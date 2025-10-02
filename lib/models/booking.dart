enum BookingStatus { pending, confirmed, cancelled, completed, noShow }

class Booking {
  final String id;
  final String userId;
  final String businessId;
  final String branchId;
  final String serviceId;
  final String staffId;
  final DateTime start;
  final DateTime end;
  final double price;
  final BookingStatus status;
  final String notes;
  final DateTime createdAt;

  const Booking({
    this.id,
    this.userId,
    this.businessId,
    this.branchId,
    this.serviceId,
    this.staffId,
    this.start,
    this.end,
    this.price,
    this.status = BookingStatus.pending,
    this.notes,
    this.createdAt,
  });
}
