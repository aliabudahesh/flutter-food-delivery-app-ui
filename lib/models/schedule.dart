class ScheduleDay {
  final DateTime date;
  final List<DateTime> availableSlots;

  const ScheduleDay({
    this.date,
    this.availableSlots = const <DateTime>[],
  });
}
