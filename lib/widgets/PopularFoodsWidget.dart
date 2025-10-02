import 'package:flutter/material.dart';
import 'package:flutter_app/config/app_config.dart';
import 'package:flutter_app/data/sample_data.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class PopularFoodsWidget extends StatelessWidget {
  const PopularFoodsWidget({super.key, this.items, this.onTap});

  final List<RecommendedItem>? items;
  final ValueChanged<RecommendedItem>? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 265,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          const PopularFoodTitle(),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                final RecommendedItem item = items![index];
                final AppLocalizations localizations = AppLocalizations.of(context)!;
                return PopularFoodTile(
                  title: localizations.translate(item.titleKey),
                  subtitle: localizations.translate(item.subtitleKey),
                  price: item.price,
                  duration: item.duration,
                  imageAsset: item.imageAsset,
                  onTap: onTap == null ? null : () => onTap!(item),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class PopularFoodTitle extends StatelessWidget {
  const PopularFoodTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final String titleKey = AppConfig.isBookingMode
        ? 'home.section.recommended.booking'
        : 'home.section.recommended.food';
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            localizations.translate(titleKey),
            style: const TextStyle(
                fontSize: 20,
                color: Color(0xFF3a3a3b),
                fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }
}

class PopularFoodTile extends StatelessWidget {
  const PopularFoodTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.duration,
    required this.imageAsset,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final double price;
  final int duration;
  final String imageAsset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    return InkWell(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 10, right: 5, top: 5, bottom: 5),
            decoration: const BoxDecoration(boxShadow: [
              BoxShadow(
                color: Color(0xFFfae3e2),
                blurRadius: 15.0,
                offset: Offset(0, 0.75),
              ),
            ]),
            child: Card(
                color: Colors.white,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                ),
                child: Container(
                  width: 170,
                  height: 210,
                  child: Column(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              alignment: Alignment.topRight,
                              width: double.infinity,
                              padding: const EdgeInsets.only(right: 5, top: 5),
                              child: Container(
                                height: 28,
                                width: 28,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white70,
                                    boxShadow: const <BoxShadow>[
                                      BoxShadow(
                                        color: Color(0xFFfae3e2),
                                        blurRadius: 25.0,
                                        offset: Offset(0.0, 0.75),
                                      ),
                                    ]),
                                child: const Icon(
                                  Icons.favorite,
                                  color: Color(0xFFfb3132),
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Center(
                                child: Image.asset(
                              imageAsset,
                              width: 130,
                              height: 140,
                              fit: BoxFit.cover,
                            )),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.bottomLeft,
                            padding: const EdgeInsets.only(left: 5, top: 5),
                            child: Text(title ?? '',
                                style: const TextStyle(
                                    color: Color(0xFF6e6e71),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500)),
                          ),
                          Container(
                            alignment: Alignment.topRight,
                            padding: const EdgeInsets.only(right: 5),
                            child: Container(
                              height: 28,
                              width: 28,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white70,
                                  boxShadow: const <BoxShadow>[
                                    BoxShadow(
                                      color: Color(0xFFfae3e2),
                                      blurRadius: 25.0,
                                      offset: Offset(0.0, 0.75),
                                    ),
                                  ]),
                              child: Icon(
                                AppConfig.isBookingMode
                                    ? Icons.schedule
                                    : Icons.near_me,
                                color: const Color(0xFFfb3132),
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.only(left: 5, top: 5),
                            child: Text(
                              subtitle ?? '',
                              style: const TextStyle(
                                  color: Color(0xFF6e6e71),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            padding:
                                const EdgeInsets.only(left: 5, top: 5, right: 5),
                            child: Text(
                              AppConfig.isBookingMode
                                  ? '${price.toStringAsFixed(0)} ₪'
                                  : '\$${price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Color(0xFF6e6e71),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      if (AppConfig.isBookingMode)
                        Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
                          child: Text(
                            localizations.translate('service.duration.minutes',
                                count: duration),
                            style: const TextStyle(
                                color: Color(0xFF6e6e71),
                                fontSize: 10,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
