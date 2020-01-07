import 'dart:developer';

import 'package:example/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rebloc/flutter_rebloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StateProvider<ColorReBlocState>(
      initState: (context) => ColorReBlocState(Colors.blue),
      builder: (context, state) {
        return ReBlocProvider<ThemeColorInitBloc, ColorReBlocState>(
          create: (context) => ThemeColorInitBloc(),
          initialAction: true,
          child: MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: state.color,
            ),
            routes: {
              '/home': (context) => MyHomePage(title: 'Flutter Demo Home Page'),
              '/theme': (context) => ThemePage(title: 'Theme Settings'),
            },
            initialRoute: '/home',
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return ReBlocProvider<CounterBloc, CounterReBlocState>(
      create: (context) => CounterBloc(),
      initialAction: 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0, // this will be set when a new tab is tapped
          onTap: (i) =>
              i == 1 ? Navigator.pushReplacementNamed(context, '/theme') : null,
          items: [
            BottomNavigationBarItem(
              icon: new Icon(Icons.home),
              title: new Text('Home'),
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.mail),
              title: new Text('Theme'),
            ),
          ],
        ),
        body: ReBlocBuilder<CounterBloc, CounterReBlocState>(
          successListener: (context, event) => log(event.toString()),
          errorListener: (context, event) => Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(event.message),
              backgroundColor: Colors.red,
            ),
          ),
          builder: (BuildContext context, CounterBloc cbloc,
              CounterReBlocState state) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'You have pushed the button this many times:',
                  ),
                  Text(
                    state.counter.toString(),
                    style: Theme.of(context).textTheme.display1,
                  ),
                  RaisedButton(
                    onPressed: () => cbloc.add(1),
                    child: Text('Plus 1'),
                  ),
                  RaisedButton(
                    onPressed: () => cbloc.add(-1),
                    child: Text('Minus 1'),
                  ),
                  RaisedButton(
                    onPressed: () => cbloc.add(0),
                    child: Text('Not implemented'),
                  ),
                ],
              ),
            );
          },
        ),
      ), // This, trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class ColorReBlocState extends ReBlocState {
  final Color color;

  ColorReBlocState(this.color);
}

class CounterReBlocState extends ReBlocState {
  final int counter;

  CounterReBlocState(this.counter);
}

class CounterBloc extends ReBloc<CounterReBlocState> {
  @override
  CounterReBlocState initState() {
    return CounterReBlocState(0);
  }

  @override
  Stream<StateEvent<CounterReBlocState>> runEvent(
      Object event, CounterReBlocState state) async* {
    if (event == 1) {
      yield StateEvent(
          state: CounterReBlocState(state.counter + 1), event: 'plus');
    } else if (event == -1) {
      yield StateEvent(
          state: CounterReBlocState(state.counter - 1), event: 'minus');
    } else {
      yield StateEvent(
          event:
              ErrorEvent(error: 'Not Implemented', message: 'Not Implemented'));
    }
  }
}
