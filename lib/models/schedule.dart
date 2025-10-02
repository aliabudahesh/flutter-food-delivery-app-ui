class ScheduleDay {
  final DateTime date;
  final List<DateTime> availableSlots;

  const ScheduleDay({
    required this.date,
    this.availableSlots = const <DateTime>[],
  });
}
