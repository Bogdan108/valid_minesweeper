import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(224, 224, 224, 1),
        appBar: AppBar(
          title: const Text(
            'MineSweeper',
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'images/background_image.png'), // Путь к вашей фотографии
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, 'game', (route) => true);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        child: const Text(
                          'Play',
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )),
                    const SizedBox(height: 15.0),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, 'menu', (route) => true);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        child: const Text(
                          'Settings',
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ))
                  ]),
            )));
  }
}
