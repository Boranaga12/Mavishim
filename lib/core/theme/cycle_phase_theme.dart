import 'package:flutter/material.dart';

import '../utils/cycle_calculator.dart';
import 'app_theme.dart';

extension CyclePhaseTheme on CycleInfo {
  Color get phaseColor {
    switch (currentPhase) {
      case CyclePhase.period:
        return AppTheme.periodColor;
      case CyclePhase.follicular:
        return AppTheme.follicularColor;
      case CyclePhase.ovulation:
        return AppTheme.ovulationColor;
      case CyclePhase.luteal:
        return AppTheme.lutealColor;
      case CyclePhase.late:
        return const Color(0xFFE63946);
      case CyclePhase.noData:
        return Colors.grey;
    }
  }
}
