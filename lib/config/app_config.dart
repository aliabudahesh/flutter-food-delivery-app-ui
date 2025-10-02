class AppConfig {
  static const String appMode = 'booking';
  static const bool allowDeposit = false;
  static const bool allowStaffSelection = true;
  static const int slotLengthMinutes = 30;

  static bool get isBookingMode => appMode == 'booking';
}
