import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rebloc/flutter_rebloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePage extends StatelessWidget {
  ThemePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // this will be set when a new tab is tapped
        onTap: (i) =>
            i == 0 ? Navigator.pushReplacementNamed(context, '/home') : null,
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
      body: ReBlocProvider<ThemeColorBloc, ColorReBlocState>(
        create: (context) => ThemeColorBloc(),
        successListener: (context, event) => Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('Color changed successfully.'),
          ),
        ),
        builder: (context, bloc, state) {
          return Center(
              child: DropdownButton<Color>(
            items: ThemeColor.map<String, DropdownMenuItem<Color>>(
                (k, v) => MapEntry(
                    k,
                    DropdownMenuItem(
                      value: v,
                      child: Text(k),
                    ))).values.toList(),
            value: state.color,
            onChanged: (c) => bloc.add(ColorChanged(c)),
          ));
        },
      ),
    );
  }
}

class ColorChanged {
  final Color color;

  ColorChanged(this.color);
}

class ThemeColorBloc extends ReBloc<ColorReBlocState> {
  @override
  ColorReBlocState initState() {
    return ColorReBlocState(Colors.blue);
  }

  @override
  Stream<StateEvent<ColorReBlocState>> runEvent(Object event, _) async* {
    if (event is ColorChanged) {
      final pref = await SharedPreferences.getInstance();
      await pref.setString('theme',
          ThemeColor.entries.firstWhere((c) => c.value == event.color).key);
      yield StateEvent(
          event: 'changed', state: ColorReBlocState(event.color));
    }
  }
}

const ThemeColor = {
  'blue': Colors.blue,
  'red': Colors.red,
  'green': Colors.green,
  'yellow': Colors.yellow,
  'orange': Colors.orange,
  'grey': Colors.grey,
  'indigo': Colors.indigo,
  'teal': Colors.teal,
};

class ThemeColorInitBloc extends ReBloc<ColorReBlocState> {
  @override
  ColorReBlocState initState() {
    return ColorReBlocState(Colors.blue);
  }

  @override
  Stream<StateEvent<ColorReBlocState>> runEvent(Object event, _) async* {
    final pref = await SharedPreferences.getInstance();
    final theme = pref.getString('theme');
    if (theme != null && theme.isNotEmpty && ThemeColor[theme] != null) {
      yield StateEvent(state: ColorReBlocState(ThemeColor[theme]));
    }
  }
}
