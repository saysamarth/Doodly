import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:skribble/views/inner_screens/leaderboard.dart';
import 'package:skribble/views/home.dart';
import 'package:skribble/models/my_custom_painter.dart';
import 'package:skribble/models/touch_points.dart';
import 'package:skribble/views/widgets/scoreboard.dart';
import 'package:skribble/views/inner_screens/waiting_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class PaintScreen extends StatefulWidget {
  final Map<String, String> data;
  final String screenFrom;
  const PaintScreen({required this.data, required this.screenFrom, super.key});

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen>
    with SingleTickerProviderStateMixin {
  List<TouchPoints> paths = [];
  List<TouchPoints> currentPoints = [];
  late IO.Socket _socket;
  Map dataOfRoom = {};
  StrokeCap strokeType = StrokeCap.round;
  Color selectedColor = Colors.black;
  double opacity = 1;
  double strokeWidth = 2;
  List<Widget> textBlankWidget = [];
  ScrollController _scrollController = ScrollController();
  TextEditingController controller = TextEditingController();
  List<Map> messages = [];
  int guessedUserCtr = 0;
  int _start = 60;
  late Timer _timer;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map> scoreboard = [];
  bool isTextInputReadOnly = false;
  int maxPoints = 0;
  String winner = "";
  bool isShowFinalLeaderboard = false;

  // Animation controller for timer pulse effect
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    connect();

    // Initialize pulse animation for timer
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer time) {
      if (_start == 0) {
        _socket.emit('change-turn', dataOfRoom['name']);
        setState(() {
          _timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void renderTextBlank(String text) {
    textBlankWidget.clear();
    for (int i = 0; i < text.length; i++) {
      textBlankWidget.add(const Text('_', style: TextStyle(fontSize: 30)));
    }
  }

  // Socket io client connection
  void connect() {
    _socket = IO.io('http://192.168.0.105:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    _socket.connect();

    if (widget.screenFrom == 'createRoom') {
      _socket.emit('create-game', widget.data);
    } else {
      _socket.emit('join-game', widget.data);
    }

    _socket.onConnect((_) {
      _socket.on('updateRoom', (roomData) {
        if (mounted) handleRoomUpdate(roomData);
      });
      _socket.on('notCorrectGame', (_) {
        if (mounted) navigateToHome();
      });
      _socket.on('points', handleIncomingPoints);
      _socket.on('msg', handleMessage);
      _socket.on('change-turn', handleTurnChange);
      _socket.on('updateScore', updateScoreboard);
      _socket.on('show-leaderboard', showLeaderboard);
      _socket.on('color-change', handleColorChange);
      _socket.on('stroke-width', handleStrokeWidth);
      _socket.on('clear-screen', clearCanvas);
      _socket.on('closeInput', closeInput);
      _socket.on('user-disconnected', updateScoreboard);
    });

    _socket.onDisconnect((_) => print('User disconnected'));
    _socket.on('user-disconnected', (roomData) {
      updateScoreboard(roomData['players']);
    });
  }

  void handleRoomUpdate(roomData) {
    setState(() {
      renderTextBlank(roomData['word']);
      dataOfRoom = roomData;
    });
    if (roomData['isJoin'] != true) {
      startTimer();
    }
    updateScoreboard(roomData['players']);
  }

  void navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomeScreen()),
      (route) => false,
    );
  }

  void handleIncomingPoints(point) {
    if (point['details'] == null) {
      setState(() {
        paths.addAll(currentPoints);
        currentPoints.clear();
      });
    } else {
      try {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final Size canvasSize = box.size;

        final double normalizedX =
            point['details']['point']['normalizedX'] ?? 0.0;
        final double normalizedY =
            point['details']['point']['normalizedY'] ?? 0.0;

        setState(() {
          currentPoints.add(
            TouchPoints.fromNormalized(
              normalizedX: normalizedX,
              normalizedY: normalizedY,
              paint:
                  Paint()
                    ..color = Color(point['details']['paint']['color'] as int)
                    ..strokeWidth =
                        (point['details']['paint']['strokeWidth'] as num)
                            .toDouble()
                    ..strokeCap = StrokeCap.round,
              canvasSize: canvasSize,
              isNewStroke: point['details']['isNewStroke'] ?? false,
            ),
          );
        });
      } catch (e) {
        print("Error handling incoming point: $e");
      }
    }
  }

  void handleMessage(msgData) {
    setState(() {
      messages.add(msgData);
      guessedUserCtr = msgData['guessedUserCtr'];
    });
    if (guessedUserCtr == dataOfRoom['players'].length - 1) {
      _socket.emit('change-turn', dataOfRoom['name']);
    }
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 40,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  void handleTurnChange(data) {
    String oldWord = dataOfRoom['word'] ?? '';
    final BuildContext currentContext = context;
    showDialog(
      context: currentContext,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              dataOfRoom = data;
              renderTextBlank(data['word'] ?? '');
              isTextInputReadOnly = false;
              guessedUserCtr = 0;
              _start = 60;
              paths.clear();
              currentPoints.clear();
            });
          }

          Navigator.of(context).pop();
          if (mounted) {
            if (_timer.isActive) {
              _timer.cancel();
            }
            startTimer();
          }
        });
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Center(
            child: Text(
              'Word was "$oldWord"',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
          ),
          content: Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.green,
          ),
        );
      },
    );
  }

  void updateScoreboard(roomData) {
    scoreboard.clear();
    if (roomData != null) {
      try {
        final players =
            roomData is List ? roomData : (roomData['players'] ?? []);
        for (int i = 0; i < players.length; i++) {
          setState(() {
            scoreboard.add({
              'username': players[i]['nickname'] ?? 'Unknown',
              'points': (players[i]['points'] ?? 0).toString(),
            });
          });
        }
      } catch (e) {
        print("Error updating scoreboard: $e");
      }
    }
  }

  void showLeaderboard(roomPlayers) {
    scoreboard.clear();
    for (int i = 0; i < roomPlayers.length; i++) {
      setState(() {
        scoreboard.add({
          'username': roomPlayers[i]['nickname'],
          'points': roomPlayers[i]['points'].toString(),
        });
      });
      if (maxPoints < int.parse(scoreboard[i]['points'])) {
        winner = scoreboard[i]['username'];
        maxPoints = int.parse(scoreboard[i]['points']);
      }
    }
    setState(() {
      _timer.cancel();
      isShowFinalLeaderboard = true;
    });
  }

  void handleColorChange(colorString) {
    int value = int.parse(colorString, radix: 16);
    Color otherColor = Color(value);
    setState(() {
      selectedColor = otherColor;
    });
  }

  void handleStrokeWidth(value) {
    setState(() {
      if (value is Map) {
        strokeWidth = value['value'].toDouble();
      } else if (value is num) {
        strokeWidth = value.toDouble();
      }
    });
  }

  void clearCanvas(data) {
    setState(() {
      paths.clear();
      currentPoints.clear();
    });
  }

  void closeInput(data) {
    _socket.emit('updateScore', widget.data['name']);
    setState(() {
      isTextInputReadOnly = true;
    });
  }

  void selectColor() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Choose Color',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            content: SingleChildScrollView(
              child: BlockPicker(
                pickerColor: selectedColor,
                onColorChanged: (color) {
                  setState(() {
                    selectedColor = color;
                  });

                  final String valueString = color.value
                      .toRadixString(16)
                      .padLeft(8, '0');

                  Map map = {
                    'color': valueString,
                    'roomName': dataOfRoom['name'],
                  };
                  _socket.emit('color-change', map);
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void panStartHandle(DragStartDetails details) {
    if (!mounted) return;
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localOffset = details.localPosition;
    final Size canvasSize = box.size;

    // Calculate normalized coordinates (0.0 to 1.0)
    final normalizedX = localOffset.dx / canvasSize.width;
    final normalizedY = localOffset.dy / canvasSize.height;

    setState(() {
      currentPoints.add(
        TouchPoints(
          points: localOffset,
          paint:
              Paint()
                ..color = selectedColor
                ..strokeWidth = strokeWidth
                ..strokeCap = StrokeCap.round,
          isNewStroke: true,
          normalizedX: normalizedX,
          normalizedY: normalizedY,
        ),
      );
    });

    _socket.emit('paint', {
      'details': {
        'point': {
          'dx': localOffset.dx,
          'dy': localOffset.dy,
          'normalizedX': normalizedX,
          'normalizedY': normalizedY,
        },
        'paint': {'color': selectedColor.value, 'strokeWidth': strokeWidth},
        'isNewStroke': true,
      },
      'roomName': widget.data['name'],
    });
  }

  void panUpdateHandle(DragUpdateDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localOffset = details.localPosition;
    final Size canvasSize = box.size;
    final normalizedX = localOffset.dx / canvasSize.width;
    final normalizedY = localOffset.dy / canvasSize.height;
    setState(() {
      currentPoints.add(
        TouchPoints(
          points: localOffset,
          paint:
              Paint()
                ..color = selectedColor
                ..strokeWidth = strokeWidth
                ..strokeCap = StrokeCap.round,
          normalizedX: normalizedX,
          normalizedY: normalizedY,
        ),
      );
    });
    _socket.emit('paint', {
      'details': {
        'point': {
          'dx': localOffset.dx,
          'dy': localOffset.dy,
          'normalizedX': normalizedX,
          'normalizedY': normalizedY,
        },
        'paint': {'color': selectedColor.value, 'strokeWidth': strokeWidth},
      },
      'roomName': widget.data['name'],
    });
  }

  void panEndHandle(DragEndDetails details) {
    setState(() {
      paths.addAll(currentPoints);
      currentPoints.clear();
    });
    _socket.emit('paint', {'details': null, 'roomName': widget.data['name']});
  }

  bool get _canUserDraw =>
      dataOfRoom['turn']['nickname'] == widget.data['nickname'] &&
      dataOfRoom['turn']['socketID'] == _socket.id;

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    _pulseController.dispose();
    if (_socket.connected) {
      _socket.disconnect();
      _socket.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // Generate dynamic colors based on the room name for consistency
    final int hashCode = dataOfRoom.isEmpty ? 0 : dataOfRoom['name'].hashCode;
    final Color primaryColor = Colors.blue;
    final Color baseColor = Color.fromARGB(
      255,
      60 + (hashCode % 80),
      100 + (hashCode % 100),
      180 + (hashCode % 70),
    );
    final Color lighterColor = baseColor.withAlpha(200);
    final Color darkerColor = baseColor.withAlpha(255);

    if (dataOfRoom.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [primaryColor.withAlpha(25), Colors.white],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    color: primaryColor,
                    strokeWidth: 6,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  "Loading game...",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (dataOfRoom['isJoin'] == true) {
      return WaitingLobbyScreen(
        lobbyName: dataOfRoom['name'],
        noOfPlayers: dataOfRoom['players'].length,
        occupancy: dataOfRoom['occupancy'],
        players: dataOfRoom['players'],
      );
    }

    if (isShowFinalLeaderboard) {
      return FinalLeaderboard(scoreboard, winner);
    }

    return Scaffold(
      key: scaffoldKey,
      drawer: PlayerScore(scoreboard),
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [baseColor.withAlpha(12), Colors.white.withAlpha(225)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar with custom styling
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(12),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => scaffoldKey.currentState!.openDrawer(),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: baseColor.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.menu, color: darkerColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        dataOfRoom['name'] ?? 'Skribble Game',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkerColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: darkerColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person, size: 16, color: darkerColor),
                          const SizedBox(width: 4),
                          Text(
                            '${dataOfRoom['players']?.length ?? 0}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: darkerColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        // Apply pulse animation when time is running low
                        final bool isLowTime = _start <= 10;
                        final double scale =
                            isLowTime ? _pulseAnimation.value : 1.0;

                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  isLowTime ? Colors.red : lighterColor,
                                  isLowTime ? Colors.red.shade700 : darkerColor,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (isLowTime ? Colors.red : darkerColor)
                                      .withAlpha(80),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '$_start',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [lighterColor, darkerColor],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: baseColor.withAlpha(80),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Current drawer indicator
                            if (_canUserDraw)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(50),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.brush,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            if (_canUserDraw) const SizedBox(width: 12),

                            // Word or blanks
                            dataOfRoom['turn']['nickname'] !=
                                    widget.data['nickname']
                                ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:
                                      textBlankWidget
                                          .map(
                                            (widget) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 4.0,
                                                  ),
                                              child: widget,
                                            ),
                                          )
                                          .toList(),
                                )
                                : Text(
                                  dataOfRoom['word'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                          ],
                        ),
                      ),

                      // Drawing canvas with shadow and border
                      Container(
                        width: width,
                        height: height * 0.4,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(18),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              // Drawing canvas
                              GestureDetector(
                                onPanUpdate:
                                    _canUserDraw ? panUpdateHandle : null,
                                onPanStart:
                                    _canUserDraw ? panStartHandle : null,
                                onPanEnd: _canUserDraw ? panEndHandle : null,
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.white,
                                  child: CustomPaint(
                                    painter: MyCustomPainter(
                                      paths: paths,
                                      currentPoints: currentPoints,
                                    ),
                                  ),
                                ),
                              ),

                              // "Your Turn" overlay when it's not your turn to draw
                              if (!_canUserDraw)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(160),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Colors.lightGreen,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${dataOfRoom['turn']['nickname']} is drawing',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Drawing tools - only visible when it's your turn
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: _canUserDraw ? 70 : 0,
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow:
                              _canUserDraw
                                  ? [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(12),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                  : null,
                        ),
                        child:
                            _canUserDraw
                                ? Row(
                                  children: [
                                    // Color selector
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: selectColor,
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          width: 70,
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: selectedColor,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                    width: 2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: selectedColor
                                                          .withAlpha(100),
                                                      blurRadius: 4,
                                                      spreadRadius: 1,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Stroke width slider
                                    Expanded(
                                      child: Slider(
                                        min: 1.0,
                                        max: 10,
                                        divisions: 9,
                                        label: "${strokeWidth.toInt()}",
                                        activeColor: selectedColor,
                                        inactiveColor: selectedColor.withAlpha(
                                          50,
                                        ),
                                        value: strokeWidth,
                                        onChanged: (double value) {
                                          setState(() {
                                            strokeWidth = value;
                                          });
                                          Map map = {
                                            'value': value,
                                            'roomName': dataOfRoom['name'],
                                          };
                                          _socket.emit('stroke-width', map);
                                        },
                                      ),
                                    ),
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          _socket.emit(
                                            'clean-screen',
                                            dataOfRoom['name'],
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          width: 60,
                                          padding: const EdgeInsets.all(8),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.delete_outline,
                                                color: Colors.red.shade400,
                                                size: 28,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                : SizedBox(),
                      ),

                      if (!_canUserDraw)
                        Container(
                          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: darkerColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: darkerColor.withAlpha(50),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 18,
                                color: darkerColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Guess the word in the chat below",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: darkerColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                      Container(
                        height:
                            height * 0.21, // Fixed height instead of Expanded
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(12),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(12),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            var msg = messages[index].values;
                            final username = msg.elementAt(0);
                            final message = msg.elementAt(1);
                            final isCurrentUser =
                                username == widget.data['nickname'];

                            // Check if message is a correct guess
                            final bool isCorrectGuess = message
                                .toLowerCase()
                                .contains(
                                  (dataOfRoom['word'] ?? '').toLowerCase(),
                                );

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // User avatar
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          isCurrentUser
                                              ? darkerColor
                                              : Colors.grey.shade400,
                                          isCurrentUser
                                              ? lighterColor
                                              : Colors.grey.shade600,
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        username.substring(0, 1).toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // Message content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              username,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    isCurrentUser
                                                        ? darkerColor
                                                        : Colors.black87,
                                                fontSize: 14,
                                              ),
                                            ),
                                            if (isCorrectGuess)
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  left: 8,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.withAlpha(
                                                    50,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: const [
                                                    Icon(
                                                      Icons.check_circle,
                                                      color: Colors.green,
                                                      size: 12,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'Guessed it!',
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                isCorrectGuess
                                                    ? Colors.green.withAlpha(
                                                      125,
                                                    )
                                                    : (isCurrentUser
                                                        ? baseColor.withAlpha(
                                                          25,
                                                        )
                                                        : Colors.grey.shade100),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color:
                                                  isCorrectGuess
                                                      ? Colors.green.withAlpha(
                                                        80,
                                                      )
                                                      : (isCurrentUser
                                                          ? baseColor.withAlpha(
                                                            50,
                                                          )
                                                          : Colors
                                                              .grey
                                                              .shade200),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            message,
                                            style: TextStyle(
                                              color:
                                                  isCorrectGuess
                                                      ? Colors.green.shade800
                                                      : Colors.black87,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Current word/blanks display

              // Message input field
              if (dataOfRoom['turn']['nickname'] != widget.data['nickname'])
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(12),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    readOnly: isTextInputReadOnly,
                    controller: controller,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        Map map = {
                          'username': widget.data['nickname'],
                          'msg': value.trim(),
                          'word': dataOfRoom['word'],
                          'roomName': widget.data['name'],
                          'guessedUserCtr': guessedUserCtr,
                          'totalTime': 60,
                          'timeTaken': 60 - _start,
                        };
                        _socket.emit('msg', map);
                        controller.clear();
                      }
                    },
                    autocorrect: false,
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: baseColor.withAlpha(128),
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      hintText:
                          isTextInputReadOnly
                              ? 'Waiting for next round...'
                              : 'Type your guess here...',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade500,
                      ),
                      prefixIcon: Icon(
                        Icons.message_outlined,
                        color:
                            isTextInputReadOnly
                                ? Colors.grey.shade400
                                : darkerColor,
                        size: 20,
                      ),
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              isTextInputReadOnly
                                  ? Colors.grey.shade300
                                  : lighterColor,
                              isTextInputReadOnly
                                  ? Colors.grey.shade400
                                  : darkerColor,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
