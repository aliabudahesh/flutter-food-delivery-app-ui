import 'package:flutter_app/config/app_config.dart';
import 'package:flutter_app/data/sample_data.dart';
import 'package:flutter_app/models/booking.dart';
import 'package:flutter_app/models/business.dart';
import 'package:flutter_app/models/service.dart';
import 'package:flutter_app/models/staff.dart';

class BookingRepository {
  List<Business> getBusinesses() {
    final List<Business> businesses = SampleData.getBusinesses();
    final List<Service> services = SampleData.getServices();
    return businesses
        .map((Business business) => Business(
              id: business.id,
              name: business.name,
              types: business.types,
              description: business.description,
              photos: business.photos,
              locations: business.locations,
              workingHours: business.workingHours,
              rating: business.rating,
              ratingCount: business.ratingCount,
              services: services
                  .where((Service service) => service.businessId == business.id)
                  .toList(),
              staff: SampleData
                  .getStaff()
                  .where((StaffMember staff) => staff.businessId == business.id)
                  .toList(),
            ))
        .toList();
  }

  List<String> getBusinessTypes() {
    if (!AppConfig.isBookingMode) {
      return const <String>[];
    }

    final List<Business> businesses = getBusinesses();
    final Set<String> types = <String>{};
    for (final Business business in businesses) {
      types.addAll(business.types);
    }
    return types.toList();
  }

  List<Service> getServicesForBusiness(String businessId) {
    return SampleData
        .getServices()
        .where((Service service) => service.businessId == businessId)
        .toList();
  }

  List<StaffMember> getStaffForBusiness(String businessId) {
    if (!AppConfig.allowStaffSelection) {
      return const <StaffMember>[];
    }

    return SampleData
        .getStaff()
        .where((StaffMember staff) => staff.businessId == businessId)
        .toList();
  }

  List<Booking> getExistingBookings(String businessId, {String staffId}) {
    return SampleData.getExistingBookings().where((Booking booking) {
      if (booking.businessId != businessId) {
        return false;
      }
      if (staffId != null && staffId.isNotEmpty) {
        return booking.staffId == staffId;
      }
      return true;
    }).toList();
  }

  List<DateTime> generateSlots({
    DateTime forDate,
    Service service,
    StaffMember staff,
    Business business,
    BusinessLocation branch,
  }) {
    if (!AppConfig.isBookingMode || service == null || business == null) {
      return const <DateTime>[];
    }

    final int slotLength = AppConfig.slotLengthMinutes;
    final int duration = service.durationMinutes;
    final DateTime resolvedDate = forDate ?? DateTime.now();
    final DateTime targetDate =
        DateTime(resolvedDate.year, resolvedDate.month, resolvedDate.day);
    final int startHour = staff?.startHour ?? business.workingHours.startHour;
    final int endHour = staff?.endHour ?? business.workingHours.endHour;
    final List<int> breakHours = staff?.breaks ?? const <int>[];

    final List<Booking> existing = getExistingBookings(business.id, staffId: staff?.id)
        .where((Booking booking) =>
            booking.start.year == targetDate.year &&
            booking.start.month == targetDate.month &&
            booking.start.day == targetDate.day &&
            (branch == null || booking.branchId == branch.id))
        .toList();

    final List<DateTime> slots = <DateTime>[];
    DateTime current = DateTime(targetDate.year, targetDate.month, targetDate.day, startHour);
    final DateTime endOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day, endHour);

    while (current.isBefore(endOfDay)) {
      final DateTime slotEnd = current.add(Duration(minutes: duration));
      final bool inBreak = breakHours.contains(current.hour);
      final bool overlapsExisting = existing.any((Booking booking) {
        return current.isBefore(booking.end) && slotEnd.isAfter(booking.start);
      });

      if (!inBreak && !overlapsExisting && slotEnd.isBefore(endOfDay.add(const Duration(minutes: 1)))) {
        slots.add(current);
      }

      current = current.add(Duration(minutes: slotLength));
    }

    return slots;
  }

  Booking createBooking({
    String userId,
    Business business,
    BusinessLocation branch,
    Service service,
    StaffMember staff,
    DateTime start,
    String notes,
  }) {
    if (!AppConfig.isBookingMode || business == null || service == null || start == null) {
      throw ArgumentError('Invalid booking parameters');
    }

    final DateTime end = start.add(Duration(minutes: service.durationMinutes));
    final Booking booking = Booking(
      id: 'bk_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId ?? 'demo-user',
      businessId: business.id,
      branchId: branch?.id ?? business.locations.first.id,
      serviceId: service.id,
      staffId: staff?.id,
      start: start,
      end: end,
      price: service.price,
      status: BookingStatus.confirmed,
      notes: notes,
      createdAt: DateTime.now(),
    );

    return booking;
  }
}
