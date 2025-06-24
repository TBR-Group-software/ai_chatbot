import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom painter for real-time audio waveform visualization
class AudioWaveformPainter extends CustomPainter {

  const AudioWaveformPainter({
    required this.soundLevel,
    required this.animationValue,
    required this.waveformColor,
    required this.isListening,
    required this.isRecording,
  });
  /// The sound level of the audio
  final double soundLevel;
  /// The animation value of the audio
  /// 
  /// This is used to animate the waveform
  final double animationValue;
  /// The color of the waveform
  final Color waveformColor;
  /// Whether the user is listening
  final bool isListening;
  /// Whether the user is recording
  final bool isRecording;

  @override
  void paint(Canvas canvas, Size size) {
    if (!isRecording) {
      return;
    }

    final paint = Paint()
      ..color = waveformColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final width = size.width - 32; // Account for padding
    final height = size.height - 16; // Account for padding
    final centerY = size.height / 2;
    const centerX = 16.0; // Left padding

    // Number of bars in the waveform
    const barCount = 25;
    final barWidth = width / barCount;

    for (var i = 0; i < barCount; i++) {
      final x = centerX + (i * barWidth) + (barWidth / 2);

      // Create animated wave effect based on real sound level
      final wavePhase = (animationValue * 4 * math.pi) + (i * 0.5);
      final baseHeight = math.sin(wavePhase) * 8 + 12;

      // Apply real sound level influence (speech_to_text provides 0.0 to 1.0)
      final normalizedSoundLevel = soundLevel.clamp(0.0, 1.0);
      final soundMultiplier =
          isListening ? (0.5 + normalizedSoundLevel * 1.5) : 0.3;

      final barHeight = (baseHeight * soundMultiplier).clamp(4.0, height * 0.7);

      // Add some randomness for natural look
      final randomVariation = math.sin(i * 0.7 + animationValue * 2) * 3;
      final finalHeight = (barHeight + randomVariation).clamp(
        4.0,
        height * 0.7,
      );

      // Draw the bar
      canvas.drawLine(
        Offset(x, centerY - finalHeight / 2),
        Offset(x, centerY + finalHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint for real-time updates
  }
} 
