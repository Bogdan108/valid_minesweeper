import 'package:flutter/material.dart';
import 'package:valid_minesweeper/settings/start_settings.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  MenuState createState() => MenuState();
}

class MenuState extends State<Menu> {
  // размеры поля

  //размеры легкого уровня
  static const int easyRow = 8;
  static const int easyColumn = 8;

  //размеры среднего уровня
  static const int middleRow = 16;
  static const int middleColumn = 16;

  //размеры тяжелого уровня
  static const int difficultRow = 30;
  static const int difficultColumn = 16;

// Количество бомб
  static const int easilyBomb = 10;
  static const int middleBomb = 40;
  static const int hardBomb = 99;

// стиль
  static const int base = 0;
  static const int colorful = 1;

// параметры слайдеров
  int _bombSlide = easilyBomb;
  int _rowSlide = easyRow;
  int _columnSlide = easyColumn;

  Color _buttonColorEasy = Colors.blue;
  Color _buttonColorMiddle = Colors.blue;
  Color _buttonColorHard = Colors.blue;
  Color _buttonColorCustom = Colors.blue;

  Color _buttonColorStyle1 = Colors.blue;
  Color _buttonColorStyle2 = Colors.blue;

  MenuState() {
    _bombSlide = MySettings.getbombCount();
    _rowSlide = MySettings.getrowCount();
    _columnSlide = MySettings.getcolumnCount();
    if (MySettings.getCustom()) {
      _buttonColorCustom = Colors.green;
    } else {
      switch (MySettings.getbombCount()) {
        case easilyBomb:
          _buttonColorEasy = Colors.green;
          break;
        case middleBomb:
          _buttonColorMiddle = Colors.green;
          break;
        case hardBomb:
          _buttonColorHard = Colors.green;
          break;
      }
    }

    switch (MySettings.getStyle()) {
      case base:
        _buttonColorStyle1 = Colors.green;
        break;
      case colorful:
        _buttonColorStyle2 = Colors.green;
        break;
    }
  }

  void _changeColorAndState(int buttonNumber) {
    setState(() {
      switch (buttonNumber) {
        case 1:
          _buttonColorEasy = Colors.green;
          _buttonColorMiddle = Colors.blue;
          _buttonColorHard = Colors.blue;
          _buttonColorCustom = Colors.blue;
          MySettings.setSize(easyRow, easyColumn);
          MySettings.setBombs(easilyBomb);
          MySettings.setCustom(false);
          break;
        case 2:
          _buttonColorEasy = Colors.blue;
          _buttonColorMiddle = Colors.green;
          _buttonColorHard = Colors.blue;
          _buttonColorCustom = Colors.blue;
          MySettings.setSize(middleRow, middleColumn);
          MySettings.setBombs(middleBomb);
          MySettings.setCustom(false);
          break;
        case 3:
          _buttonColorEasy = Colors.blue;
          _buttonColorMiddle = Colors.blue;
          _buttonColorHard = Colors.green;
          _buttonColorCustom = Colors.blue;
          MySettings.setSize(difficultRow, difficultColumn);
          MySettings.setBombs(hardBomb);
          MySettings.setCustom(false);
          break;
        case 4:
          _buttonColorEasy = Colors.blue;
          _buttonColorMiddle = Colors.blue;
          _buttonColorHard = Colors.blue;
          _buttonColorCustom = Colors.green;
          MySettings.setSize(_rowSlide, _columnSlide);
          MySettings.setBombs(_bombSlide);
          MySettings.setCustom(true);
          break;
      }
      _bombSlide = MySettings.getbombCount();
      _rowSlide = MySettings.getrowCount();
      _columnSlide = MySettings.getcolumnCount();
    });
  }

  void _changeStyleAndState(int buttonNumber) {
    setState(() {
      switch (buttonNumber) {
        case base:
          _buttonColorStyle1 = Colors.green;
          _buttonColorStyle2 = Colors.blue;
          MySettings.setStyle(0);
          break;
        case colorful:
          _buttonColorStyle1 = Colors.blue;
          _buttonColorStyle2 = Colors.green;
          MySettings.setStyle(1);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Difficulty',
                      style: TextStyle(fontSize: 30.0),
                    ),
                    const SizedBox(height: 30.0),
                    ElevatedButton(
                      onPressed: () => _changeColorAndState(2),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _buttonColorMiddle),
                      child: const Text('Middle (16x16, 40)',
                          style:
                              TextStyle(fontSize: 18.0, color: Colors.white)),
                    ),
                    //mainAxisAlignment: MainAxisAlignment.center,
                    //mainAxisSize: MainAxisSize.min,
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      ElevatedButton(
                        onPressed: () => _changeColorAndState(1),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: _buttonColorEasy),
                        child: const Text(
                          'Easy (8x8, 10)',
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 30),
                      ElevatedButton(
                        onPressed: () => _changeColorAndState(3),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: _buttonColorHard),
                        child: const Text(
                          'Large (30x16, 99)',
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                        ),
                      )
                    ]),
                    ElevatedButton(
                      onPressed: () => _changeColorAndState(4),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _buttonColorCustom),
                      child: const Text(
                        'Custom',
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 35),

                    // кастомизация поля (слайдеры)
                    // бомбы
                    const Text(
                      'Custom',
                      style: TextStyle(fontSize: 30.0),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Slider(
                          value: _bombSlide.toDouble(),
                          min: easilyBomb.toDouble(),
                          max: hardBomb.toDouble(),
                          onChanged: (value) {
                            setState(() {
                              _bombSlide = value.round();
                              if (_buttonColorCustom == Colors.green) {
                                MySettings.setBombs(_bombSlide);
                              }
                            });
                          },
                        ),
                        Text('Bombs: $_bombSlide'),

                        // строка
                        Slider(
                          value: _rowSlide.toDouble(),
                          min: easyRow.toDouble(),
                          max: 80,
                          onChanged: (value) {
                            setState(() {
                              _rowSlide = value.round();
                              if (_buttonColorCustom == Colors.green) {
                                MySettings.setSize(_rowSlide, _columnSlide);
                              }
                            });
                          },
                        ),
                        Text('Row: $_rowSlide'),

                        // столбец
                        Slider(
                          value: _columnSlide.toDouble(),
                          min: easyColumn.toDouble(),
                          max: 18,
                          onChanged: (value) {
                            setState(() {
                              _columnSlide = value.round();
                              if (_buttonColorCustom == Colors.green) {
                                MySettings.setSize(_rowSlide, _columnSlide);
                              }
                            });
                          },
                        ),
                        Text('Columns: $_columnSlide'),
                      ],
                    ),
                    const SizedBox(height: 35),

                    // выбор стилей для полей
                    const Text(
                      'Style',
                      style: TextStyle(fontSize: 30.0),
                    ),
                    const SizedBox(height: 30.0),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      ElevatedButton(
                        onPressed: () => _changeStyleAndState(base),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: _buttonColorStyle1),
                        child: const Text(
                          'Base',
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 80),
                      ElevatedButton(
                        onPressed: () => _changeStyleAndState(colorful),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: _buttonColorStyle2),
                        child: const Text(
                          'Colorful',
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                        ),
                      )
                    ]),
                  ],
                ),
              ]),
        ));
  }
}
