import 'package:flutter/material.dart';

class MeuStreamBuilder<T> extends StatelessWidget {
  final Stream<T> stream;
  final AsyncWidgetBuilder<T> builder;
  final T? initialData;

  const MeuStreamBuilder({
    super.key,
    required this.stream,
    required this.builder,
    this.initialData,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loader();
        }
        if (snapshot.hasError) {
          return _telaFalha();
        }
        // if (!snapshot.hasData) {
        //   return _telaSemDados();
        // }
        // if (snapshot.data.data() == null) {
        //   return _telaSemDados2();
        // }
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
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text('...'),
    //   ),
    //   body: Center(
    //     child: Text('Ocorreu uma falha: hasError'),
    //   ),
    // );
    return const Text('Ocorreu uma falha');
  }

  // Widget _telaSemDados() {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('...'),
  //     ),
  //     body: Center(
  //       child: Text('noData'),
  //     ),
  //   );
  // }

  // Widget _telaSemDados2() {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('...'),
  //     ),
  //     body: Center(
  //       child: Text('Sala excluída'),
  //     ),
  //   );
  // }
}
