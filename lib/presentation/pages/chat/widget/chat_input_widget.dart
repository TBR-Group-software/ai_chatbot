import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ai_chat_bot/core/theme/app_theme.dart';
import '../../../widgets/voice_recording_bottom_modal.dart';
import '../../../bloc/voice_recording/voice_recording_bloc.dart';
import 'package:ai_chat_bot/core/dependency_injection/dependency_injection.dart'
    as di;

class ChatInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final FocusNode focusNode;
  final bool isEditing;
  final String? editingHint;
  final VoidCallback? onCancelEdit;

  const ChatInputWidget({
    super.key,
    required this.controller,
    required this.onSend,
    required this.focusNode,
    this.isEditing = false,
    this.editingHint,
    this.onCancelEdit,
  });

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
                  width: 1,
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
  final void Function(String text) onRecordingComplete;
  final VoidCallback onRecordingCancel;

  const _VoiceLongPressButton({
    required this.onRecordingComplete,
    required this.onRecordingCancel,
  });

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
    if (_startPosition == null) return;
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
            width: 1,
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
