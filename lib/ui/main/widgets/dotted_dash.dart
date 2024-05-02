import 'package:flutter/material.dart';
import 'package:warung_mini_tab/common/my_colors.dart';

class DottedDash extends StatelessWidget {
  final double boxWidth;
  final int? rowCount;
  const DottedDash({super.key, required this.boxWidth, this.rowCount = 1});

  @override
  Widget build(BuildContext context) {
    const dashWidth = 5.0;
    double dashHeight = 1;
    final dashCount = (boxWidth / (2 * dashWidth)).floor();

    List<Widget> items() {
      List<Widget> ele = [];
      for (var i = 0; i < rowCount!; i++) {
        ele.add(Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 2),
              width: dashWidth,
              height: dashHeight,
              child: const DecoratedBox(
                decoration: BoxDecoration(color: colorBlack100),
              ),
            );
          }),
        ));
      }
      return ele;
    }

    return Column(mainAxisSize: MainAxisSize.min, children: items());
  }
}
