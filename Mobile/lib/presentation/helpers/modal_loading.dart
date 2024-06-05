import 'package:flutter/material.dart';
import 'package:vision_aid/presentation/components/components.dart';
import 'package:vision_aid/presentation/themes/colors.dart';

void modalLoading(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.white54,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      content: Container(
        height: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                TextCustom(
                    text: 'Vision ',
                    color: ColorsEnum.primaryColor,
                    fontWeight: FontWeight.w500),
                TextCustom(text: 'Aid', fontWeight: FontWeight.w500),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10.0),
            Row(
              children: const [
                CircularProgressIndicator(color: ColorsEnum.primaryColor),
                SizedBox(width: 15.0),
                TextCustom(text: 'Loading...')
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
