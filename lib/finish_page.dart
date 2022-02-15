import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FinishPage extends StatelessWidget {
  const FinishPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/Collaboration-rafiki.svg', height: 300),
            const Text(
              'App is ready!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            const Text('App can run normally now',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                )),
            const SizedBox(
              height: 32,
            ),
            SizedBox(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.teal,
                    ),
                    onPressed: () {},
                    child: const Text('Finish',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        )))),
          ],
        ),
      ),
    );
  }
}
