import 'package:flutter_app/config/app_config.dart';
import 'package:flutter_app/models/booking.dart';
import 'package:flutter_app/models/business.dart';
import 'package:flutter_app/models/service.dart';
import 'package:flutter_app/models/staff.dart';
import 'package:flutter_app/repositories/booking_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BookingRepository', () {
    final BookingRepository repository = BookingRepository();

    test('generates non-overlapping slots for staff', () {
      final Business business = repository.getBusinesses().first;
      final Service service = repository.getServicesForBusiness(business.id).first;
      final StaffMember staff = repository.getStaffForBusiness(business.id).first;

      final List<DateTime> slots = repository.generateSlots(
        forDate: DateTime.now(),
        business: business,
        service: service,
        staff: staff,
        branch: business.locations.first,
      );

      expect(slots, isNotEmpty);
      for (int i = 1; i < slots.length; i++) {
        final DateTime previousEnd =
            slots[i - 1].add(Duration(minutes: service.durationMinutes));
        expect(slots[i].isAfter(previousEnd) || slots[i].isAtSameMomentAs(previousEnd),
            isTrue);
      }
    });

    test('creates booking with calculated end time', () {
      final Business business = repository.getBusinesses().first;
      final BusinessLocation branch = business.locations.first;
      final Service service = repository.getServicesForBusiness(business.id).first;
      final DateTime start = DateTime(2023, 10, 10, 12, 0);

      final Booking booking = repository.createBooking(
        business: business,
        branch: branch,
        service: service,
        staff: null,
        start: start,
        notes: 'Test',
      );

      expect(booking.end.difference(start).inMinutes, service.durationMinutes);
      expect(booking.status, BookingStatus.confirmed);
      expect(booking.businessId, business.id);
    });

    test('slot generation respects booking mode flag', () {
      expect(AppConfig.isBookingMode, isTrue);
      final Business business = repository.getBusinesses().first;
      final Service service = repository.getServicesForBusiness(business.id).first;
      final List<DateTime> slots = repository.generateSlots(
        forDate: DateTime.now(),
        business: business,
        service: service,
        branch: business.locations.first,
      );
      expect(slots, isNotEmpty);
    });
  });
}
