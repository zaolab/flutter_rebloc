import 'dart:async';

import 'package:flutter/widgets.dart';

/// A base object to represent the state of the UI as output by the bloc.
///
/// Each bloc should only ever output one type of state.
/// Consider using multiple blocs if there is a need to output different state
/// types as each bloc should ideally only process one kind of UI state.
/// If there is a need to communicate internal state, use an event instead.
/// e.g. loading, working, saving, loaded, saved, errored etc.
@immutable
abstract class ReBlocState {
  /// Creates a base ReBlocState.
  const ReBlocState();
}

/// A function type that is used as a callback to initialize a default state.
typedef StateInitializer<T extends ReBlocState> = T Function(BuildContext);

/// A broadcast controller to convert state value changes to an I/O stream.
class StateController<T extends ReBlocState> extends Sink<T> {
  /// The stream of state coming into the controller.
  Stream<T> get stream => _controller.stream;

  /// The current state that the controller is holding.
  T get state => _state;

  /// Creates a StateController with [initialState] as the initial state value.
  StateController({initialState}) : _state = initialState;

  /// Adds a new state value into the stream.
  @override
  void add(T state) {
    _state = state;
    _controller.add(state);
  }

  /// Closes the stream, no new value can be added to the stream.
  @override
  void close() {
    _controller.close();
  }

  T _state;

  final StreamController<T> _controller = StreamController<T>.broadcast();
}
