import 'package:flutter/material.dart';
import 'package:waset_management/main.dart';

class Nav {
  static goToScrean(Widget screan) {
    return navKey.currentState!.push(MaterialPageRoute(builder: (_) => screan));
  }

  static goToScreanWithReplaceMent(Widget screan) {
    return navKey.currentState!
        .pushReplacement(MaterialPageRoute(builder: (_) => screan));
  }

  static goToScreanAndRemoveUntill(Widget screan) {
    return navKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => screan),
        ((Route<dynamic> route) => false));
  }

  static pop({val}) {
    if (navKey.currentState!.canPop()) {
      navKey.currentState!.pop(val);
    } else {
      goToScrean(Container());
    }
    return;
  }
}
