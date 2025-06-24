part of 'voice_recording_bloc.dart';

/// Base abstract class for all voice recording events.
///
/// This sealed class defines the contract for all events that can be
/// dispatched to the [VoiceRecordingBloc]. Each concrete event represents
/// a specific user action or system trigger related to voice recording.
///
/// All events are immutable and should be created using const constructors
/// for optimal performance and memory usage.
abstract class VoiceRecordingEvent {
  const VoiceRecordingEvent();
}

/// Event to initiate voice recording.
///
/// This event triggers the start of a new voice recording session.
/// The BLoC will handle all necessary initialization including:
/// * Microphone permission requests
/// * Speech recognition setup
/// * Audio stream initialization
/// * Real-time text recognition
///
/// The event has no parameters as all configuration is handled
/// internally by the BLoC and its use cases.
///
/// Example usage:
/// ```dart
/// // Start recording when user presses record button
/// onPressed: () {
///   context.read<VoiceRecordingBloc>()
///     .add(const StartVoiceRecordingEvent());
/// }
/// ```
///
/// If a recording is already in progress, this event will be ignored
/// to prevent conflicts and ensure stable operation.
class StartVoiceRecordingEvent extends VoiceRecordingEvent {
  /// Creates a start voice recording event.
  const StartVoiceRecordingEvent();
}

/// Event to stop voice recording and retrieve final text.
///
/// This event terminates the current recording session and retrieves
/// the final recognized text. The recording will be properly finalized
/// and all resources will be cleaned up.
///
/// The event supports an optional completion callback that receives
/// the final recognized text, allowing immediate handling of the result
/// without requiring additional state monitoring.
///
/// Example usage:
/// ```dart
/// // Stop recording and handle the result
/// context.read<VoiceRecordingBloc>().add(
///   StopVoiceRecordingEvent(
///     onComplete: (recognizedText) {
///       // Handle the final text
///       _messageController.text = recognizedText;
///       _sendMessage();
///     },
///   ),
/// );
///
/// // Stop recording without immediate handling
/// context.read<VoiceRecordingBloc>().add(
///   const StopVoiceRecordingEvent(),
/// );
/// ```
class StopVoiceRecordingEvent extends VoiceRecordingEvent {

  /// Creates a stop voice recording event.
  ///
  /// [onComplete] Optional callback that receives the final recognized text.
  /// The callback is executed after the recording has been successfully
  /// stopped and the state updated.
  const StopVoiceRecordingEvent({this.onComplete});
  /// Optional callback executed when recording is successfully stopped.
  ///
  /// The callback receives the final recognized text as a [String] parameter.
  /// This allows immediate processing of the recording result without
  /// requiring additional BlocListener or state monitoring.
  ///
  /// The callback is executed after the BLoC state has been updated to
  /// completed, ensuring the UI reflects the final state before the
  /// callback is invoked.
  final void Function(String recognizedText)? onComplete;
}

/// Event to cancel voice recording without saving text.
///
/// This event immediately terminates the recording session and discards
/// all recognized text. It's used when the user wants to abort the
/// recording without saving the result.
///
/// The cancellation is immediate and irreversible - any text that was
/// being recognized during the session will be lost. The BLoC will
/// return to its initial state after cancellation.
///
/// Example usage:
/// ```dart
/// // Cancel recording with cleanup callback
/// context.read<VoiceRecordingBloc>().add(
///   CancelVoiceRecordingEvent(
///     onCancel: () {
///       // Perform any necessary cleanup
///       _resetUI();
///       _showCancellationMessage();
///     },
///   ),
/// );
///
/// // Simple cancellation without callback
/// context.read<VoiceRecordingBloc>().add(
///   const CancelVoiceRecordingEvent(),
/// );
/// ```
class CancelVoiceRecordingEvent extends VoiceRecordingEvent {

  /// Creates a cancel voice recording event.
  ///
  /// [onCancel] Optional callback executed after the recording
  /// has been canceled and state reset to initial.
  const CancelVoiceRecordingEvent({this.onCancel});
  /// Optional callback executed when recording is successfully canceled.
  ///
  /// This callback is invoked after the recording has been terminated
  /// and the BLoC state has been reset to initial. It allows for
  /// immediate UI updates or cleanup operations.
  ///
  /// The callback receives no parameters as no data is preserved
  /// during cancellation.
  final VoidCallback? onCancel;
} 
