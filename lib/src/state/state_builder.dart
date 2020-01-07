import 'package:flutter/widgets.dart';
import 'package:flutter_rebloc/src/state/state.dart';
import 'package:flutter_rebloc/src/state/state_provider.dart';

/// A builder widget that passes a state value of type [T] to the callback.
///
/// The state value must be provided by an ancestor StateProvider widget.
class StateBuilder<T extends ReBlocState> extends StatefulWidget {
  /// A builder function to build the child with [T] as the second argument.
  final Widget Function(BuildContext, T) builder;

  /// Creates the builder that passes down the state value.
  const StateBuilder({
    Key key,
    this.builder,
  }) : super(key: key);

  @override
  _StateBuilderState<T> createState() => _StateBuilderState<T>();
}

class _StateBuilderState<T extends ReBlocState> extends State<StateBuilder<T>> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = StateProvider.of<T>(context);
    return StreamBuilder<T>(
      initialData: state.state,
      stream: state.stream,
      builder: (context, snapshot) => widget.builder(context, snapshot.data),
    );
  }
}
