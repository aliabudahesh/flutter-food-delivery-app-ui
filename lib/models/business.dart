import 'package:flutter_app/models/service.dart';
import 'package:flutter_app/models/staff.dart';

class BusinessLocation {
  final String id;
  final String name;
  final String address;
  final String phone;

  const BusinessLocation({
    this.id,
    this.name,
    this.address,
    this.phone,
  });
}

class WorkingHours {
  final int startHour;
  final int endHour;
  final List<int> closedWeekdays;

  const WorkingHours({
    this.startHour = 9,
    this.endHour = 18,
    this.closedWeekdays = const <int>[]
  });
}

class Business {
  final String id;
  final String name;
  final List<String> types;
  final String description;
  final List<String> photos;
  final List<BusinessLocation> locations;
  final WorkingHours workingHours;
  final double rating;
  final int ratingCount;
  final List<Service> services;
  final List<StaffMember> staff;

  const Business({
    this.id,
    this.name,
    this.types = const <String>[],
    this.description,
    this.photos = const <String>[],
    this.locations = const <BusinessLocation>[],
    this.workingHours = const WorkingHours(),
    this.rating = 0,
    this.ratingCount = 0,
    this.services = const <Service>[],
    this.staff = const <StaffMember>[],
  });
}
