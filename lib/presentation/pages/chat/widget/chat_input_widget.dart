import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ai_chat_bot/core/theme/app_theme.dart';
import 'package:ai_chat_bot/presentation/widgets/voice_recording_bottom_modal.dart';
import 'package:ai_chat_bot/presentation/bloc/voice_recording/voice_recording_bloc.dart';
import 'package:ai_chat_bot/core/dependency_injection/dependency_injection.dart'
    as di;

/// A comprehensive chat input widget that provides multi-modal message composition capabilities.
///
/// This sophisticated input widget serves as the primary interface for users to compose
/// and send messages in the chat interface. It supports both text input and voice
/// recording, with advanced features for message editing and contextual feedback.
/// The widget integrates seamlessly with the chat system and provides an intuitive
/// user experience across different input modalities.
///
/// Key capabilities:
/// * **Text Composition**: Multi-line text field with automatic height adjustment
/// * **Voice Input**: Long-press voice recording with drag-to-cancel functionality
/// * **Edit Mode**: Visual indicators and specialized behavior for message editing
/// * **Send Actions**: Integrated send button with immediate message dispatch
/// * **Cancellation**: User-friendly cancellation for both text and voice inputs
/// * **Accessibility**: Proper focus management and gesture handling
///
/// Input modes:
/// * **Text Mode**: Standard text input with expandable field
/// * **Voice Mode**: Long-press recording with visual feedback modal
/// * **Edit Mode**: Specialized interface for modifying existing messages
///
/// Example usage:
/// ```dart
/// // Basic chat input widget
/// class ChatPage extends StatefulWidget {
///   @override
///   _ChatPageState createState() => _ChatPageState();
/// }
///
/// class _ChatPageState extends State<ChatPage> {
///   final TextEditingController _controller = TextEditingController();
///   final FocusNode _focusNode = FocusNode();
///   bool _isEditing = false;
///   String? _editingHint;
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: Column(
///         children: [
///           Expanded(child: ChatMessagesList()),
///           ChatInputWidget(
///             controller: _controller,
///             focusNode: _focusNode,
///             isEditing: _isEditing,
///             editingHint: _editingHint,
///             onSend: _handleSendMessage,
///             onCancelEdit: _handleCancelEdit,
///           ),
///         ],
///       ),
///     );
///   }
///
///   void _handleSendMessage() {
///     final text = _controller.text.trim();
///     if (text.isNotEmpty) {
///       if (_isEditing) {
///         _updateMessage(text);
///       } else {
///         _sendNewMessage(text);
///       }
///       _controller.clear();
///       _exitEditMode();
///     }
///   }
///
///   void _handleCancelEdit() {
///     setState(() {
///       _isEditing = false;
///       _editingHint = null;
///     });
///   }
/// }
///
/// // Voice recording integration
/// ChatInputWidget(
///   controller: messageController,
///   focusNode: messageFocus,
///   onSend: () {
///     context.read<ChatBloc>().add(
///       SendMessageEvent(messageController.text),
///     );
///     messageController.clear();
///   },
/// )
/// ```
class ChatInputWidget extends StatefulWidget {

  /// Creates a chat input widget.
  ///
  /// The [controller], [onSend], and [focusNode] parameters are required
  /// for basic functionality. The editing-related parameters are optional
  /// and enable advanced message editing capabilities.
  ///
  /// [controller] Text editing controller for input management
  /// [onSend] Callback for handling message sending
  /// [focusNode] Focus node for input field control
  /// [isEditing] Whether the widget is in editing mode (defaults to false)
  /// [editingHint] Optional hint text for editing mode
  /// [onCancelEdit] Optional callback for cancelling edit mode
  const ChatInputWidget({
    super.key,
    required this.controller,
    required this.onSend,
    required this.focusNode,
    this.isEditing = false,
    this.editingHint,
    this.onCancelEdit,
  });
  /// Text editing controller for the input field.
  ///
  /// This controller manages the text content of the input field and should
  /// be managed by the parent widget. The controller is used for both
  /// regular message composition and message editing scenarios.
  ///
  /// The parent should clear the controller after successful message sending.
  final TextEditingController controller;
  
  /// Callback invoked when the send button is pressed or a voice message is complete.
  ///
  /// This callback should handle the message sending logic, including validation,
  /// BLoC event dispatch, and any necessary UI updates. The callback is triggered
  /// by both text message sending and voice message completion.
  ///
  /// For text messages, the controller's text should be retrieved and processed.
  /// For voice messages, the text is automatically populated in the controller
  /// before this callback is invoked.
  final VoidCallback onSend;
  
  /// Focus node for the text input field.
  ///
  /// This focus node should be managed by the parent widget and is used for
  /// controlling keyboard visibility and input focus. Proper focus management
  /// ensures a smooth user experience during chat interactions.
  final FocusNode focusNode;
  
  /// Whether the widget is in message editing mode.
  ///
  /// When true, the widget displays an editing indicator bar and modifies
  /// the input placeholder text. The voice recording button is hidden during
  /// editing mode to focus on text-based editing.
  ///
  /// Defaults to false for normal message composition.
  final bool isEditing;
  
  /// Hint text displayed in the editing mode indicator.
  ///
  /// This optional text provides context about what is being edited,
  /// such as showing a preview of the original message content. When null,
  /// a default "Editing message" text is displayed.
  ///
  /// Only relevant when [isEditing] is true.
  final String? editingHint;
  
  /// Callback invoked when the user cancels message editing.
  ///
  /// This optional callback is triggered when the user taps the close button
  /// in the editing mode indicator. The parent should handle exiting edit mode
  /// and restoring the normal chat input state.
  ///
  /// If null, the close button is not displayed in edit mode.
  final VoidCallback? onCancelEdit;

  @override
  ChatInputWidgetState createState() => ChatInputWidgetState();
}

class ChatInputWidgetState extends State<ChatInputWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late bool _isEditing;
  late String? _editingHint;
  late VoidCallback? _onCancelEdit;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _focusNode = widget.focusNode;
    _isEditing = widget.isEditing;
    _editingHint = widget.editingHint;
    _onCancelEdit = widget.onCancelEdit;
  }

  @override
  void didUpdateWidget(ChatInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isEditing = widget.isEditing;
    _editingHint = widget.editingHint;
    _onCancelEdit = widget.onCancelEdit;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (_isEditing)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.extension<CustomColors>()!.primarySubtle,
              border: Border(
                bottom: BorderSide(
                  color: theme.extension<CustomColors>()!.primaryMuted,
                ),
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(Icons.edit, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _editingHint ?? 'Editing message',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_onCancelEdit != null)
                  GestureDetector(
                    onTap: _onCancelEdit,
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),

        Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 32,
            bottom: 32,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  child: SingleChildScrollView(
                    child: TextField(
                      onTapOutside: (event) {
                        _focusNode.unfocus();
                      },
                      focusNode: _focusNode,
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText:
                            _isEditing ? 'Edit your message...' : 'Message',
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      style: theme.textTheme.bodyLarge,
                      maxLines: null,
                      minLines: 1,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Voice recording button - only show when not editing
              if (!_isEditing) ...[
                _VoiceLongPressButton(
                  onRecordingComplete: (recognizedText) {
                    if (recognizedText.isNotEmpty) {
                      _controller.text = recognizedText;
                      // Send message immediately
                      widget.onSend();
                    }
                  },
                  onRecordingCancel: () {
                    // Do nothing, recording cancelled
                  },
                ),
                const SizedBox(width: 8),
              ],

              // Send button
              IconButton(
                onPressed: widget.onSend,
                icon: SvgPicture.asset(
                  'assets/images/send_icon.svg',
                  width: 32,
                  height: 32,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VoiceLongPressButton extends StatefulWidget {

  const _VoiceLongPressButton({
    required this.onRecordingComplete,
    required this.onRecordingCancel,
  });
  final void Function(String text) onRecordingComplete;
  final VoidCallback onRecordingCancel;

  @override
  State<_VoiceLongPressButton> createState() => _VoiceLongPressButtonState();
}

class _VoiceLongPressButtonState extends State<_VoiceLongPressButton> {
  Offset? _startPosition;
  bool _isCancelling = false;
  late VoiceRecordingBloc _voiceBloc;

  void _showVoiceRecordingModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (modalContext) {
        return VoiceRecordingBottomModal(
          voiceBloc: _voiceBloc,
          onComplete: widget.onRecordingComplete,
          onCancel: widget.onRecordingCancel,
        );
      },
    );
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    HapticFeedback.mediumImpact();
    _startPosition = details.globalPosition;
    _isCancelling = false;
    _voiceBloc.add(const StartVoiceRecordingEvent());
    _showVoiceRecordingModal();
  }

  void _handleLongPressMove(LongPressMoveUpdateDetails details) {
    if (_startPosition == null) {
      return;
    }
    final dy = details.globalPosition.dy - _startPosition!.dy;
    // If user dragged up more than 80 pixels, mark as cancel
    if (dy < -80) {
      if (!_isCancelling) {
        setState(() {
          _isCancelling = true;
        });
      }
    } else {
      if (_isCancelling) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    if (_isCancelling) {
      _voiceBloc.add(
        CancelVoiceRecordingEvent(
          onCancel: () {
            widget.onRecordingCancel();
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
      );
    } else {
      _voiceBloc.add(
        StopVoiceRecordingEvent(
          onComplete: (text) {
            widget.onRecordingComplete(text);
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
      );
    }

    // Reset state
    _startPosition = null;
    _isCancelling = false;
  }

  @override
  void initState() {
    super.initState();
    _voiceBloc = di.sl<VoiceRecordingBloc>();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: _handleLongPressStart,
      onLongPressMoveUpdate: _handleLongPressMove,
      onLongPressEnd: _handleLongPressEnd,
      onTap: () {},
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surface,
          border: Border.all(
            color: theme.extension<CustomColors>()!.onSurfaceSubtle,
          ),
        ),
        child: Icon(
          _isCancelling ? Icons.delete : Icons.mic,
          color:
              _isCancelling
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
          size: 24,
        ),
      ),
    );
  }
}
