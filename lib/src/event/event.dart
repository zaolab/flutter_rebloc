/// The base BLOC internal event class.
///
/// It is a requirement for events to extend this.
abstract class Event {
  /// Creates a base event.
  const Event();
}

/// A base error event to represent an error that happened in the BLOC.
class ErrorEvent extends Event {
  /// An object to represent the error itself.
  final Object error;

  /// A message to describe the error.
  final String message;

  /// Creates an error event.
  const ErrorEvent({this.error, this.message});

  @override
  String toString() {
    return message;
  }
}
