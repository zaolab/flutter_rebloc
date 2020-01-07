import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_rebloc/src/event/event.dart';
import 'package:flutter_rebloc/src/state/state.dart';
import 'package:flutter_rebloc/src/state/state_provider.dart';

/// A layer that processes business logic by consuming action events and
/// streaming output state.
///
/// The BLOC consumes an incoming action event through the add method and
/// streams the output through the [stream] property.
/// The action event will be consumed by the runEvent method which all BLOCs
/// must override. The yielded value of the runEvent can contain an event
/// and/or state. The event will be passed to the event listeners and state
/// to the output stream. The output event signifies the internal state of the
/// BLOC and what it is currently doing. Event and/or state can be null.
/// When the state is null, the previous state will be kept as if.
///
/// e.g.
/// ```dart
/// enum CounterAction {
///   increment,
///   decrement,
/// }
///
/// CounterState extends ReBlocState {
///   final int counter;
///   CounterState(this.counter);
/// }
///
/// CounterBloc extends ReBloc<CounterState> {
///   CounterState initState() => CounterState(0);
///
///   Stream<StateEvent<CounterState>> runEvent(Object action, CounterState state) async* {
///     yield(StateEvent(event: 'Working...'));
///
///      switch (action) {
///        case CounterAction.increment:
///          yield(StateEvent(event: 'Incremented', state: CounterState(state.count+1)));
///          break;
///        case CounterAction.decrement:
///          yield(StateEvent(event: 'Decremented', state: CounterState(state.count-1)));
///          break;
///        default:
///          yield(StateEvent(event: ErrorEvent(message: 'Not implemented')));
///      }
///   }
/// }
/// ```
abstract class ReBloc<S extends ReBlocState> {
  /// The last event that occured in the Bloc.
  ///
  /// This is not the action event that is sunk into the BlOC.
  /// It is the event that signals the situation the BLOC faced itself.
  Object get lastEvent => _lastEvent;

  /// The output stream containing the state.
  Stream get stream => _output.stream;

  /// The type of the state.
  Type get stateType => S;

  /// The last state output by the BLOC.
  S get state => _state;

  /// Creates a new BLOC with [context] that the BLOC can use to get
  /// access to state values provided by an ancestor StateProvider.
  ReBloc({BuildContext context}) {
    _state = initState();
    if (context != null) {
      withContext(context);
    }
    _eventStream.stream.listen((event) {
      runEvent(event, state)?.listen((stateEvent) {
        _lastEvent = stateEvent.event ?? _lastEvent;

        if (stateEvent.state != null && _state != stateEvent.state) {
          state = stateEvent.state;
          _output.add(stateEvent.state);
        }

        if (stateEvent.event != null) {
          if (stateEvent.event is ErrorEvent) {
            for (var f in _errorListeners) {
              f(stateEvent.event);
            }
          } else {
            for (var f in _successListeners) {
              f(stateEvent.event);
            }
          }
          for (var f in _listeners) {
            f(stateEvent.event);
          }
        }
      });
    }, onError: handleError);
  }

  /// Creates a default initial state.
  @protected
  S initState();

  /// Consumes and run the [action] added to the sink and yield an output stream
  /// containing the BLOC event and output state.
  @protected
  Stream<StateEvent<S>> runEvent(Object action, S state);

  /// Closes and cleanup the BLOC.
  @mustCallSuper
  void close() {
    _stateSub?.cancel();
    _stateSub = null;
    _context = null;
    _eventStream.close();
    _output.close();
    _listeners.clear();
    _errorListeners.clear();
    _successListeners.clear();
  }

  /// Adds an action event to be run by the BLOC.
  void add(Object action) {
    _eventStream.add(action);
  }

  /// Subscribe callback function to the [eventType] events yielded by runEvent.
  ///
  /// There are three event types to subscribe to:
  /// 1. [ReBlocEvent.error] - Events that extend the ErrorEvent class.
  /// 2. [ReBlocEvent.success] - Events that _do not_ extend the ErrorEvent class.
  /// 3. [ReBlocEvent.all] - All events.
  void subscribe(ReBlocEvent eventType, dynamic f) {
    switch (eventType) {
      case ReBlocEvent.all:
        _listeners.add(f);
        break;
      case ReBlocEvent.success:
        _successListeners.add(f);
        break;
      case ReBlocEvent.error:
        _errorListeners.add(f);
        break;
    }
  }

  /// Unsubscribe callback function from the [eventType] events.
  void unsubscribe(ReBlocEvent eventType, dynamic f) {
    switch (eventType) {
      case ReBlocEvent.all:
        _listeners.remove(f);
        break;
      case ReBlocEvent.success:
        _successListeners.remove(f);
        break;
      case ReBlocEvent.error:
        _errorListeners.remove(f);
        break;
    }
  }

  /// Sets the BLOC with [context] to be used to get state values from the
  /// context tree.
  void withContext(BuildContext context) {
    if (context != null && _context != context) {
      _context = context;
      final p = StateProvider.of<S>(context);
      if (p != null) {
        _state = p.state;
        _sharedState = true;
        _stateSub?.cancel();
        _stateSub = p.stream.listen(updateStateFromStream);
      } else if (_sharedState) {
        _sharedState = false;
        _stateSub?.cancel();
        _stateSub = null;
      }
    } else if (_context != context) {
      _sharedState = false;
      _context = context;
      _stateSub?.cancel();
      _stateSub = null;
    }
  }

  /// Gets a state value from an ancestor StateProvider.
  /// There must be a context set in the BLOC either from the constructor
  /// or the withContext method.
  T getSharedStateOfType<T extends ReBlocState>() {
    if (_context != null) {
      return StateProvider.of<T>(_context)?.state;
    }

    return null;
  }

  /// Handles any unhandled streaming error that happened in runEvent method.
  void handleError(dynamic err) {
    log(err.toString(), error: err);
  }

  final StreamController<Object> _eventStream = StreamController<Object>();

  final StreamController<S> _output = StreamController<S>.broadcast();

  S _state;

  final Set<ValueChanged<Object>> _listeners = {};

  final Set<ValueChanged<ErrorEvent>> _errorListeners = {};

  final Set<ValueChanged<Object>> _successListeners = {};

  Object _lastEvent;

  BuildContext _context;

  bool _sharedState = false;

  // ignore: cancel_subscriptions
  StreamSubscription<S> _stateSub;

  @protected
  set state(S s) {
    if (_sharedState) {
      final ss = StateProvider.of<S>(_context);
      if (ss != null) {
        ss.add(s);
      } else {
        _sharedState = false;
      }
    }
    _state = s;
  }

  /// Updates the state coming from external events and pushing it to the stream.
  @protected
  void updateStateFromStream(S s) {
    if (_state != s) {
      _state = s;
      _output.add(s);
    }
  }
}

typedef ReBlocCreator<S extends ReBlocState> = ReBloc<S> Function(BuildContext);

/// An object that contains the BLOC event and output state.
class StateEvent<S extends ReBlocState> {
  /// The state value to push into the BLOC stream.
  final S state;

  /// The BLOC event to trigger to listeners.
  final Object event;

  /// Creates an immutable StateEvent to push to BLOC stream.
  StateEvent({this.state, this.event});
}

/// The different types of events the BLOC can yield.
enum ReBlocEvent {
  /// An events that extend the ErrorEvent class and indicating
  /// an error happening in the BLOC.
  error,

  /// An event that is not an error indicating the BLOC has
  /// successfully performed its job.
  success,

  /// Both error and non error events.
  all,
}
