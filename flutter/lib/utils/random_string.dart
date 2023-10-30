import 'dart:math';

const _alphabet =
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

String randomString(int size) {
  final rand = Random();
  return List.generate(
    size,
    (index) => _alphabet[rand.nextInt(_alphabet.length)],
  ).join();
}

int randomInt() =>
    ((Random().nextDouble() * (1 << 63) * 2) - (1 << 63)).toInt();
