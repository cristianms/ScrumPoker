import 'dart:async';

/// Abstração de classe bloc
abstract class SimpleBloc<T extends Object> {
  /// Controller do stream
  final _controller = StreamController<T>();

  /// Getter do stream
  Stream<T> get stream => _controller.stream;

  /// Adiciona valor ao stream
  void add(T object) {
    _controller.add(object);
  }

  /// Adiciona erro ao stream
  void addError(T object) {
    if (!_controller.isClosed) {
      _controller.addError(object);
    }
  }

  /// Fecha o stream
  void dispose() {
    _controller.close();
  }
}
