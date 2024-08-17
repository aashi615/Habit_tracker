import 'package:flutter/material.dart';
import 'package:habit_tracker/pages/Login_Page.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0f7fa), Color(0xFF0288d1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: Image.asset('assets/images/Checklist.png'),
              height: 300,
              width: 320,
            ),
            SizedBox(height: 35),
            Text(
              'Track your Daily activities and increase productivity',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            Text(
              'Build some good habits with us',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 65),
            SliderWidget(),
          ],
        ),
      ),
    );
  }
}

class SliderWidget extends StatefulWidget {
  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  double _sliderValue = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Stack(
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white60,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_sliderValue < 1)
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Image.asset('assets/images/3arrows.png',color: Color.fromRGBO(
                        53, 160, 216, 1.0),
                    height: 50,
                    )
                  ),
              ],
            ),
          ),
          Positioned.fill(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: CustomSliderThumbCircle(
                  thumbRadius: 30,
                  min: 0,
                  max: 1,
                ),
                trackHeight: 0,
                activeTrackColor: Colors.transparent,
                inactiveTrackColor: Colors.transparent,
              ),
              child: Slider(
                value: _sliderValue,
                min: 0,
                max: 1,
                onChanged: (value) {
                  setState(() {
                    _sliderValue = value;
                  });
                },
                onChangeEnd: (value) {
                  if (value == 1) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomSliderThumbCircle extends SliderComponentShape {
  final double thumbRadius;
  final double min;
  final double max;

  const CustomSliderThumbCircle({
    required this.thumbRadius,
    required this.min,
    required this.max,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, thumbRadius, paint);
    final borderPaint = Paint()
      ..color = Color.fromRGBO(20, 144, 210, 1.0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, thumbRadius, borderPaint);

    TextSpan span = new TextSpan(
      style: new TextStyle(
        fontSize: thumbRadius * 0.6,
        fontWeight: FontWeight.bold,
        color: Color.fromRGBO(20, 144, 210, 1.0),
      ),
      text: 'Start',
    );

    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(
        canvas,
        new Offset(center.dx - (tp.width / 2),
            center.dy - (tp.height / 2)));
  }
}


