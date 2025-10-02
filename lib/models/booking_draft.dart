import 'package:flutter_app/models/business.dart';
import 'package:flutter_app/models/service.dart';
import 'package:flutter_app/models/staff.dart';

class BookingDraft {
  BookingDraft({
    this.business,
    this.branch,
    this.service,
    this.staff,
    this.start,
    this.notes,
  });

  final Business? business;
  final BusinessLocation? branch;
  final Service? service;
  final StaffMember? staff;
  final DateTime? start;
  final String? notes;
}
