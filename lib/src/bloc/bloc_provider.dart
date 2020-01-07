import 'package:flutter/widgets.dart';
import 'package:flutter_rebloc/src/bloc/bloc.dart';
import 'package:flutter_rebloc/src/bloc/bloc_builder.dart';
import 'package:flutter_rebloc/src/bloc/bloc_listener.dart';
import 'package:flutter_rebloc/src/state/state.dart';

/// A BLOC injector to allow descendant widgets to get the BLOC object.
class ReBlocProvider<T extends ReBloc<S>, S extends ReBlocState>
    extends StatefulWidget {
  /// A callback to create the actual BLOC itself.
  final ReBlocCreator<S> create;

  /// An initial action event to add to the BLOC sink for processing.
  final Object initialAction;

  /// The child widget.
  final Widget child;

  /// A builder callback to build the child widget.
  ///
  /// The [builder] and [child] _must not_ both be present since
  /// they serve the same purpose.
  final Widget Function(BuildContext, T, S) builder;

  /// A callback to get the last event that happened in the BLOC if any.
  final ValueChanged<Object> onInitLastEvent;

  /// An event listener to listen to all BLOC events.
  final ReBlocEventListener listener;

  /// An error event listener to listen to the BLOC error events.
  final ReBlocErrorEventListener errorListener;

  /// An event listener to listen to non error events.
  final ReBlocEventListener successListener;

  /// Creates a BLOC injector widget.
  const ReBlocProvider({
    Key key,
    @required this.create,
    this.initialAction,
    this.child,
    this.builder,
    this.onInitLastEvent,
    this.listener,
    this.errorListener,
    this.successListener,
  })  : assert(child == null || builder == null),
        super(key: key);

  @override
  _ReBlockProviderState<T, S> createState() => _ReBlockProviderState<T, S>();

  /// Clones the ReBlocProvider with a different child.
  ReBlocProvider<T, S> cloneWithChild(Widget child) {
    return ReBlocProvider<T, S>(
      key: key,
      create: create,
      initialAction: initialAction,
      onInitLastEvent: onInitLastEvent,
      listener: listener,
      errorListener: errorListener,
      successListener: successListener,
      child: child,
    );
  }

  /// Gets the BLOC of type [T] provided by ReBlocProvider in the [context] tree.
  static T of<T extends ReBloc>(BuildContext context) {
    var state = context
        .getElementForInheritedWidgetOfExactType<_ReBlocProviderStateScope<T>>()
        ?.widget as _ReBlocProviderStateScope<T>;
    return state?._bloc;
  }
}

class _ReBlockProviderState<T extends ReBloc<S>, S extends ReBlocState>
    extends State<ReBlocProvider<T, S>> {
  T _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.create(context);
    _bloc.withContext(context);
    if (widget.initialAction != null) {
      _bloc.add(widget.initialAction);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.close();
    _bloc = null;
  }

  @override
  Widget build(BuildContext context) {
    var child = widget.child;
    if (widget.builder != null) {
      child = ReBlocBuilder<T, S>(
        builder: widget.builder,
        onInitLastEvent: widget.onInitLastEvent,
        listener: widget.listener,
        successListener: widget.successListener,
        errorListener: widget.errorListener,
      );
    } else if (widget.onInitLastEvent != null ||
        widget.listener != null ||
        widget.successListener != null ||
        widget.errorListener != null) {
      child = ReBlocListener<T>(
        child: child,
        onInitLastEvent: widget.onInitLastEvent,
        listener: widget.listener,
        successListener: widget.successListener,
        errorListener: widget.errorListener,
      );
    }
    return _ReBlocProviderStateScope<T>(
      _bloc,
      child: child,
    );
  }
}

class _ReBlocProviderStateScope<T extends ReBloc> extends InheritedWidget {
  final T _bloc;

  _ReBlocProviderStateScope(this._bloc, {Key key, Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(_ReBlocProviderStateScope old) => _bloc != old._bloc;
}
