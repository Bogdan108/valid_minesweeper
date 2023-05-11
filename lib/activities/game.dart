import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:valid_minesweeper/activities/ceil.dart';
import 'package:valid_minesweeper/settings/start_settings.dart';
import 'package:valid_minesweeper/utils/image_enum.dart';
import 'package:valid_minesweeper/utils/image_manage.dart';

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  GameState createState() => GameState();
}

class GameState extends State<Game> {
  int rowCount = MySettings.getrowCount();
  int columnCount = MySettings.getcolumnCount();
  int bombsCount = MySettings.getbombCount();
  late int ceilsFreeTest;
  late bool firstStep;
  late int firstX;
  late int firstY;
  late int hintCount;
  late dynamic random;
  late Timer? timer;
  int seconds = 0;
  late bool stopBot;

  // Массив содержащий объекты клеток
  late List<List<Ceil>> playground;
  late List<List<Ceil>> testGround;
  late int ceilsFree;

  @override
  void initState() {
    super.initState();
    initialiseGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, 'menu')
                    .then((value) => {timer?.cancel(), initialiseGame()});
              },
              icon: const Icon(Icons.menu_outlined))
        ],
        title: const Text(
          'Game',
          style: TextStyle(fontSize: 27.0, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              //color: const Color(Colors.greenAccent),
              border: Border.all(
                color: const Color.fromARGB(255, 186, 198, 186),
                width: 8,
              ),
              borderRadius: BorderRadius.circular(12),
              color: const Color.fromARGB(255, 186, 198, 186),
            ),
            height: 80.0,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // табло с бомбами
                Padding(
                  padding: const EdgeInsets.only(left: .0),
                  child: Container(
                    width: 120,
                    height: 55,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey,
                          width: 4.0,
                        ),
                        left: BorderSide(color: Colors.grey, width: 4.0),
                        bottom: BorderSide(color: Colors.white, width: 4.0),
                        right: BorderSide(color: Colors.white, width: 4.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset("images/bomb.png",
                                  color: Colors.red, width: 35, height: 35),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "${MySettings.getbombCount()}",
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                //Смайл
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        timer?.cancel();
                        initialiseGame();
                      },
                      child: const CircleAvatar(
                        backgroundColor: Colors.yellowAccent,
                        child: Icon(
                          Icons.tag_faces_outlined,
                          color: Colors.black,
                          size: 40.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // подсказка
                    GestureDetector(
                      onTap: () {
                        _specialHint();
                      },
                      child:
                          //color: Colors.green,
                          const Center(
                              child: Icon(
                        Icons.lightbulb_outline,
                        color: Colors.yellowAccent,
                        size: 40.0,
                      )),
                    )
                  ],
                ),

                // табло с бомбами
                Container(
                  width: 120,
                  height: 55,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    border: Border(
                      top: BorderSide(color: Colors.grey, width: 4.0),
                      left: BorderSide(color: Colors.grey, width: 4.0),
                      bottom: BorderSide(color: Colors.white, width: 4.0),
                      right: BorderSide(color: Colors.white, width: 4.0),
                    ),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.alarm,
                          color: Colors.red,
                          size: 35.0,
                        ),
                        SizedBox(
                          width: 70,
                          height: 60,
                          child: Center(
                              child: Text(
                            _printDuration(Duration(seconds: seconds.toInt())),
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                        )
                      ]),
                )
              ],
            ),
          ),
          // Построение игрового поля
          Container(
            decoration: BoxDecoration(
              //color: const Color(Colors.greenAccent),
              border: Border.all(
                color: const Color.fromARGB(255, 131, 130, 130),
                width: 8,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            width: double.infinity,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columnCount,
              ),
              itemBuilder: (context, position) {
                int rowNumber = (position / columnCount).floor();
                int columnNumber = (position % columnCount);

                Image image;

                if (playground[rowNumber][columnNumber].isOpen == false) {
                  if (playground[rowNumber][columnNumber].isFlaged == true) {
                    image = ImageManager.getImage(ImageType.flagged);
                    playground[rowNumber][columnNumber].isHint = false;
                  } else {
                    image = ImageManager.getImage(ImageType.facingDown);
                  }
                  if (playground[rowNumber][columnNumber].isHint) {
                    image = Image.asset("images/facingDown.png",
                        color: const Color.fromARGB(255, 217, 219, 82));
                  }
                } else {
                  if (playground[rowNumber][columnNumber].isBomb) {
                    image = ImageManager.getImage(ImageType.bomb);
                  } else {
                    image = ImageManager.getImage(
                      ImageManager.getImageTypeFromNumber(
                          playground[rowNumber][columnNumber].bombsAround),
                    );
                  }
                }

                return InkWell(
                  // обработка нажатяи на клетку
                  onTap: () {
                    if (!firstStep) {
                      setState(() {
                        firstStep = true;
                        firstX = rowNumber;
                        firstY = columnNumber;
                        _boardGenerator();
                      });
                    }
                    if (playground[rowNumber][columnNumber].isBomb) {
                      _gameOverAlert();
                    }
                    if (playground[rowNumber][columnNumber].bombsAround == 0) {
                      _handleTap(rowNumber, columnNumber);
                    } else {
                      setState(() {
                        playground[rowNumber][columnNumber].isOpen = true;
                        ceilsFree = ceilsFree - 1;
                      });
                    }

                    if (ceilsFree == 0) {
                      _winAlert();
                    }
                  },
                  // Постановка флагов длительным нажатием
                  onLongPress: () {
                    setState(() {
                      playground[rowNumber][columnNumber].isFlaged =
                          !playground[rowNumber][columnNumber].isFlaged;
                    });
                  },
                  splashColor: Colors.grey,
                  child: Container(
                    color: Colors.grey,
                    child: image,
                  ),
                );
              },
              itemCount: rowCount * columnCount,
            ),
          )
        ],
      ),
    );
  }

  // Инициализация игры
  void initialiseGame() {
    hintCount = 3;
    random = Random();
    firstStep = false;
    firstX = -1;
    firstY = -1;
    stopBot = false;
    rowCount = MySettings.getrowCount();
    columnCount = MySettings.getcolumnCount();
    bombsCount = MySettings.getbombCount();

    // установка количества свободных клеток
    ceilsFree = rowCount * columnCount;

    if (bombsCount >= ceilsFree - 8) {
      stopBot = true;
      _inputCheckAlert();
    }
    playground = List.generate(rowCount, (i) {
      return List.generate(columnCount, (j) {
        return Ceil();
      });
    });

    testGround = List.generate(rowCount, (i) {
      return List.generate(columnCount, (j) {
        return Ceil();
      });
    });
    //  время
    seconds = 0;
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) => updateTime(),
    );

    setState(() {});
  }

  void _boardGenerator() {
    bool isValid = false;
    int localCounter = 0;
    while (!isValid) {
      localCounter++;
      print('$localCounter');
      if (localCounter >= 1100) {
        _inputCheckAlert();
        break;
      }

      ceilsFreeTest = rowCount * columnCount;
      playground = List.generate(rowCount, (i) {
        return List.generate(columnCount, (j) {
          return Ceil();
        });
      });

      testGround = List.generate(rowCount, (i) {
        return List.generate(columnCount, (j) {
          return Ceil();
        });
      });

      for (var i = 0; i < rowCount; i++) {
        for (var j = 0; j < columnCount; j++) {
          playground[i][j].bombsAround = 0;
          playground[i][j].isBomb = false;
          testGround[i][j].bombsAround = 0;
          testGround[i][j].isBomb = false;
        }
      }
      // обработка первого хода
      for (var i = firstX - 1; i <= firstX + 1; i++) {
        for (var j = firstY - 1; j <= firstY + 1; j++) {
          if (i >= 0 && i < rowCount && j >= 0 && j < columnCount) {
            playground[i][j].isBooked = true;
            testGround[i][j].isBooked = true;
          }
        }
      }

      // Случайная расстановка бомб с учётом первого хода
      for (var i = 0; i < bombsCount; i++) {
        int x, y;
        do {
          x = random.nextInt(rowCount);
          y = random.nextInt(columnCount);
        } while (playground[x][y].isBomb || playground[x][y].isBooked);
        --ceilsFree;
        --ceilsFreeTest;
        playground[x][y].isBomb = true;
        testGround[x][y].isBomb = true;
      }

      // Функция вычисления бомб рядом с клеткой

      for (var i = 0; i < rowCount; i++) {
        for (var j = 0; j < columnCount; j++) {
          playground[i][j].bombsAround = _countBombsAround(i, j, playground);
          testGround[i][j].bombsAround = _countBombsAround(i, j, testGround);
        }
      }
      isValid = botValidator(isValid);
    }
  }

  bool botValidator(bool validFlag) {
    _botTap(firstX, firstY);

    while (!isWin(testGround) && !stopBot) {
      bool specialMove = false;
      for (var i = 0; i < rowCount; i++) {
        for (var j = 0; j < columnCount; j++) {
          if (testGround[i][j].bombsAround > 0 && !testGround[i][j].isBomb) {
            // теперь обрабатываю каждую клетку
            var closedCount = 0;
            var flagedCount = 0;
            for (var dx = i - 1; dx <= i + 1; dx++) {
              for (var dy = j - 1; dy <= j + 1; dy++) {
                if (dx >= 0 && dx < rowCount && dy >= 0 && dy < columnCount) {
                  if (!testGround[dx][dy].isOpen) {
                    closedCount++;
                  }
                  if (testGround[dx][dy].isFlaged &&
                      !testGround[dx][dy].isOpen) {
                    flagedCount++;
                  }
                }
              }
            }
            // проверка, что кол-во неоткрытых клеток вокруг равно количесву бомб вокруг
            if (closedCount == testGround[i][j].bombsAround) {
              for (var dx = i - 1; dx <= i + 1; dx++) {
                for (var dy = j - 1; dy <= j + 1; dy++) {
                  if (dx >= 0 && dx < rowCount && dy >= 0 && dy < columnCount) {
                    if (!testGround[dx][dy].isFlaged) {
                      testGround[dx][dy].isFlaged = true;
                      specialMove = true;
                    }
                  }
                }
              }
            }

            if (flagedCount == testGround[i][j].bombsAround) {
              for (var dx = i - 1; dx <= i + 1; dx++) {
                for (var dy = j - 1; dy <= j + 1; dy++) {
                  if (dx >= 0 && dx < rowCount && dy >= 0 && dy < columnCount) {
                    if (!testGround[dx][dy].isFlaged) {
                      testGround[dx][dy].isOpen = true;
                      _botTap(dx, dy);
                      specialMove = true;
                    }
                  }
                }
              }
            }
          }
        }
        setState(() {});
      }
      if (specialMove == false) {
        break;
      }
    }
    validFlag = isWin(testGround);
    return validFlag;
  }

  void _botTap(int i, int j) {
    ceilsFreeTest = ceilsFreeTest - 1;
    testGround[i][j].isOpen = true;
    if (testGround[i][j].bombsAround == 0) {
      for (var dx = -1; dx <= 1; dx++) {
        for (var dy = -1; dy <= 1; dy++) {
          final nx = i + dx;
          final ny = j + dy;
          if (nx >= 0 &&
              nx < rowCount &&
              ny >= 0 &&
              ny < columnCount &&
              !testGround[nx][ny].isOpen) {
            _botTap(nx, ny);
          }
        }
      }
    }
    setState(() {});
  }

  bool isWin(List<List<Ceil>> testGround) {
    for (var i = 0; i < rowCount; i++) {
      for (var j = 0; j < columnCount; j++) {
        if (!testGround[i][j].isOpen && !testGround[i][j].isBomb) {
          return false;
        }
      }
    }
    return true;
  }

  int _countBombsAround(int x, int y, List<List<Ceil>> ground) {
    var bombsCount = 0;
    for (var i = x - 1; i <= x + 1; i++) {
      for (var j = y - 1; j <= y + 1; j++) {
        if (i >= 0 && i < rowCount && j >= 0 && j < columnCount) {
          if (ground[i][j].isBomb) bombsCount++;
        }
      }
    }
    return bombsCount;
  }

  void _handleTap(int i, int j) {
    ceilsFree = ceilsFree - 1;
    playground[i][j].isOpen = true;
    if (playground[i][j].bombsAround == 0) {
      for (var dx = -1; dx <= 1; dx++) {
        for (var dy = -1; dy <= 1; dy++) {
          final nx = i + dx;
          final ny = j + dy;
          if (nx >= 0 &&
              nx < rowCount &&
              ny >= 0 &&
              ny < columnCount &&
              !playground[nx][ny].isOpen) {
            _handleTap(nx, ny);
          }
        }
      }
    }
    setState(() {});
  }

  // Обработчик завершения игры (проигрыш)
  void _gameOverAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Game Over!"),
          content: const Text("You stepped on a mine!"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                timer?.cancel();
                initialiseGame();
                Navigator.pop(context);
              },
              child: const Text("Play again"),
            ),
          ],
        );
      },
    );
  }

//Обработчик завершения игры (выигрыш)
  void _winAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Congratulations!"),
          content: const Text("You Win!"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                timer?.cancel();
                initialiseGame();
                Navigator.pop(context);
              },
              child: const Text("Play again"),
            ),
          ],
        );
      },
    );
  }

  //Обработчик неправильных входных данных
  void _inputCheckAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Attention!"),
          content: const Text("A lot of cells with bombs!"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Continue"),
            ),
          ],
        );
      },
    );
  }

  bool _specialHint() {
    if (hintCount != 0 && firstStep) {
      for (var i = 0; i < rowCount; i++) {
        for (var j = 0; j < columnCount; j++) {
          if (playground[i][j].isBomb && !playground[i][j].isHint) {
            for (var x = i - 1; x <= i + 1; x++) {
              for (var y = j - 1; y <= j + 1; y++) {
                if (x >= 0 &&
                    x < rowCount &&
                    y >= 0 &&
                    y < columnCount &&
                    playground[x][y].isOpen) {
                  playground[i][j].isHint = true;
                  --hintCount;
                  setState(() {});
                  return true;
                }
              }
            }
          }
        }
      }
    }
    return false;
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  updateTime() {
    if (firstStep) {
      seconds++;
      setState(() {});
    }
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
