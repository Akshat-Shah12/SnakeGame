import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Game(),
    );
  }
}

class Game extends StatefulWidget {
  const Game({Key key}) : super(key: key);

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  int numberOfSquares = 760;
  static var randomNumber = Random();
  int food = randomNumber.nextInt(700);
  String direction = "left";
  bool gameIsOn = false;
  bool paused = false;
  List<int> snakePosition = [45, 65, 85, 105, 125];
  var duration = Duration(milliseconds: 300);

  void startGame() {
    gameIsOn = true;
    paused = false;
    snakePosition = [45, 65, 85, 105, 125];
    Timer.periodic(duration, (timer) {
      if (!paused) {
        updateSnake();
        if (gameOver()) {
          timer.cancel();
          showGameOverScreen(snakePosition.length);
        }
      }
    });
  }

  void restart() {
    setState(() {
      gameIsOn=false;
      direction="down";
      paused=true;
      snakePosition = [45, 65, 85, 105, 125];
    });
  }

  void generateNewFood() {
    setState(() {
      food = randomNumber.nextInt(700);
    });
  }

  void updateSnake() {
    setState(() {
      if (direction == "down") {
        print("down");
        if (snakePosition.last > 740) {
          snakePosition.add(snakePosition.last - 740);
        } else {
          snakePosition.add(snakePosition.last + 20);
        }
      } else if (direction == "up") {
        print("up");
        if (snakePosition.last < 20) {
          ////check for <21 and <20 to see if the grid numbering starts from 0 or 1
          snakePosition.add(snakePosition.last + 740);
        } else {
          snakePosition.add(snakePosition.last - 20);
        }
      } else if (direction == "left") {
        print("left");

        if (snakePosition.last % 20 == 0) {
          snakePosition.add(snakePosition.last + 19);
        } else {
          snakePosition.add(snakePosition.last - 1);
        }
      } else if (direction == "right") {
        print("right");
        if ((snakePosition.last+1) % 20 == 0) {
          snakePosition.add(snakePosition.last - 19);
        } else {
          snakePosition.add(snakePosition.last + 1);
        }
      }
      if (snakePosition.last == food) {
        generateNewFood();
      } else {
        setState(() {
          snakePosition.removeAt(0);
        });
      }
    });
  }

  bool gameOver() {
    for (var i = 0; i < snakePosition.length; i++) {
      for (var j = i + 1; j < snakePosition.length; j++) {
        if (snakePosition[i] == snakePosition[j]) {
          gameIsOn = false;
          return true;
        }
      }
    }
    return false;
  }

  Future showGameOverScreen(int num) => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text("Game Over"),
          content: Text("Your score is ${num}"),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  restart();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Go Back'),
            )
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              // onDoubleTap: () {
              //   startGame();
              // },
              onVerticalDragUpdate: (details) {
                if (gameIsOn &&
                    !paused &&
                    direction != "up" &&
                    details.delta.dy > 0) {
                  direction = "down";
                } else if (gameIsOn &&
                    !paused &&
                    direction != "down" &&
                    details.delta.dy < 0) {
                  direction = "up";
                }
              },
              onHorizontalDragUpdate: (details) {
                if (gameIsOn &&
                    !paused &&
                    direction != "left" &&
                    details.delta.dx > 0) {
                  direction = "right";
                } else if (gameIsOn &&
                    !paused &&
                    direction != "right" &&
                    details.delta.dx < 0) {
                  direction = "left";
                }
              },
              child: Container(
                child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: numberOfSquares,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 20),
                    itemBuilder: (context, index) {
                      if (snakePosition.contains(index)) {
                        return Center(
                          child: Container(
                            padding: EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }
                      if (index == food) {
                        return Container(
                          padding: EdgeInsets.all(2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              color: Colors.green,
                            ),
                          ),
                        );
                      } else {
                        return Container(
                          padding: EdgeInsets.all(2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              color: Colors.grey[850],
                            ),
                          ),
                        );
                      }
                    }),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: gameIsOn
                ? Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        paused?
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              paused=false;
                            });
                            
                          },
                          child: Text(
                            " R E S U M E",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        )
                        :GestureDetector(
                          onTap: () {
                            setState(() {
                              paused=true;
                            });
                            
                          },
                          child: Text(
                            " P A U S E",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            restart();
                          },
                          child: Text(
                            " R E S T A R T",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  )
                : GestureDetector(
                    onTap: startGame,
                    child: Text(
                      " S T A R T",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
