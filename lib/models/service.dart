class Service {
  final String id;
  final String businessId;
  final String name;
  final int durationMinutes;
  final double price;
  final List<String> addOns;
  final String description;
  final List<String> branches;

  const Service({
    this.id,
    this.businessId,
    this.name,
    this.durationMinutes = 60,
    this.price = 0,
    this.addOns = const <String>[],
    this.description,
    this.branches = const <String>[],
  });
}
