import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/config/app_config.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:flutter_app/models/business.dart';
import 'package:flutter_app/models/booking_draft.dart';
import 'package:flutter_app/models/service.dart';
import 'package:flutter_app/models/staff.dart';
import 'package:flutter_app/pages/FoodOrderPage.dart';
import 'package:flutter_app/repositories/booking_repository.dart';

class FoodDetailsPage extends StatefulWidget {
  const FoodDetailsPage({Key key, this.business, this.service}) : super(key: key);

  final Business business;
  final Service service;

  @override
  _FoodDetailsPageState createState() => _FoodDetailsPageState();
}

class _FoodDetailsPageState extends State<FoodDetailsPage> {
  final BookingRepository _repository = BookingRepository();
  final TextEditingController _notesController = TextEditingController();

  Business _business;
  Service _service;
  BusinessLocation _selectedBranch;
  StaffMember _selectedStaff;
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedSlot;
  List<DateTime> _slots = <DateTime>[];

  @override
  void initState() {
    super.initState();
    if (AppConfig.isBookingMode) {
      _initializeBookingContext();
    }
  }

  void _initializeBookingContext() {
    final List<Business> businesses = _repository.getBusinesses();
    _business = widget.business ?? (businesses.isNotEmpty ? businesses.first : null);
    if (_business == null) {
      return;
    }

    final List<Service> services =
        _repository.getServicesForBusiness(_business.id);
    _service = widget.service ?? (services.isNotEmpty ? services.first : null);
    _selectedBranch =
        _business.locations.isNotEmpty ? _business.locations.first : null;
    if (AppConfig.allowStaffSelection) {
      final List<StaffMember> staff = _repository.getStaffForBusiness(_business.id);
      _selectedStaff = staff.isNotEmpty ? staff.first : null;
    }
    _refreshSlots();
  }

  void _refreshSlots() {
    if (_business == null || _service == null) {
      setState(() {
        _slots = <DateTime>[];
        _selectedSlot = null;
      });
      return;
    }
    final List<DateTime> generated = _repository.generateSlots(
      forDate: _selectedDate,
      service: _service,
      staff: _selectedStaff,
      business: _business,
      branch: _selectedBranch,
    );
    setState(() {
      _slots = generated;
      if (!_slots.contains(_selectedSlot)) {
        _selectedSlot = null;
      }
    });
  }

  List<StaffMember> get _availableStaff =>
      _business == null ? <StaffMember>[] : _repository.getStaffForBusiness(_business.id);

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.isBookingMode) {
      return _buildLegacyFoodDetails(context);
    }

    final AppLocalizations localizations = AppLocalizations.of(context);
    final String serviceName =
        _service != null ? localizations.translate(_service.name) : '';
    final String businessName = _business != null
        ? localizations.translate(_business.name ?? '')
        : '';

    return Scaffold(
      backgroundColor: Colors.white,
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
        title: Text(localizations.translate('booking.select_service'),
            style: const TextStyle(
                color: Color(0xFF3a3737),
                fontSize: 16,
                fontWeight: FontWeight.w500)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeroImage(),
            const SizedBox(height: 10),
            _BookingTitle(
              title: serviceName,
              price: _service != null
                  ? '${_service.price.toStringAsFixed(0)} ₪'
                  : '',
              businessName: businessName,
              duration: _service?.durationMinutes ?? AppConfig.slotLengthMinutes,
            ),
            const SizedBox(height: 10),
            _buildDescriptionCard(localizations),
            const SizedBox(height: 10),
            _buildBranchSelector(localizations),
            if (AppConfig.allowStaffSelection)
              _buildStaffSelector(localizations),
            _buildDateSelector(localizations),
            _buildSlots(localizations),
            _buildNotesField(localizations),
            const SizedBox(height: 20),
            _buildContinueButton(localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    final String fallback = 'assets/images/bestfood/ic_best_food_8.jpeg';
    final String imagePath = _business?.photos?.isNotEmpty == true
        ? _business.photos.first
        : fallback;
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 1,
      margin: EdgeInsets.zero,
    );
  }

  Widget _buildDescriptionCard(AppLocalizations localizations) {
    final String description = _service != null
        ? localizations.translate(_service.description ?? '')
        : '';
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              localizations.translate('booking.about'),
              style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF3a3a3b),
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6e6e71),
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchSelector(AppLocalizations localizations) {
   final List<BusinessLocation> locations = _business?.locations ?? <BusinessLocation>[];
    final List<BusinessLocation> filteredLocations = _service?.branches?.isNotEmpty == true
        ? locations
            .where((BusinessLocation location) =>
                _service.branches.contains(location.id))
            .toList()
        : locations;
    if (filteredLocations.isNotEmpty &&
        (_selectedBranch == null ||
            !filteredLocations.contains(_selectedBranch))) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _selectedBranch = filteredLocations.first;
        });
      });
    }
    return _BookingCard(
      title: localizations.translate('booking.branch.title'),
      child: DropdownButton<BusinessLocation>(
        isExpanded: true,
        value: _selectedBranch,
        underline: const SizedBox.shrink(),
        onChanged: (BusinessLocation value) {
          setState(() {
            _selectedBranch = value;
          });
          _refreshSlots();
        },
        items: filteredLocations
            .map((BusinessLocation location) => DropdownMenuItem<BusinessLocation>(
                  value: location,
                  child: Text(localizations.translate(location.name ?? '')),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildStaffSelector(AppLocalizations localizations) {
    final List<StaffMember> staff = _availableStaff;
    return _BookingCard(
      title: localizations.translate('booking.staff.title'),
      subtitle: localizations.translate('booking.staff.subtitle'),
      child: DropdownButton<StaffMember>(
        isExpanded: true,
        value: _selectedStaff,
        underline: const SizedBox.shrink(),
        onChanged: (StaffMember value) {
          setState(() {
            _selectedStaff = value;
          });
          _refreshSlots();
        },
        items: staff
            .map((StaffMember member) => DropdownMenuItem<StaffMember>(
                  value: member,
                  child: Text(localizations.translate(member.name ?? '')),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildDateSelector(AppLocalizations localizations) {
    final MaterialLocalizations materialLocalizations =
        MaterialLocalizations.of(context);
    final String formattedDate =
        materialLocalizations.formatFullDate(_selectedDate);
    return _BookingCard(
      title: localizations.translate('booking.date.title'),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(formattedDate),
        trailing: const Icon(Icons.calendar_today, color: Color(0xFFfb3132)),
        onTap: () async {
          final DateTime picked = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 60)),
          );
          if (picked != null) {
            setState(() {
              _selectedDate = picked;
            });
            _refreshSlots();
          }
        },
      ),
    );
  }

  Widget _buildSlots(AppLocalizations localizations) {
    if (_slots.isEmpty) {
      return _BookingCard(
        title: localizations.translate('booking.slots.available'),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            localizations.translate('booking.slots.none'),
            style: const TextStyle(color: Color(0xFF6e6e71), fontSize: 12),
          ),
        ),
      );
    }

    final MaterialLocalizations materialLocalizations =
        MaterialLocalizations.of(context);

    return _BookingCard(
      title: localizations.translate('booking.slots.available'),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _slots
            .map((DateTime slot) => ChoiceChip(
                  label: Text(materialLocalizations.formatTimeOfDay(
                      TimeOfDay.fromDateTime(slot))),
                  selected: _selectedSlot == slot,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedSlot = selected ? slot : null;
                    });
                  },
                  selectedColor: const Color(0xFFfb3132),
                  labelStyle: TextStyle(
                      color: _selectedSlot == slot
                          ? Colors.white
                          : const Color(0xFF3a3a3b)),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildNotesField(AppLocalizations localizations) {
    return _BookingCard(
      title: localizations.translate('booking.summary.notes'),
      child: TextField(
        controller: _notesController,
        maxLines: 2,
        decoration: InputDecoration(
          hintText: localizations.translate('booking.notes.hint'),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildContinueButton(AppLocalizations localizations) {
    return SizedBox(
      width: double.infinity,
      child: RaisedButton(
        color: const Color(0xFFfb3132),
        textColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onPressed: _selectedSlot == null || _service == null
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text(localizations.translate('booking.alert.unavailable')),
                ));
              }
            : () {
                debugPrint('[analytics] select_service:${_service.id}');
                debugPrint('[analytics] select_slot:${_selectedSlot.toIso8601String()}');
                final BookingDraft draft = BookingDraft(
                  business: _business,
                  branch: _selectedBranch,
                  service: _service,
                  staff: _selectedStaff,
                  start: _selectedSlot,
                  notes: _notesController.text,
                );
                Navigator.push(
                  context,
                  ScaleRoute(
                    page: FoodOrderPage(
                      bookingDraft: draft,
                    ),
                  ),
                );
              },
        child: Text(localizations.translate('booking.button.review')),
      ),
    );
  }

  Widget _buildLegacyFoodDetails(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
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
          brightness: Brightness.light,
          actions: <Widget>[
            IconButton(
                icon: const Icon(
                  Icons.business_center,
                  color: Color(0xFF3a3737),
                ),
                onPressed: () {
                  Navigator.push(context, ScaleRoute(page: FoodOrderPage()));
                })
          ],
        ),
        body: Container(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Card(
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Image.asset(
                  'assets/images/bestfood/' + 'ic_best_food_8' + ".jpeg",
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0),
                ),
                elevation: 1,
                margin: const EdgeInsets.all(5),
              ),
              FoodTitleWidget(
                  productName: "Grilled Salmon",
                  productPrice: "\$96.00",
                  productHost: "pizza hut"),
              const SizedBox(
                height: 15,
              ),
              AddToCartMenu(),
              const SizedBox(
                height: 15,
              ),
              PreferredSize(
                preferredSize: const Size.fromHeight(50.0),
                child: TabBar(
                  labelColor: const Color(0xFFfd3f40),
                  indicatorColor: const Color(0xFFfd3f40),
                  unselectedLabelColor: const Color(0xFFa4a1a1),
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const <Widget>[
                    Tab(
                      text: 'Food Details',
                    ),
                    Tab(
                      text: 'Food Reviews',
                    ),
                  ], // list of tabs
                ),
              ),
              Container(
                height: 150,
                child: TabBarView(
                  children: <Widget>[
                    Container(
                      color: Colors.white24,
                      child: DetailContentMenu(),
                    ),
                    Container(
                      color: Colors.white24,
                      child: DetailContentMenu(),
                    ), // class name
                  ],
                ),
              ),
              BottomMenu(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}

class _BookingTitle extends StatelessWidget {
  const _BookingTitle({Key key, this.title, this.price, this.businessName, this.duration})
      : super(key: key);

  final String title;
  final String price;
  final String businessName;
  final int duration;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              title ?? '',
              style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xFF3a3a3b),
                  fontWeight: FontWeight.w500),
            ),
            Text(
              price ?? '',
              style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xFF3a3a3b),
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          businessName ?? '',
          style: const TextStyle(
              fontSize: 16,
              color: Color(0xFFa9a9a9),
              fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 5),
        Text(
          localizations.translate('service.duration.minutes', count: duration ?? 0),
          style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6e6e71),
              fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({Key key, this.title, this.subtitle, this.child}) : super(key: key);

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
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
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6e6e71),
                      fontWeight: FontWeight.w400),
                ),
              ],
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// Legacy widgets retained for food ordering mode
class FoodTitleWidget extends StatelessWidget {
  String productName;
  String productPrice;
  String productHost;

  FoodTitleWidget({
    Key key,
    @required this.productName,
    @required this.productPrice,
    @required this.productHost,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              productName,
              style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF3a3a3b),
                  fontWeight: FontWeight.w500),
            ),
            Text(
              productPrice,
              style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF3a3a3b),
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
        Row(
          children: <Widget>[
            Text(
              "by ",
              style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFa9a9a9),
                  fontWeight: FontWeight.w400),
            ),
            Text(
              productHost,
              style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1f1f1f),
                  fontWeight: FontWeight.w400),
            ),
          ],
        )
      ],
    );
  }
}

class BottomMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Column(
            children: <Widget>[
              Icon(
                Icons.timelapse,
                color: Color(0xFF404aff),
                size: 35,
              ),
              SizedBox(
                height: 15,
              ),
              Text("25 min",
                  style: TextStyle(
                      color: Color(0xFFa4a1a1),
                      fontSize: 14,
                      fontWeight: FontWeight.w400))
            ],
          ),
          Column(
            children: <Widget>[
              Icon(
                Icons.directions_bike,
                color: Color(0xFF404aff),
                size: 35,
              ),
              SizedBox(
                height: 15,
              ),
              Text("Free delivery",
                  style: TextStyle(
                      color: Color(0xFFa4a1a1),
                      fontSize: 14,
                      fontWeight: FontWeight.w400))
            ],
          )
        ],
      ),
    );
  }
}

class AddToCartMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0xFFfae3e2),
              blurRadius: 25.0,
              offset: Offset(0.0, 0.75),
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            width: 130,
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
                  "1",
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
          ),
          Container(
              height: 50,
              width: 130,
              decoration: BoxDecoration(
                  color: Color(0xFFfb3132),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  )),
              child: Center(
                child: Text("Add to Cart",
                    style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 15,
                        fontWeight: FontWeight.w400)),
              ))
        ],
      ),
    );
  }
}

class DetailContentMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: <Widget>[
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 5,
                ),
                Text(
                  "This super-seeded cranberry superfood salad is a pure health explosion!",
                  style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF3a3a3b),
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "It’s filled with antioxidants and vitamins which makes it super healthy!",
                  style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFa9a9a9),
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
