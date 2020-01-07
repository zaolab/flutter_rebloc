import 'package:flutter/widgets.dart';
import 'package:flutter_rebloc/flutter_rebloc.dart';
import 'package:flutter_rebloc/src/state/state.dart';
import 'package:flutter_rebloc/src/state/state_builder.dart';

/// A state injector to allow descendant widgets and BLOCs to access the state value.
///
/// If a state type [T] is injector into the widget tree, then all BLOCs which
/// work with the type will be updating this state.
/// This allow BLOCs to share state values and persist state across screens
/// if used as a top level Widget.
class StateProvider<T extends ReBlocState> extends StatefulWidget {
  /// A callback function to initialize the default state value.
  final StateInitializer<T> initState;

  /// The child widget.
  final Widget child;

  /// A builder function to build the child with [T] as the second argument.
  ///
  /// This property is provided as a convenience.
  /// If the plan is to immediately access and use the state value,
  /// then use this builder to gain access instead of nesting another
  /// StateBuilder widget.
  final Function(BuildContext, T) builder;

  /// Creates a state injector widget.
  const StateProvider({
    Key key,
    @required this.initState,
    this.child,
    this.builder,
  })  : assert(child == null || builder == null),
        super(key: key);

  @override
  _StateProviderState<T> createState() => _StateProviderState<T>();

  /// Clones this replacing the widget's current child to the [child].
  StateProvider<T> cloneWithChild(Widget child) {
    return StateProvider<T>(
      key: key,
      initState: initState,
      child: child,
    );
  }

  /// Gets the state of type [T] provided by StateProvider in the [context] tree.
  static StateController<T> of<T extends ReBlocState>(BuildContext context) {
    var state = context
        .getElementForInheritedWidgetOfExactType<_StateProviderScope<T>>()
        ?.widget as _StateProviderScope<T>;
    return state?._controller;
  }
}

class _StateProviderState<T extends ReBlocState>
    extends State<StateProvider<T>> {
  StateController<T> _controller;

  @override
  void initState() {
    super.initState();
    _controller = StateController(initialState: widget.initState(context));
  }

  /// Updates the state and add it into the stream sink for listeners to consume.
  void updateState(T s) {
    if (s != _controller.state) {
      _controller.add(s);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    var child = widget.child;
    if (widget.builder != null) {
      child = StateBuilder<T>(
        builder: widget.builder,
      );
    }
    return _StateProviderScope<T>(
      _controller,
      child: child,
    );
  }
}

class _StateProviderScope<T extends ReBlocState> extends InheritedWidget {
  final StateController<T> _controller;

  _StateProviderScope(this._controller, {Key key, Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(_StateProviderScope old) =>
      _controller != old._controller;
}
