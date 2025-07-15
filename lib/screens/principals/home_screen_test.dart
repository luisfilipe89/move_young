import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: const [
          _FigmaStyledHomeContent(),
        ],
      ),
    );
  }
}

class _FigmaStyledHomeContent extends StatelessWidget {
  const _FigmaStyledHomeContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 415,
      height: 922,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0x19000000),
            blurRadius: 100,
            offset: const Offset(0, 40),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 415,
              height: 922,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(60),
                ),
              ),
            ),
          ),

          // Find your activity
          const Positioned(
            left: 39,
            top: 137,
            child: Text(
              'Find your',
              style: TextStyle(
                color: Colors.black,
                fontSize: 50,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const Positioned(
            left: 39,
            top: 202,
            child: Text(
              'activity',
              style: TextStyle(
                color: Colors.black,
                fontSize: 50,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Popular Tabs
          const Positioned(
            left: 36,
            top: 311,
            child: Text(
              'Popular',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const Positioned(
            left: 132,
            top: 311,
            child: Opacity(
              opacity: 0.5,
              child: Text(
                'Moderate',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const Positioned(
            left: 245,
            top: 311,
            child: Opacity(
              opacity: 0.5,
              child: Text(
                'Intensive',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          // Swimming card
          Positioned(
            left: 36,
            top: 365,
            child: Container(
              width: 341,
              height: 198,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: NetworkImage("https://placehold.co/341x198"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const Positioned(
            left: 48,
            top: 527,
            child: Text(
              'Swimming',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Positioned(
            left: 294,
            top: 531,
            child: Opacity(
              opacity: 0.5,
              child: Text(
                '430Kcal/hr',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          // Tennis card
          Positioned(
            left: 45,
            top: 575,
            child: Container(
              width: 341,
              height: 198,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: NetworkImage("https://placehold.co/341x198"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const Positioned(
            left: 48,
            top: 748,
            child: Text(
              'Playing Tenis',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Positioned(
            left: 294,
            top: 753,
            child: Opacity(
              opacity: 0.5,
              child: Text(
                '430Kcal/hr',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
