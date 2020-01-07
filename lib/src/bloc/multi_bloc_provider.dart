import 'package:flutter/widgets.dart';
import 'package:flutter_rebloc/src/bloc/bloc_provider.dart';

/// A widget that takes a list of ReBlocProvider and build them.
///
/// The ReBlocProvider will be built into a nested tree with the
/// first ReBlocProvider as the top level ancestor and the
/// last ReBlocProvider as the bottom level descendant.
/// The source child or builder property of the ReBlocProvider will not be used.
class MultiBlocProvider extends StatelessWidget {
  /// The list of ReBlocProvider.
  final List<ReBlocProvider> providers;

  /// The child widget.
  final Widget child;

  /// Creates a widget that builds multiple ReBlocProvider.
  const MultiBlocProvider({Key key, @required this.providers, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var stack = child;
    for (var p in providers.reversed) {
      stack = p.cloneWithChild(stack);
    }
    return stack;
  }
}
