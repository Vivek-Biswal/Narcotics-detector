enum TestResult { positive, negative, inconclusive }

extension TestResultExtension on TestResult {
  String get label {
    switch (this) {
      case TestResult.positive:
        return 'POSITIVE';
      case TestResult.negative:
        return 'NEGATIVE';
      case TestResult.inconclusive:
        return 'INCONCLUSIVE';
    }
  }

  String get description {
    switch (this) {
      case TestResult.positive:
        return 'Controlled substance detected';
      case TestResult.negative:
        return 'No controlled substance detected';
      case TestResult.inconclusive:
        return 'Unable to determine — retest required';
    }
  }
}

enum VerificationStatus { verified, pending, failed }

extension VerificationStatusExtension on VerificationStatus {
  String get label {
    switch (this) {
      case VerificationStatus.verified:
        return 'VERIFIED';
      case VerificationStatus.pending:
        return 'PENDING';
      case VerificationStatus.failed:
        return 'FAILED';
    }
  }
}

enum DetectionState {
  idle,
  detecting,
  detected,
  notDetected,
  poorLighting,
  invalidImage,
}

enum CalibrationStep {
  detectingCard,
  normalizingColour,
  detectingTestArea,
  analysingColour,
  preparingResult,
}

extension CalibrationStepExtension on CalibrationStep {
  String get label {
    switch (this) {
      case CalibrationStep.detectingCard:
        return 'Detecting reference card';
      case CalibrationStep.normalizingColour:
        return 'Normalizing colour channels';
      case CalibrationStep.detectingTestArea:
        return 'Detecting test area';
      case CalibrationStep.analysingColour:
        return 'Analysing colour response';
      case CalibrationStep.preparingResult:
        return 'Preparing result';
    }
  }
}

enum CaptureState {
  idle,
  previewing,
  captured,
  qualityWarning,
  cardNotDetected,
}
