import 'package:flutter/widgets.dart';
import 'package:flutter_rebloc/src/bloc/bloc.dart';
import 'package:flutter_rebloc/src/bloc/bloc_provider.dart';
import 'package:flutter_rebloc/src/event/event.dart';

typedef ReBlocEventListener = void Function(BuildContext context, Object event);
typedef ReBlocErrorEventListener = void Function(BuildContext, ErrorEvent);

/// A widget to listen to events that happened in a BLOC.
class ReBlocListener<T extends ReBloc> extends StatefulWidget {
  /// The child widget
  final Widget child;

  /// The BLOC to listen to. Leave it empty if the BLOC is from a ReBlocProvider.
  final ReBloc bloc;

  /// A callback to get the last event that happened in the BLOC if any.
  final ValueChanged<Object> onInitLastEvent;

  /// An event listener to listen to all BLOC events.
  final ReBlocEventListener listener;

  /// An error event listener to listen to the BLOC error events.
  final ReBlocErrorEventListener errorListener;

  /// An event listener to listen to non error events.
  final ReBlocEventListener successListener;

  /// Creates a BLOC listener that callbacks on event yielded in BLOC.
  const ReBlocListener({
    Key key,
    this.child,
    this.bloc,
    this.onInitLastEvent,
    this.listener,
    this.errorListener,
    this.successListener,
  }) : super(key: key);

  @override
  ReBlocListenerState<T, ReBlocListener> createState() =>
      ReBlocListenerState<T, ReBlocListener>();
}

/// The widget state of ReBlocListener
class ReBlocListenerState<T extends ReBloc, W extends ReBlocListener>
    extends State<W> {
  /// The BLOC to listen the events to.
  @protected
  T bloc;

  /// The listener callback that listens to [ReBlocEvent.all]
  @protected
  ValueChanged<Object> listener;

  /// The listener callback that listens to [ReBlocEvent.error]
  @protected
  ValueChanged<ErrorEvent> errorListener;

  /// The listener callback that listens to [ReBlocEvent.success]
  @protected
  ValueChanged<Object> successListener;

  @mustCallSuper
  @override
  void initState() {
    super.initState();
    bloc = widget.bloc ?? ReBlocProvider.of<T>(context);
    if (widget.onInitLastEvent != null && bloc.lastEvent != null) {
      widget.onInitLastEvent(bloc.lastEvent);
    }
    _subscribe(widget);
  }

  @mustCallSuper
  @override
  void didUpdateWidget(ReBlocListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unsubscribe();

    if (widget.bloc != null && widget.bloc != bloc) {
      bloc = widget.bloc;
    } else if (oldWidget.bloc != null && widget.bloc == null) {
      bloc = ReBlocProvider.of<T>(context);
    }

    _subscribe(widget);
  }

  @mustCallSuper
  @override
  void dispose() {
    super.dispose();
    _unsubscribe();
  }

  void _subscribe(ReBlocListener w) {
    if (bloc == null) {
      return;
    }

    if (w.errorListener != null) {
      errorListener = (ErrorEvent event) => w.errorListener(context, event);
      bloc.subscribe(ReBlocEvent.error, errorListener);
    }
    if (w.successListener != null) {
      successListener = (Object event) => w.successListener(context, event);
      bloc.subscribe(ReBlocEvent.success, successListener);
    }
    if (w.listener != null) {
      listener = (Object event) => w.listener(context, event);
      bloc.subscribe(ReBlocEvent.all, listener);
    }
  }

  void _unsubscribe() {
    if (bloc == null) {
      return;
    }
    if (errorListener != null) {
      bloc.unsubscribe(ReBlocEvent.error, errorListener);
      errorListener = null;
    }
    if (successListener != null) {
      bloc.unsubscribe(ReBlocEvent.success, successListener);
      successListener = null;
    }
    if (listener != null) {
      bloc.unsubscribe(ReBlocEvent.all, listener);
      listener = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
