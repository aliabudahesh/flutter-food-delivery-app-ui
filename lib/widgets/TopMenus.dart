import 'package:flutter/material.dart';
import 'package:flutter_app/data/sample_data.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class TopMenus extends StatelessWidget {
  const TopMenus({Key key, this.items}) : super(key: key);

  final List<TopMenuItemData> items;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          final TopMenuItemData item = items[index];
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
  const TopMenuTile({Key key, this.label, this.assetPath, this.iconData})
      : super(key: key);

  final String label;
  final String assetPath;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 10, right: 5, top: 5, bottom: 5),
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Color(0xFFfae3e2),
                blurRadius: 25.0,
                offset: Offset(0.0, 0.75),
              ),
            ]),
            child: Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(3.0),
                  ),
                ),
                child: Container(
                  width: 50,
                  height: 50,
                  child: Center(
                    child: assetPath != null
                        ? Image.asset(
                            assetPath,
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
          Text(label ?? '',
              style: TextStyle(
                  color: Color(0xFF6e6e71),
                  fontSize: 14,
                  fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }
}
