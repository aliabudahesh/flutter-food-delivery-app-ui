enum BookingStatus { pending, confirmed, cancelled, completed, noShow }

class Booking {
  const Booking({
    required this.id,
    required this.userId,
    required this.businessId,
    required this.branchId,
    required this.serviceId,
    this.staffId,
    required this.start,
    required this.end,
    required this.price,
    this.status = BookingStatus.pending,
    this.notes,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String businessId;
  final String branchId;
  final String serviceId;
  final String? staffId;
  final DateTime start;
  final DateTime end;
  final double price;
  final BookingStatus status;
  final String? notes;
  final DateTime createdAt;
}
