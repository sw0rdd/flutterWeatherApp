import 'package:flutter/material.dart';


class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Project Weather",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
                fontFamily: "Anton"
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "This is an app that is developed for the course\n"
                    "1DV535 at Linneaus University using Flutter and the\n"
                    "OpenWeatherMAP API. \n",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: "Merriweather"
                ),
              )
            ),
            Text(
              "Developed by Seif-Alamir Yousef",
              style: TextStyle(
                fontSize: 15,
              ),
            )
          ],
        ),
      )
    );
  }
}
