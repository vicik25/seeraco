import 'package:flutter/material.dart';

import '../theme/seera_colors.dart';

class OrderProgressStepper extends StatelessWidget {
  const OrderProgressStepper({super.key, required this.activeStep});

  final int activeStep;

  @override
  Widget build(BuildContext context) {
    const labels = ['Data', 'Bayar', 'Selesai'];

    return Row(
      children: [
        for (var index = 0; index < labels.length; index++) ...[
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index <= activeStep
                        ? SeeraColors.pinkPop
                        : SeeraColors.pinkSoft,
                  ),
                  child: index < activeStep
                      ? const Icon(Icons.check, size: 17, color: Colors.white)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: index == activeStep
                                ? Colors.white
                                : SeeraColors.greyMauve,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[index],
                  style: TextStyle(
                    color: index <= activeStep
                        ? SeeraColors.pinkDeep
                        : SeeraColors.greyMauve,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (index < labels.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 20),
                color: index < activeStep
                    ? SeeraColors.pinkPop
                    : SeeraColors.pinkSoft,
              ),
            ),
        ],
      ],
    );
  }
}
