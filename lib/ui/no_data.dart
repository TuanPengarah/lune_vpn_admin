import 'package:flutter/material.dart';

class NoData extends StatelessWidget {
  final IconData? icon;
  final String? reason;

  const NoData({Key? key, this.icon, this.reason}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Center(
        child: Container(
          height: MediaQuery.of(context).size.height / 1.5,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon ?? Icons.browser_not_supported,
                  color: Colors.grey,
                  size: 120,
                ),
                SizedBox(height: 5),
                Text(reason ?? 'No Data Found!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ))
              ]),
        ),
      ),
    );
  }
}
