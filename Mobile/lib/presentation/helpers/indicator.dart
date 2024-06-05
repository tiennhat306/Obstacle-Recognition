import 'package:flutter/material.dart';
import 'package:vision_aid/presentation/themes/colors.dart';

class IndicatorTabBar extends Decoration {
  
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _PainterIndicator(this, onChanged);

}



class _PainterIndicator extends BoxPainter {

  final IndicatorTabBar decoration;

  _PainterIndicator(this.decoration, VoidCallback? onChanged) : super(onChanged);
  

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {

    Rect rect;

    rect = Offset(offset.dx + 6, ( configuration.size!.height - 3 )) & Size(configuration.size!.width - 12, 3);

    final paint = Paint()
      ..color = ColorsEnum.primaryColor
      ..style = PaintingStyle.fill;

    canvas.drawRRect(RRect.fromRectAndCorners(rect, topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0)), paint);


  }



}