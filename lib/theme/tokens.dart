import 'package:flutter/material.dart';

class AppColors {
  static const white = Color(0xFFFFFFFF);
  static const superlightgrey = Color(0xFFEEEEEE);
  static const lightgrey = Color(0xFFEEEEEE); //Grey[300]
  static const grey = Color(0xFF9E9E9E); //Grey[500]
  static const darkgrey = Color(0xFF616161); //Grey[700]
  static const blackTransparent = Color(0x26000000);
  static const black = Color(0x1F000000); //Black12
  static const blackText = Color(0xDD000000); //Black87
  static const blackopac = Color(0x99000000); //black54
  static const blackShadow = Color(0x33000000);
  static const lightblackShadow = Color(0x26000000);
  static const blackIcon = Color(0xFF000000);
  static const blue = Color(0xFF2196F3);
  static const red = Color(0xFFF44336);
  static const orange = Color(0xFFFF9800);
  static const green = Color(0xFF4CAF50);
  static const lightamber = Color(0xFFFFE082);
  static const amber = Color(0xFFFFC107);
}

class AppRadius {
  static const smallCard = 8.0;
  static const image = 12.0;
  static const card = 16.0; // used for tiles, list items
  static const container = 20.0;
  static const bigContainer = 24.0; // used for main content blocks
}

class AppSpacing {
  static const content = 12.0; // content padding (inner text, compact tiles)
}

class AppHeights {
  static const superSmall = 2.0;
  static const small = 4.0;
  static const reg = 8.0;
  static const big = 12.0;
  static const superbig = 16.0;
  static const huge = 20.0;
  static const superHuge = 24.0;
  static const image = 140.0;
  static double cardImage(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final target = width * 0.28; // around 28% of screen width
    return target.clamp(
        110.0, 170.0); // never smaller than 110, never taller than 170
  }
}

class AppWidths {
  static const small = 4.0;
  static const regular = 8.0;
  static const big = 12.0;
  static const superbig = 16.0;
  static const huge = 20.0;
}

class AppPaddings {
  //Symmetric Horizontal + Vertical
  static const symmSuperSmall =
      EdgeInsets.symmetric(horizontal: 4, vertical: 2);
  static const symmSmall = EdgeInsets.symmetric(horizontal: 8, vertical: 4);
  static const symmReg = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const symmSpecial = EdgeInsets.symmetric(horizontal: 4, vertical: 8);
  //Symmetric Horizontal
  static const symmHorizontalMedium = EdgeInsets.symmetric(horizontal: 12);
  static const symmHorizontalReg = EdgeInsets.symmetric(horizontal: 16);
  static const symmHorizontalBig = EdgeInsets.symmetric(horizontal: 24);
  //Symmetrical Vertical
  static const symmVerticalSmall = EdgeInsets.symmetric(vertical: 8);
  //All
  static const allSmall = EdgeInsets.all(8);
  static const allMedium = EdgeInsets.all(12);
  static const allReg = EdgeInsets.all(16);
  static const allBig = EdgeInsets.all(20);
  static const allSuperBig = EdgeInsets.all(24);
  //Only top
  static const topSuperSmall = EdgeInsets.only(top: 4);
  static const topSmall = EdgeInsets.only(top: 6);

  //Only top + bottom
  static const topBottom = EdgeInsets.only(top: 4, bottom: 12);

  //Only right
  static const rightSmall = EdgeInsets.only(right: 8);
  static const rightSuperBig = EdgeInsets.only(right: 24);
}

class AppShadows {
  static const md = [
    BoxShadow(
      color: AppColors.blackTransparent,
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];
  static const mdBlurred = [
    BoxShadow(
      color: AppColors.blackTransparent,
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];
}

class AppTextStyles {
  static const huge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w300,
  );

  static const title = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 20,
    fontWeight: FontWeight.w500, // nice semi-bold
    color: AppColors.blackText, // 87% black
    letterSpacing: 0.15,
  );

  static const headline = TextStyle(
      fontFamily: 'Roboto',
      fontSize: 22,
      fontWeight: FontWeight.w400,
      height: 1.4);

  static const special = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.blackopac,
      fontFamily: 'Roboto');

  static const cardTitle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: AppColors.blackText,
  );

  static const cardTitleMuted = TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.grey);

  static const body = TextStyle(
    fontSize: 14,
  );

  static const bodyMuted = TextStyle(
      fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.grey);

  static const small = TextStyle(
    fontSize: 13,
  );
  static const smallMuted = TextStyle(fontSize: 13, color: AppColors.grey);
  static const supersmall = TextStyle(
    fontSize: 10,
  );
}
