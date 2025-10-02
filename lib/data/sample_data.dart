import 'package:flutter/material.dart';
import 'package:flutter_app/config/app_config.dart';
import 'package:flutter_app/models/booking.dart';
import 'package:flutter_app/models/business.dart';
import 'package:flutter_app/models/service.dart';
import 'package:flutter_app/models/staff.dart';

class TopMenuItemData {
  final String labelKey;
  final String assetPath;
  final IconData iconData;

  const TopMenuItemData({
    this.labelKey,
    this.assetPath,
    this.iconData,
  });
}

class RecommendedItem {
  final String titleKey;
  final String subtitleKey;
  final double price;
  final int duration;
  final String imageAsset;

  const RecommendedItem({
    this.titleKey,
    this.subtitleKey,
    this.price = 0,
    this.duration = 0,
    this.imageAsset,
  });
}

class SampleData {
  static final DateTime _today = DateTime.now();

  static List<TopMenuItemData> getTopMenuData() {
    if (AppConfig.isBookingMode) {
      return const <TopMenuItemData>[
        TopMenuItemData(labelKey: 'business_type.barber', iconData: Icons.content_cut),
        TopMenuItemData(labelKey: 'business_type.hair_salon', iconData: Icons.brush),
        TopMenuItemData(labelKey: 'business_type.spa', iconData: Icons.spa),
        TopMenuItemData(labelKey: 'business_type.clinic', iconData: Icons.local_hospital),
        TopMenuItemData(labelKey: 'business_type.makeup', iconData: Icons.face_retouching_natural),
        TopMenuItemData(labelKey: 'business_type.massage', iconData: Icons.self_improvement),
      ];
    }

    return const <TopMenuItemData>[
      TopMenuItemData(labelKey: 'food_type.burger', assetPath: 'assets/images/topmenu/ic_burger.png'),
      TopMenuItemData(labelKey: 'food_type.sushi', assetPath: 'assets/images/topmenu/ic_sushi.png'),
      TopMenuItemData(labelKey: 'food_type.pizza', assetPath: 'assets/images/topmenu/ic_pizza.png'),
      TopMenuItemData(labelKey: 'food_type.cake', assetPath: 'assets/images/topmenu/ic_cake.png'),
      TopMenuItemData(labelKey: 'food_type.ice_cream', assetPath: 'assets/images/topmenu/ic_ice_cream.png'),
      TopMenuItemData(labelKey: 'food_type.soft_drink', assetPath: 'assets/images/topmenu/ic_soft_drink.png'),
    ];
  }

  static List<RecommendedItem> getRecommendedItems() {
    if (AppConfig.isBookingMode) {
      return const <RecommendedItem>[
        RecommendedItem(
          titleKey: 'service.haircut_lux',
          subtitleKey: 'business.mirror_masters',
          price: 180.0,
          duration: 75,
          imageAsset: 'assets/images/bestfood/ic_best_food_8.jpeg',
        ),
        RecommendedItem(
          titleKey: 'service.spa_signature',
          subtitleKey: 'business.zen_garden',
          price: 320.0,
          duration: 90,
          imageAsset: 'assets/images/bestfood/ic_best_food_9.jpeg',
        ),
        RecommendedItem(
          titleKey: 'service.barber_classic',
          subtitleKey: 'business.true_fade',
          price: 120.0,
          duration: 45,
          imageAsset: 'assets/images/bestfood/ic_best_food_10.jpeg',
        ),
      ];
    }

    return const <RecommendedItem>[
      RecommendedItem(
        titleKey: 'food.grilled_salmon',
        subtitleKey: 'food.by_pizza_hut',
        price: 96.0,
        imageAsset: 'assets/images/popular_foods/ic_popular_food_1.png',
      ),
      RecommendedItem(
        titleKey: 'food.meat_veggie',
        subtitleKey: 'food.by_pizza_hut',
        price: 65.08,
        imageAsset: 'assets/images/popular_foods/ic_popular_food_2.png',
      ),
      RecommendedItem(
        titleKey: 'food.mixed_salad',
        subtitleKey: 'food.by_pizza_hut',
        price: 34.67,
        imageAsset: 'assets/images/popular_foods/ic_popular_food_3.png',
      ),
    ];
  }

  static List<Business> getBusinesses() {
    if (!AppConfig.isBookingMode) {
      return const <Business>[];
    }

    const Business barberStudio = Business(
      id: 'biz_1',
      name: 'business.mirror_masters',
      types: <String>['business_type.barber', 'business_type.hair_salon'],
      description: 'business.desc.mirror_masters',
      photos: <String>['assets/images/bestfood/ic_best_food_8.jpeg'],
      rating: 4.8,
      ratingCount: 214,
      locations: <BusinessLocation>[
        BusinessLocation(
          id: 'loc_1',
          name: 'business.branch.city_center',
          address: 'business.branch.city_center_address',
          phone: '+972-3-555-0180',
        ),
        BusinessLocation(
          id: 'loc_2',
          name: 'business.branch.harbor',
          address: 'business.branch.harbor_address',
          phone: '+972-3-555-0182',
        ),
      ],
      workingHours: WorkingHours(startHour: 9, endHour: 20),
    );

    const Business spaClinic = Business(
      id: 'biz_2',
      name: 'business.zen_garden',
      types: <String>['business_type.spa'],
      description: 'business.desc.zen_garden',
      photos: <String>['assets/images/bestfood/ic_best_food_9.jpeg'],
      rating: 4.6,
      ratingCount: 168,
      locations: <BusinessLocation>[
        BusinessLocation(
          id: 'loc_3',
          name: 'business.branch.park',
          address: 'business.branch.park_address',
          phone: '+972-4-555-0190',
        ),
      ],
      workingHours: WorkingHours(startHour: 10, endHour: 22),
    );

    return const <Business>[barberStudio, spaClinic];
  }

  static List<Service> getServices() {
    if (!AppConfig.isBookingMode) {
      return const <Service>[];
    }

    return const <Service>[
      Service(
        id: 'svc_1',
        businessId: 'biz_1',
        name: 'service.barber_classic',
        durationMinutes: 45,
        price: 120,
        description: 'service.desc.barber_classic',
        branches: <String>['loc_1', 'loc_2'],
      ),
      Service(
        id: 'svc_2',
        businessId: 'biz_1',
        name: 'service.haircut_lux',
        durationMinutes: 75,
        price: 180,
        description: 'service.desc.haircut_lux',
        branches: <String>['loc_1'],
      ),
      Service(
        id: 'svc_3',
        businessId: 'biz_2',
        name: 'service.spa_signature',
        durationMinutes: 90,
        price: 320,
        description: 'service.desc.spa_signature',
        branches: <String>['loc_3'],
      ),
      Service(
        id: 'svc_4',
        businessId: 'biz_2',
        name: 'service.facial_refresh',
        durationMinutes: 60,
        price: 210,
        description: 'service.desc.facial_refresh',
        branches: <String>['loc_3'],
      ),
    ];
  }

  static List<StaffMember> getStaff() {
    if (!AppConfig.isBookingMode) {
      return const <StaffMember>[];
    }

    return const <StaffMember>[
      StaffMember(
        id: 'stf_1',
        businessId: 'biz_1',
        name: 'staff.yosef',
        skillServiceIds: <String>['svc_1', 'svc_2'],
        startHour: 9,
        endHour: 19,
        breaks: <int>[13],
      ),
      StaffMember(
        id: 'stf_2',
        businessId: 'biz_1',
        name: 'staff.adam',
        skillServiceIds: <String>['svc_1'],
        startHour: 10,
        endHour: 18,
        breaks: <int>[12, 16],
      ),
      StaffMember(
        id: 'stf_3',
        businessId: 'biz_2',
        name: 'staff.nava',
        skillServiceIds: <String>['svc_3', 'svc_4'],
        startHour: 11,
        endHour: 22,
        breaks: <int>[15],
      ),
    ];
  }

  static List<Booking> getExistingBookings() {
    if (!AppConfig.isBookingMode) {
      return const <Booking>[];
    }

    return <Booking>[
      Booking(
        id: 'bk_1',
        businessId: 'biz_1',
        branchId: 'loc_1',
        serviceId: 'svc_1',
        staffId: 'stf_1',
        start: DateTime(_today.year, _today.month, _today.day, 11, 0),
        end: DateTime(_today.year, _today.month, _today.day, 11, 45),
        price: 120,
      ),
      Booking(
        id: 'bk_2',
        businessId: 'biz_1',
        branchId: 'loc_1',
        serviceId: 'svc_2',
        staffId: 'stf_2',
        start: DateTime(_today.year, _today.month, _today.day + 1, 14, 0),
        end: DateTime(_today.year, _today.month, _today.day + 1, 15, 15),
        price: 180,
      ),
    ];
  }
}
