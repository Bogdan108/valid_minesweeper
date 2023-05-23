import 'dart:async';
import 'package:flutter/material.dart';
import 'package:valid_minesweeper/settings/start_settings.dart';
import 'package:valid_minesweeper/logic/logic.dart';

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  GameState createState() => GameState();
}

class GameState extends State<Game> {
  int rowCount = MySettings.getrowCount();
  int columnCount = MySettings.getcolumnCount();
  int bombsCount = MySettings.getbombCount();
  late bool firstStep;
  late int hintCount;
  late dynamic random;
  late Timer? timer;
  int seconds = 0;

  // Создаем класс логику
  Logic logic = Logic();

  late int ceilsFree;

  @override
  void initState() {
    super.initState();
    initialiseGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(224, 224, 224, 1),
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
          style: TextStyle(fontSize: 30.0, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              //color: const Color(Colors.greenAccent),
              border: Border.all(
                //color: const Color.fromARGB(255, 186, 198, 186),
                color: const Color.fromRGBO(224, 224, 224, 1),
                width: 8,
              ),
              borderRadius: BorderRadius.circular(12),
              //color: const Color.fromARGB(255, 186, 198, 186),
              color: const Color.fromRGBO(224, 224, 224, 1),
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
                                "${logic.getBombCount()}",
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
                    InkWell(
                      onTap: () {
                        _specialHint();
                      },
                      child: const CircleAvatar(
                          backgroundColor: Colors.yellowAccent,
                          child: Icon(
                            Icons.lightbulb_outline,
                            color: Colors.black,
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
                return InkWell(
                  // обработка нажатия на клетку
                  onTap: () {
                    if (!firstStep) {
                      setState(() {
                        // передать
                        firstStep = true;
                        if (!logic.boardGenerator(rowNumber, columnNumber)) {
                          _inputCheckAlert();
                        }
                      });
                    }
                    if (logic.getPlayground(rowNumber, columnNumber).isBomb) {
                      _gameOverAlert();
                    }
                    if (!logic.getPlayground(rowNumber, columnNumber).isOpen) {
                      if (logic
                              .getPlayground(rowNumber, columnNumber)
                              .bombsAround ==
                          0) {
                        setState(() {
                          logic.handleTap(rowNumber, columnNumber);
                        });
                      } else {
                        setState(() {
                          logic.getPlayground(rowNumber, columnNumber).isOpen =
                              true;
                        });
                      }
                      if (logic.isWinPr()) {
                        _winAlert();
                      }
                    }
                  },
                  // Постановка флагов длительным нажатием
                  onLongPress: () {
                    setState(() {
                      if (logic
                          .getPlayground(rowNumber, columnNumber)
                          .isFlaged) {
                        logic.setBombCount(true);
                        logic.getPlayground(rowNumber, columnNumber).isFlaged =
                            false;
                      } else {
                        logic.setBombCount(false);
                        logic.getPlayground(rowNumber, columnNumber).isFlaged =
                            true;
                      }
                    });
                  },
                  splashColor: Colors.grey,
                  child: Container(
                    color: Colors.grey,
                    child: logic.getImage(position),
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
    logic.initialiseLogic();
    hintCount = 3;
    firstStep = false;
    rowCount = MySettings.getrowCount();
    columnCount = MySettings.getcolumnCount();
    bombsCount = MySettings.getbombCount();

    // установка количества свободных клеток
    ceilsFree = rowCount * columnCount;

    if (bombsCount >= ceilsFree - 8) {
      _inputCheckAlertBomb();
    }

    //  время
    seconds = 0;
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) => updateTime(),
    );

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

  //Обработчик неправильных входных данных (проверка на валидность)
  void _inputCheckAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Attention!'),
          content: const Text(
              'The game can\'t guarantee the validity of the field!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                timer?.cancel();
                initialiseGame();
                Navigator.pop(context);
              },
              child: const Text('Restart'),
            ),
            TextButton(
                child: const Text('Continue'),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ],
        );
      },
    );
  }

  //Обработчик неправильных входных данных (количество бомб превышает размеры исходного поля)
  void _inputCheckAlertBomb() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Attention!'),
          content: const Text(
              'The large number of bombs on the field, go to the settings!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'menu')
                    .then((value) => {timer?.cancel(), initialiseGame()});
              },
              child: const Text('Settings'),
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
          if (logic.getPlayground(i, j).isBomb &&
              !logic.getPlayground(i, j).isHint) {
            for (var x = i - 1; x <= i + 1; x++) {
              for (var y = j - 1; y <= j + 1; y++) {
                if (x >= 0 &&
                    x < rowCount &&
                    y >= 0 &&
                    y < columnCount &&
                    logic.getPlayground(x, y).isOpen) {
                  logic.getPlayground(i, j).isHint = true;
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

  // функция обработки строки времени
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
