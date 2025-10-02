class StaffMember {
  const StaffMember({
    required this.id,
    required this.businessId,
    required this.name,
    this.skillServiceIds = const <String>[],
    this.photo,
    this.workingDays = const <int>[1, 2, 3, 4, 5],
    this.startHour = 9,
    this.endHour = 18,
    this.breaks = const <int>[12],
  });

  final String id;
  final String businessId;
  final String name;
  final List<String> skillServiceIds;
  final String? photo;
  final List<int> workingDays;
  final int startHour;
  final int endHour;
  final List<int> breaks;
}
