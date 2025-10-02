# Flutter Food Delivery Application Design

## This application is not completed yet. Currently, I am working on it. 
A small attempt to make an Food delivery app user interface in Flutter for Android and iOS.

## 🤓 Author(s)
**Md Tarikul Islam** [![Twitter Follow](https://img.shields.io/twitter/follow/tarikul711.svg?style=social)](https://twitter.com/tarikul711)

## Food Ordering & Delivery App UI in Flutter
<img src="screens/full_ui.png"  />

## ScreenShots
### Home Page
<img src="screens/home_screen.jpg" height="500em" />

### Food Details Screen & Add To Cart Screen
<img src="screens/detail_screen.jpg" height="500em" /> &nbsp;&nbsp;&nbsp;&nbsp; <img src="screens/add_to_cart_screen.jpg" height="500em" />

### Login & Registration Screen
<img src="screens/login_screen.jpg" height="500em" />&nbsp;&nbsp;&nbsp;&nbsp; <img src="screens/signin_scren.jpg" height="500em" />

## ✨ Requirements
* Any Operating System (ie. MacOS X, Linux, Windows)
* Any IDE with Flutter SDK installed (ie.  Android Studio, VSCode, IntelliJ, etc)
* A little knowledge of Dart and Flutter
* A brain to think 🤓🤓

## Booking Mode

This repository now supports a multi-business booking experience that reuses the
original food delivery layout and theme. The active mode is controlled by the
`APP_MODE` flag inside `lib/config/app_config.dart`.

| Flag | Description | Default |
| ---- | ----------- | ------- |
| `APP_MODE` | Switch between `food` and `booking` experiences. | `booking` |
| `ALLOW_DEPOSIT` | Enables optional deposit messaging at checkout. | `false` |
| `ALLOW_STAFF_SELECTION` | Toggle manual staff selection in the booking flow. | `true` |
| `SLOT_LENGTH_MINUTES` | Base slot size used for availability calculations. | `30` |

### Running in booking mode

```bash
flutter pub get
flutter run
```

Switch back to the food experience by editing `appMode` in
`lib/config/app_config.dart` and hot-restarting the app.

## Data Seeding & Migration

The `tools/seed_booking.dart` script converts legacy menu JSON into booking
services by inferring duration from name patterns. Example:

```bash
printf '[{"name":"Relax massage 60 min","price":280}]' | dart tools/seed_booking.dart
```

Sample businesses, staff, and services are defined in `lib/data/sample_data.dart`
and power the demo flow.

## Tests

Run the new booking-focused test suites:

```bash
flutter test test/booking_repository_test.dart
flutter test test/booking_widgets_test.dart
```

Both tests rely on the booking mode being active via `APP_MODE = 'booking'`.


