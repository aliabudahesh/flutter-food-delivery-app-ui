import 'package:flutter/material.dart';
import 'package:flutter_app/data/sample_data.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class TopMenus extends StatelessWidget {
  const TopMenus({super.key, this.items});

  final List<TopMenuItemData>? items;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          final TopMenuItemData item = items![index];
          return TopMenuTile(
            label: localizations.translate(item.labelKey),
            assetPath: item.assetPath,
            iconData: item.iconData,
          );
        },
      ),
    );
  }
}

class TopMenuTile extends StatelessWidget {
  const TopMenuTile({super.key, required this.label, this.assetPath, this.iconData});

  final String label;
  final String? assetPath;
  final IconData? iconData;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 10, right: 5, top: 5, bottom: 5),
            decoration: const BoxDecoration(boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color(0xFFfae3e2),
                blurRadius: 25.0,
                offset: Offset(0.0, 0.75),
              ),
            ]),
            child: Card(
                color: Colors.white,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(3.0),
                  ),
                ),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Center(
                    child: assetPath != null
                        ? Image.asset(
                            assetPath!,
                            width: 24,
                            height: 24,
                          )
                        : Icon(
                            iconData,
                            color: const Color(0xFFfb3132),
                          ),
                  ),
                )),
          ),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF6e6e71),
                  fontSize: 14,
                  fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }
}
