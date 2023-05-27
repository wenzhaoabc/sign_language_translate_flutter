import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:phone_state/phone_state.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sign_language/res/constant.dart';
import 'package:sign_language/utils/PhoneUtils.dart';

class SensorPhone {
  void StartListen(String to, String content) {
    // StreamSubscription<UserAccelerometerEvent> _accelerometerSubscription;
    userAccelerometerEvents.listen(
      (UserAccelerometerEvent event) {
        // print(event);
        if (event.x.abs() > 8 || event.y.abs() > 8 || event.z.abs() > 8) {
          String to = getStringAsync(Constant.sosPhone);
          String content = getStringAsync(Constant.sosContent);
          bool detect = getBoolAsync(Constant.detectDevice);
          if (detect && to.isNotEmpty && content.isNotEmpty) {
            PhoneUtils.makePhoneCallPlayVoice(to, content);
          }
          debugPrint("event = $event");
        }
      },
      onError: (error) {
        // Logic to handle error
        // Needed for Android in case sensor is not available
        toast('不支持当前设备');
      },
      cancelOnError: true,
    );
  }
}
