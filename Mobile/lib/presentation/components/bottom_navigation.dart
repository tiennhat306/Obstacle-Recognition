import 'package:flutter/material.dart';
import 'package:vision_aid/presentation/components/components.dart';
import 'package:vision_aid/presentation/screens/client/home_screen.dart';
import 'package:vision_aid/presentation/screens/client/profile_screen.dart';
import 'package:vision_aid/presentation/themes/colors.dart';

class BottomNavigation extends StatelessWidget {
  final int index;

  BottomNavigation(this.index);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(color: Colors.grey, blurRadius: 10, spreadRadius: -5)
        ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ItemButton(
              i: 0,
              index: index,
              iconData: Icons.home_outlined,
              text: 'Home',
              onPressed: () => Navigator.pushReplacement(
                  context, routeCustom(page: HomeScreen())),
            ),
            _ItemButton(
              i: 1,
              index: index,
              iconData: Icons.person_outline_outlined,
              text: 'Profile',
              onPressed: () => Navigator.pushReplacement(
                  context, routeCustom(page: ProfileScreen())),
            ),
          ],
        ));
  }
}

class _ItemButton extends StatelessWidget {
  final int i;
  final int index;
  final IconData iconData;
  final String text;
  final VoidCallback? onPressed;

  const _ItemButton(
      {required this.i,
      required this.index,
      required this.iconData,
      required this.text,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 7.0),
        decoration: BoxDecoration(
            color: (i == index)
                ? ColorsEnum.primaryColor.withOpacity(.9)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(15.0)),
        child: (i == index)
            ? Row(
                children: [
                  Icon(iconData, color: Colors.white, size: 25),
                  const SizedBox(width: 6.0),
                  TextCustom(
                      text: text,
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.w500)
                ],
              )
            : Icon(iconData, size: 28),
      ),
    );
  }
}
