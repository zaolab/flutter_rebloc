import 'package:flutter/widgets.dart';
import 'package:flutter_rebloc/src/state/state_provider.dart';

/// A widget that takes a list of StateProviders and build them.
///
/// The StateProvider will be built into a nested tree with the
/// first StateProvider as the top level ancestor and the
/// last StateProvider as the bottom level descendant.
/// The source child or builder property of the StateProviders will not be used.
class MultiStateProvider extends StatelessWidget {
  /// The list of StateProviders.
  final List<StateProvider> providers;

  /// The child widget.
  final Widget child;

  /// Creates a widget that builds multiple StateProvider.
  const MultiStateProvider({Key key, @required this.providers, this.child})
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
