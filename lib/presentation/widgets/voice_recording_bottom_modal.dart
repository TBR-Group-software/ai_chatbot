import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ai_chat_bot/core/theme/app_theme.dart';
import 'package:ai_chat_bot/presentation/bloc/voice_recording/voice_recording_bloc.dart';
import 'package:ai_chat_bot/presentation/widgets/circular_icon_button.dart';
import 'package:ai_chat_bot/presentation/widgets/voice_recording_controls.dart';

/// Modern bottom modal for voice recording with real-time audio visualization
/// Follows clean architecture and project design patterns
class VoiceRecordingBottomModal extends StatefulWidget {

  const VoiceRecordingBottomModal({
    super.key,
    required this.voiceBloc,
    this.onComplete,
    this.onCancel,
  });
  final void Function(String text)? onComplete;
  final VoidCallback? onCancel;
  final VoiceRecordingBloc voiceBloc;

  @override
  State<VoiceRecordingBottomModal> createState() =>
      _VoiceRecordingBottomModalState();
}

class _VoiceRecordingBottomModalState extends State<VoiceRecordingBottomModal>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    // Start animations
    _slideController.forward();
    _waveController.repeat();

    // Start recording immediately when modal opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.voiceBloc.add(const StartVoiceRecordingEvent());
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _handleStop() {
    widget.voiceBloc.add(
      StopVoiceRecordingEvent(
        onComplete: (text) {
          widget.onComplete?.call(text);
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  void _handleCancel() {
    widget.voiceBloc.add(
      CancelVoiceRecordingEvent(
        onCancel: () {
          widget.onCancel?.call();
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>()!;

    return FractionallySizedBox(
      heightFactor: 0.32,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            boxShadow: [
              BoxShadow(
                color: customColors.modalShadow,
                blurRadius: 20,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: BlocBuilder<VoiceRecordingBloc, VoiceRecordingState>(
            bloc: widget.voiceBloc,
            builder: (context, state) {
              return Row(
                children: [
                  // Cancel button
                  CircularIconButton(
                    icon: Icons.close,
                    backgroundColor: customColors.cancelButtonBackground,
                    iconColor: Colors.white,
                    onTap: _handleCancel,
                  ),
                  const SizedBox(width: 24),
                  // Waveform and timer
                  VoiceRecordingControls(
                    state: state,
                    waveController: _waveController,
                    theme: theme,
                    customColors: customColors,
                  ),
                  const SizedBox(width: 24),
                  // Send button
                  GestureDetector(
                    onTap: _handleStop,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary,
                      ),
                      child:
                          state.isStopping
                              ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.onPrimary,
                                ),
                              )
                              : SvgPicture.asset(
                                'assets/images/send_icon.svg',
                                width: 32,
                                height: 32,
                              ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
