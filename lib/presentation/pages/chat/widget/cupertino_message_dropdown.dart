import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ai_chat_bot/core/theme/app_theme.dart';

class CupertinoMessageDropdown {
  static OverlayEntry? _currentOverlay;
  static GlobalKey? _highlightedMessageKey;
  static final ValueNotifier<GlobalKey?> _highlightNotifier =
      ValueNotifier<GlobalKey?>(null);

  static ValueNotifier<GlobalKey?> get highlightNotifier => _highlightNotifier;

  static void show({
    required BuildContext context,
    required GlobalKey messageKey,
    required LayerLink layerLink,
    required Widget messageWidget,
    required bool isUserMessage,
    required String messageText,
    required VoidCallback onCopy,
    VoidCallback? onEdit,
  }) {
    // Dismiss any existing dropdown
    dismiss();

    // Store the message key for highlighting
    _highlightedMessageKey = messageKey;
    _highlightNotifier.value = messageKey;

    // Ensure the message is visible on screen first, then show dropdown
    _ensureMessageVisible(messageKey, () {
      // Get message position and size after scroll animation completes
      final messageRenderBox =
          messageKey.currentContext?.findRenderObject() as RenderBox?;
      
      if (messageRenderBox == null) {
        return;
      }
      
      // Get position relative to the screen (accounting for scroll)
      final messagePosition = messageRenderBox.localToGlobal(Offset.zero);
      final messageSize = messageRenderBox.size;

      // Create and show the overlay
      _currentOverlay = _createOverlayEntry(
        context: context,
        messageKey: messageKey,
        layerLink: layerLink,
        messageWidget: messageWidget,
        messagePosition: messagePosition,
        messageSize: messageSize,
        isUserMessage: isUserMessage,
        messageText: messageText,
        onCopy: onCopy,
        onEdit: onEdit,
      );

      Overlay.of(context).insert(_currentOverlay!);
    });
  }

  static void dismiss() {
    _currentOverlay?.remove();
    _currentOverlay = null;
    _highlightedMessageKey = null;
    _highlightNotifier.value = null;
  }

  static bool get isMessageHighlighted => _highlightedMessageKey != null;
  static GlobalKey? get highlightedMessageKey => _highlightedMessageKey;

  static void _ensureMessageVisible(
    GlobalKey messageKey,
    VoidCallback onComplete,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = messageKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ).then((_) {
          // Wait a bit more for the scroll to fully complete, then show dropdown
          Future.delayed(const Duration(milliseconds: 50), onComplete);
        });
      } else {
        // If no context, show dropdown immediately
        onComplete();
      }
    });
  }

  static OverlayEntry _createOverlayEntry({
    required BuildContext context,
    required GlobalKey messageKey,
    required LayerLink layerLink,
    required Widget messageWidget,
    required Offset messagePosition,
    required Size messageSize,
    required bool isUserMessage,
    required String messageText,
    required VoidCallback onCopy,
    VoidCallback? onEdit,
  }) {
    return OverlayEntry(
      builder: (overlayContext) => _CupertinoDropdownOverlay(
        context: context,
        messageKey: messageKey,
        layerLink: layerLink,
        messageWidget: messageWidget,
        messagePosition: messagePosition,
        messageSize: messageSize,
        isUserMessage: isUserMessage,
        messageText: messageText,
        onCopy: onCopy,
        onEdit: onEdit,
        onDismiss: dismiss,
      ),
    );
  }
}

class _CupertinoDropdownOverlay extends StatefulWidget {

  const _CupertinoDropdownOverlay({
    required this.context,
    required this.messageKey,
    required this.layerLink,
    required this.messageWidget,
    required this.messagePosition,
    required this.messageSize,
    required this.isUserMessage,
    required this.messageText,
    required this.onCopy,
    required this.onEdit,
    required this.onDismiss,
  });
  final BuildContext context;
  final GlobalKey messageKey;
  final LayerLink layerLink;
  final Widget messageWidget;
  final Offset messagePosition;
  final Size messageSize;
  final bool isUserMessage;
  final String messageText;
  final VoidCallback onCopy;
  final VoidCallback? onEdit;
  final VoidCallback onDismiss;

  @override
  State<_CupertinoDropdownOverlay> createState() =>
      _CupertinoDropdownOverlayState();
}

class _CupertinoDropdownOverlayState extends State<_CupertinoDropdownOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  Offset? _dropdownPosition;
  Size _dropdownSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculatePosition();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _calculatePosition() {
    final adjustedMessageTop = _getAdjustedMessageTop();
    final messageSize = widget.messageSize;
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    // Calculate dropdown size (approximate)
    final itemCount =
        widget.isUserMessage ? 2 : 1; // Edit + Copy OR Copy only
    const itemHeight = 56.0;
    const paddingVertical = 16.0;
    _dropdownSize = Size(280, (itemHeight * itemCount) + paddingVertical);

    // Available space calculations using adjusted message position
    final availableSpaceBelow = screenSize.height -
        adjustedMessageTop -
        messageSize.height -
        padding.bottom -
        50; // Safe area
    final availableSpaceAbove = adjustedMessageTop - padding.top - 50;

    // Determine position - align to left bottom of message
    if (availableSpaceBelow >= _dropdownSize.height) {
      // Show below, aligned to left of message
      _dropdownPosition = Offset(
        widget.messagePosition.dx, // Align to left edge of message
        adjustedMessageTop + messageSize.height + 8,
      );
    } else if (availableSpaceAbove >= _dropdownSize.height) {
      // Show above, aligned to left of message
      _dropdownPosition = Offset(
        widget.messagePosition.dx, // Align to left edge of message
        adjustedMessageTop - _dropdownSize.height - 8,
      );
    } else {
      // Limited space, prefer below, aligned to left of message
      _dropdownPosition = Offset(
        widget.messagePosition.dx, // Align to left edge of message
        adjustedMessageTop + messageSize.height + 8,
      );
    }

    // Ensure dropdown doesn't go off screen horizontally
    if (_dropdownPosition!.dx + _dropdownSize.width > screenSize.width - 16) {
      _dropdownPosition = Offset(
        screenSize.width - _dropdownSize.width - 16,
        _dropdownPosition!.dy,
      );
    }

    // Ensure dropdown doesn't go off screen on the left
    if (_dropdownPosition!.dx < 16) {
      _dropdownPosition = Offset(16, _dropdownPosition!.dy);
    }

    // Ensure dropdown doesn't go off screen vertically
    if (_dropdownPosition!.dy < padding.top + 50) {
      _dropdownPosition = Offset(_dropdownPosition!.dx, padding.top + 50);
    }
    
    if (_dropdownPosition!.dy + _dropdownSize.height > screenSize.height - padding.bottom - 50) {
      _dropdownPosition = Offset(
        _dropdownPosition!.dx, 
        screenSize.height - padding.bottom - _dropdownSize.height - 50,
      );
    }

    setState(() {});
  }

  void _dismissWithAnimation() {
    _animationController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  double _getAdjustedMessageTop() {
    final messagePosition = widget.messagePosition;
    final messageSize = widget.messageSize;
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    // Calculate available space
    final availableHeight = screenSize.height - padding.top - padding.bottom - 100;
    
    // If message is taller than available space, position it at the top
    if (messageSize.height > availableHeight) {
      return padding.top + 50; // Small top margin
    }
    
    // If message would extend beyond bottom, adjust position
    if (messagePosition.dy + messageSize.height > screenSize.height - padding.bottom - 50) {
      return screenSize.height - padding.bottom - messageSize.height - 50;
    }
    
    // If message would be above top, position it at top
    if (messagePosition.dy < padding.top + 50) {
      return padding.top + 50;
    }
    
    // Use original position if it fits
    return messagePosition.dy;
  }

  void _handleCopy() {
    HapticFeedback.selectionClick();
    Clipboard.setData(ClipboardData(text: widget.messageText));
    _dismissWithAnimation();

    // Show styled snackbar
    ScaffoldMessenger.of(widget.context).showSnackBar(
      SnackBar(
        content: Text(
          'Message copied',
          style: Theme.of(widget.context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(widget.context).colorScheme.onPrimary,
              ),
        ),
        backgroundColor: Theme.of(widget.context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(milliseconds: 1500),
        elevation: 4,
      ),
    );
  }

  void _handleEdit() {
    HapticFeedback.selectionClick();
    widget.onEdit?.call();
    _dismissWithAnimation();
  }

  @override
  Widget build(BuildContext context) {
    if (_dropdownPosition == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Blurred background (covers full screen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _dismissWithAnimation,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ),
            ),

            // Render the message on top of the blur at absolute position
            Positioned(
              left: widget.messagePosition.dx,
              top: _getAdjustedMessageTop(),
              child: IgnorePointer(
                child: Material(
                  type: MaterialType.transparency,
                  child: SizedBox(
                    width: widget.messageSize.width,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        // Constrain the height to the screen's safe area
                        maxHeight: MediaQuery.of(context).size.height -
                            MediaQuery.of(context).viewPadding.top -
                            MediaQuery.of(context).viewPadding.bottom -
                            100, // Extra padding for safety
                      ),
                      child: SingleChildScrollView(
                        child: widget.messageWidget,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Dropdown menu
            Positioned(
              left: _dropdownPosition!.dx,
              top: _dropdownPosition!.dy,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: _CupertinoDropdownMenu(
                      isUserMessage: widget.isUserMessage,
                      onCopy: _handleCopy,
                      onEdit: widget.isUserMessage ? _handleEdit : null,
                      onCancel: _dismissWithAnimation,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CupertinoDropdownMenu extends StatelessWidget {

  const _CupertinoDropdownMenu({
    required this.isUserMessage,
    required this.onCopy,
    required this.onEdit,
    required this.onCancel,
  });
  final bool isUserMessage;
  final VoidCallback onCopy;
  final VoidCallback? onEdit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>()!;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: customColors.dropdownBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Action items
            if (isUserMessage && onEdit != null)
              _CupertinoDropdownItem(
                icon: Icons.edit,
                title: 'Edit',
                onTap: onEdit!,
                isFirst: true,
              ),
            _CupertinoDropdownItem(
              icon: Icons.copy,
              title: 'Copy',
              onTap: onCopy,
              isFirst: !isUserMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _CupertinoDropdownItem extends StatefulWidget {

  const _CupertinoDropdownItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isFirst = false,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isFirst;

  @override
  State<_CupertinoDropdownItem> createState() => _CupertinoDropdownItemState();
}

class _CupertinoDropdownItemState extends State<_CupertinoDropdownItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>()!;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: _isPressed ? customColors.dropdownItemPressed : Colors.transparent,
          border: widget.isFirst
              ? null
              : Border(
                  top: BorderSide(
                    color: customColors.dropdownBorder,
                    width: 0.5,
                  ),
                ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: customColors.dropdownIcon,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: customColors.dropdownText,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

 
