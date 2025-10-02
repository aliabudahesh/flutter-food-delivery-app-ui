import 'package:flutter/material.dart';
import 'package:flutter_app/config/app_config.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:flutter_app/models/booking_draft.dart';
import 'package:flutter_app/models/business.dart';
import 'package:flutter_app/models/service.dart';
import 'package:flutter_app/models/staff.dart';
import 'package:flutter_app/repositories/booking_repository.dart';

class FoodOrderPage extends StatefulWidget {
  const FoodOrderPage({super.key, this.bookingDraft});

  final BookingDraft? bookingDraft;

  @override
  State<FoodOrderPage> createState() => _FoodOrderPageState();
}

class _FoodOrderPageState extends State<FoodOrderPage> {
  final BookingRepository _repository = BookingRepository();
  bool _bookingConfirmed = false;

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.isBookingMode || widget.bookingDraft == null) {
      return _buildLegacyCart(context);
    }

    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final BookingDraft draft = widget.bookingDraft!;
    final Business business = draft.business!;
    final Service service = draft.service!;
    final BusinessLocation branch = draft.branch ??
        (business.locations.isNotEmpty
            ? business.locations.first
            : BusinessLocation(id: 'default', name: service.name));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF3a3737),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          localizations.translate('booking.summary.title'),
          style: const TextStyle(
              color: Color(0xFF3a3737),
              fontWeight: FontWeight.w600,
              fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _SummaryCard(
                title: localizations.translate('booking.summary.service'),
                value: localizations.translate(service.name),
              ),
              _SummaryCard(
                title: localizations.translate('booking.summary.branch'),
                value: localizations.translate(branch.name),
                subtitle: localizations.translate(branch.address ?? ''),
              ),
              if (draft.staff != null)
                _SummaryCard(
                  title: localizations.translate('booking.summary.staff'),
                  value: localizations.translate(draft.staff!.name),
                ),
              _SummaryCard(
                title: localizations.translate('booking.summary.time'),
                value: _formatDateTime(draft.start!, context),
              ),
              _SummaryCard(
                title: localizations.translate('booking.summary.price'),
                value: '${service.price.toStringAsFixed(0)} ₪',
              ),
              if (draft.notes?.isNotEmpty == true)
                _SummaryCard(
                  title: localizations.translate('booking.summary.notes'),
                  value: draft.notes,
                ),
              if (AppConfig.allowDeposit)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    localizations.translate('booking.deposit.note'),
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6e6e71),
                        fontWeight: FontWeight.w400),
                  ),
                ),
              const SizedBox(height: 20),
              if (_bookingConfirmed)
                _SuccessBanner(
                  message: localizations.translate('booking.summary.completed'),
                ),
              const SizedBox(height: 10),
              _buildActionButtons(localizations, draft,
                  business: business, branch: branch, service: service),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations localizations, BookingDraft draft,
      {required Business business,
      required BusinessLocation branch,
      required Service service}) {
    final StaffMember? staff = draft.staff;
    final DateTime start = draft.start!;
    return Column(
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFfb3132), // replaces color:
                foregroundColor: Colors.white, // replaces textColor:
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                )),
            onPressed: () {
              _repository.createBooking(
                business: business,
                branch: branch,
                service: service,
                staff: staff,
                start: start,
                notes: draft.notes,
              );
              setState(() {
                _bookingConfirmed = true;
              });
              debugPrint(
                  '[analytics] booking_confirmed:${service.id}:${start.toIso8601String()}');
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    Text(localizations.translate('booking.summary.success')),
              ));
            },
            child: Text(localizations.translate('booking.button.confirm')),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side:
                  const BorderSide(color: Color(0xFFfb3132)), // was borderSide:
              foregroundColor: const Color(0xFFfb3132), // was textColor:
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              final String ics = _generateIcsContent(draft);
              showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(localizations
                        .translate('booking.summary.add_to_calendar')),
                    content: SingleChildScrollView(
                      child: SelectableText(ics),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(localizations.translate('booking.alert.added')),
              ));
            },
            child: Text(
                localizations.translate('booking.summary.add_to_calendar')),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime time, BuildContext context) {
    final MaterialLocalizations materialLocalizations =
        MaterialLocalizations.of(context);
    return '${materialLocalizations.formatMediumDate(time)} · ${materialLocalizations.formatTimeOfDay(TimeOfDay.fromDateTime(time))}';
  }

  String _generateIcsContent(BookingDraft draft) {
    final Service service = draft.service!;
    final DateTime start = draft.start!;
    final DateTime end = start.add(Duration(minutes: service.durationMinutes));
    final String location = draft.branch?.name ?? service.name;
    return 'BEGIN:VCALENDAR\nVERSION:2.0\nBEGIN:VEVENT\nSUMMARY:${service.name}\nDTSTART:${_formatIcsDate(start)}\nDTEND:${_formatIcsDate(end)}\nLOCATION:$location\nDESCRIPTION:${draft.notes ?? ''}\nEND:VEVENT\nEND:VCALENDAR';
  }

  String _formatIcsDate(DateTime date) {
    final String iso = date
        .toUtc()
        .toIso8601String()
        .replaceAll('-', '')
        .replaceAll(':', '')
        .replaceAll('Z', '');
    return iso.split('.').first;
  }

  Widget _buildLegacyCart(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFFAFAFA),
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF3a3737),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Center(
            child: Text(
              "Item Carts",
              style: TextStyle(
                  color: Color(0xFF3a3737),
                  fontWeight: FontWeight.w600,
                  fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          actions: <Widget>[
            CartIconWithBadge(),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 5),
                  child: Text(
                    "Your Food Cart",
                    style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF3a3a3b),
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                CartItem(
                    productName: "Grilled Salmon",
                    productPrice: "\$96.00",
                    productImage: "ic_popular_food_1",
                    productCartQuantity: "2"),
                SizedBox(
                  height: 10,
                ),
                CartItem(
                    productName: "Meat vegetable",
                    productPrice: "\$65.08",
                    productImage: "ic_popular_food_4",
                    productCartQuantity: "5"),
                SizedBox(
                  height: 10,
                ),
                PromoCodeWidget(),
                SizedBox(
                  height: 10,
                ),
                TotalCalculationWidget(),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.only(left: 5),
                  child: Text(
                    "Payment Method",
                    style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF3a3a3b),
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                PaymentMethodWidget(),
              ],
            ),
          ),
        ));
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({super.key, this.title, this.value, this.subtitle});

  final String? title;
  final String? value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Color(0xFFfae3e2).withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 1,
          offset: Offset(0, 1),
        ),
      ]),
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title ?? '',
                style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF3a3a3b),
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                value ?? '',
                style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6e6e71),
                    fontWeight: FontWeight.w400),
              ),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 2),
                Text(
                  subtitle ?? '',
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFa4a1a1),
                      fontWeight: FontWeight.w400),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFe8f5e9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.check_circle, color: Color(0xFF2e7d32)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message ?? '',
              style: const TextStyle(
                  color: Color(0xFF2e7d32), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// Legacy widgets retained for food ordering experience
class PaymentMethodWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Color(0xFFfae3e2).withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 1,
          offset: Offset(0, 1),
        ),
      ]),
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: 10, right: 30, top: 10, bottom: 10),
          child: Row(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/images/menus/ic_credit_card.png",
                  width: 50,
                  height: 50,
                ),
              ),
              Text(
                "Credit/Debit Card",
                style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF3a3a3b),
                    fontWeight: FontWeight.w400),
                textAlign: TextAlign.left,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TotalCalculationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Color(0xFFfae3e2).withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 1,
          offset: Offset(0, 1),
        ),
      ]),
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: 25, right: 30, top: 10, bottom: 10),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Grilled Salmon",
                    style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF3a3a3b),
                        fontWeight: FontWeight.w400),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    "\$96.00",
                    style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF3a3a3b),
                        fontWeight: FontWeight.w400),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Meat vegetable",
                    style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF3a3a3b),
                        fontWeight: FontWeight.w400),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    "\$65.08",
                    style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF3a3a3b),
                        fontWeight: FontWeight.w400),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Total",
                    style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF3a3a3b),
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    "\$161.08",
                    style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF3a3a3b),
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PromoCodeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Color(0xFFfae3e2).withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 1,
          offset: Offset(0, 1),
        ),
      ]),
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: 10, right: 30, top: 10, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Have a promocode?",
                style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF3a3a3b),
                    fontWeight: FontWeight.w400),
                textAlign: TextAlign.left,
              ),
              Text(
                "Apply",
                style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFfb3132),
                    fontWeight: FontWeight.w400),
                textAlign: TextAlign.left,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CartItem extends StatefulWidget {
  const CartItem({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.productCartQuantity,
  });

  final String productName;
  final String productPrice;
  final String productImage;
  final String productCartQuantity;

  @override
  _CartItemState createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: 105,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Color(0xFFfae3e2).withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 1,
          offset: Offset(0, 1),
        ),
      ]),
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
          child: Row(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 10),
                child: Image.asset(
                  "assets/images/popular_foods/${widget.productImage}.png",
                  width: 90,
                  height: 80,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(
                      widget.productName,
                      style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF3a3a3b),
                          fontWeight: FontWeight.w400),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      widget.productPrice,
                      style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF3a3a3b),
                          fontWeight: FontWeight.w400),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.center,
                width: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(
                      "-",
                      style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF000000),
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      widget.productCartQuantity,
                      style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF000000),
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      "+",
                      style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF000000),
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CartIconWithBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Stack(
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.shopping_cart,
              color: Color(0xFFfb3132),
            ),
            onPressed: () {},
          ),
          Positioned(
            right: 7,
            top: 7,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                  color: Color(0xFFfb3132),
                  borderRadius: BorderRadius.circular(50)),
              child: Center(
                child: Text(
                  "1",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
