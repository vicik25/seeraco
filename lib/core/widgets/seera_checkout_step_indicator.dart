import 'package:flutter/material.dart';

import '../theme/seera_colors.dart';

class SeeraCheckoutStepIndicator extends StatelessWidget {
  const SeeraCheckoutStepIndicator({required this.activeStep, super.key});

  final int activeStep;

  @override
  Widget build(BuildContext context) {
    const steps = ['Data Pembeli', 'Pembayaran'];
    return Row(
      children: [
        for (var index = 0; index < steps.length; index++) ...[
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: index == activeStep ? SeeraColors.pinkDeep : Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: index == activeStep ? SeeraColors.pinkDeep : SeeraColors.pinkSoft),
                boxShadow: index == activeStep
                    ? const [BoxShadow(color: SeeraColors.pinkShadow, blurRadius: 12, offset: Offset(0, 4))]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: index == activeStep ? Colors.white : SeeraColors.pinkMist,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: index == activeStep ? SeeraColors.pinkDeep : SeeraColors.greyMauve,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      steps[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: index == activeStep ? Colors.white : SeeraColors.greyMauve,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (index < steps.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}
