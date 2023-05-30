import 'package:flutter/material.dart';

class MeuStreamBuilder<T> extends StatelessWidget {
  final Stream<T> stream;
  final AsyncWidgetBuilder<T> builder;
  final T? initialData;

  const MeuStreamBuilder({
    Key? key,
    required this.stream,
    required this.builder,
    this.initialData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loader();
        }
        if (snapshot.hasError) {
          return _telaFalha();
        }
        return builder(context, snapshot);
      },
    );
  }

  Widget _loader() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _telaFalha() {
    return const Text('Ocorreu uma falha');
  }
}
