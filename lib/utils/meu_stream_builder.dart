// @dart=2.9
import 'package:flutter/material.dart';

class MeuStreamBuilder<T> extends StatelessWidget {
  final Stream<T> stream;
  final AsyncWidgetBuilder<T> builder;
  final T initialData;

  const MeuStreamBuilder({
    Key key,
    @required this.stream,
    @required this.builder,
    this.initialData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
    return Center(
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
    return Text('Ocorreu uma falha');
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
