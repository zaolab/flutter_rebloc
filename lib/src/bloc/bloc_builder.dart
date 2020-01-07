import 'package:flutter/widgets.dart';
import 'package:flutter_rebloc/src/bloc/bloc.dart';
import 'package:flutter_rebloc/src/bloc/bloc_listener.dart';
import 'package:flutter_rebloc/src/state/state.dart';

/// A builder widget that passes the BLOC of type [T] to the callback.
///
/// The BLOC must be provided by an ancestor ReBlocProvider widget.
class ReBlocBuilder<T extends ReBloc, S extends ReBlocState>
    extends ReBlocListener {
  /// The builder callback to generate the child widget.
  final Widget Function(BuildContext, T, S) builder;

  /// Creates the builder that passes down the BLOC's state value.
  const ReBlocBuilder({
    Key key,
    @required this.builder,
    ReBloc bloc,
    ValueChanged<Object> onInitLastEvent,
    ReBlocEventListener listener,
    ReBlocErrorEventListener errorListener,
    ReBlocEventListener successListener,
  }) : super(
          key: key,
          bloc: bloc,
          onInitLastEvent: onInitLastEvent,
          listener: listener,
          errorListener: errorListener,
          successListener: successListener,
        );

  @override
  _ReBlocBuilderState<T, S> createState() => _ReBlocBuilderState<T, S>();
}

class _ReBlocBuilderState<T extends ReBloc, S extends ReBlocState>
    extends ReBlocListenerState<T, ReBlocBuilder<T, S>> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<S>(
      initialData: bloc.state,
      stream: bloc.stream,
      builder: (context, snapshot) {
        return widget.builder(context, bloc, snapshot.data);
      },
    );
  }
}
