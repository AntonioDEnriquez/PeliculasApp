import 'dart:async';

class Debouncer<T> {
  Debouncer(
      {
      // Cantidad de tiempo que hay que esperar antes de emitir un valor
      required this.duration,
      // Metodo que voy a deisparar cuando ya tenga un valor
      this.onValue});

  final Duration duration;

  void Function(T value)? onValue;

  T? _value;
  Timer? _timer;

  T get value => _value!;

  set value(T val) {
    _value = val;
    _timer?.cancel();
    _timer = Timer(duration, () => onValue!(_value!));
  }
}
