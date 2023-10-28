import 'dart:math';

import 'package:nanoid/non_secure.dart';

String randomString(int size) => customAlphabet(
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
      size,
    );

int randomInt() =>
    ((Random().nextDouble() * (1 << 63) * 2) - (1 << 63)).toInt();
