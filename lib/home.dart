import 'package:flutter/material.dart';
import 'package:flutter_complex_ui/custom_drawer.dart';
import 'package:flutter_complex_ui/flights_stepper.dart';

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complex UI"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const CustomDrawer();
                    },
                  ),
                );
              },
              icon: const Icon(Icons.new_releases_sharp),
              label: const Text("Custom Drawer"),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const FlightsStepper();
                    },
                  ),
                );
              },
              icon: const Icon(Icons.flight),
              label: const Text("Custom Drawer"),
            ),
          ],
        ),
      ),
    );
  }
}
