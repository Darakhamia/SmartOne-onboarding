enum StepStatus { completed, current, locked }

class OnboardingStep {
  final int index;
  final String name;
  final String description;
  StepStatus status;
  DateTime? completedAt;

  OnboardingStep({
    required this.index,
    required this.name,
    required this.description,
    required this.status,
    this.completedAt,
  });

  bool get isCompleted => status == StepStatus.completed;
  bool get isCurrent => status == StepStatus.current;
  bool get isLocked => status == StepStatus.locked;

  String get statusIcon {
    switch (status) {
      case StepStatus.completed:
        return '✓';
      case StepStatus.current:
        return '⏳';
      case StepStatus.locked:
        return '🔒';
    }
  }

  String get statusLabel {
    switch (status) {
      case StepStatus.completed:
        return 'Completed';
      case StepStatus.current:
        return 'In Progress';
      case StepStatus.locked:
        return 'Pending';
    }
  }

  OnboardingStep copyWith({StepStatus? status, DateTime? completedAt}) {
    return OnboardingStep(
      index: index,
      name: name,
      description: description,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'index': index,
      'name': name,
      'description': description,
      'status': status.index,
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}
