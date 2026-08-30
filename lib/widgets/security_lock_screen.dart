import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SecurityLockScreen extends StatefulWidget {
  final Widget child;

  const SecurityLockScreen({super.key, required this.child});

  @override
  State<SecurityLockScreen> createState() => _SecurityLockScreenState();
}

class _SecurityLockScreenState extends State<SecurityLockScreen>
    with WidgetsBindingObserver {
  // Sağ, sağ, sol, sol, sağ, sağ, sağ, sol.
  static const _unlockSequence = <bool>[
    true,
    true,
    false,
    false,
    true,
    true,
    true,
    false,
  ];
  static const _maxInputGap = Duration(seconds: 2);
  static const _lockoutDuration = Duration(seconds: 15);
  static const _maxFailedAttempts = 4;

  bool _isUnlocked = false;
  int _sequenceIndex = 0;
  int _failedAttempts = 0;
  DateTime? _lastInputAt;
  DateTime? _lockedUntil;
  Timer? _lockoutTimer;
  final FocusNode _lockFocusNode = FocusNode(debugLabel: 'security-lock');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestLockFocus());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lockoutTimer?.cancel();
    _lockFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed || !mounted) return;
    // Also lock during `inactive`, before the app-switcher preview is made.
    setState(_lock);
  }

  void _handleTap(TapDownDetails details, double width) {
    if (!_isUnlocked) _handleSide(details.localPosition.dx >= width / 2);
  }

  void _handleSide(bool isRight) {
    if (_isUnlocked) return;
    final now = DateTime.now();
    final until = _lockedUntil;
    if (until != null && now.isBefore(until)) return;
    if (_lastInputAt != null && now.difference(_lastInputAt!) > _maxInputGap) {
      _clearEntry();
    }
    _lastInputAt = now;

    if (isRight != _unlockSequence[_sequenceIndex]) {
      _registerFailedAttempt();
      return;
    }

    _sequenceIndex++;
    _failedAttempts = 0;
    if (_sequenceIndex == _unlockSequence.length) {
      setState(() {
        _isUnlocked = true;
        _clearEntry();
      });
      _lockFocusNode.unfocus();
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _handleSide(true);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _handleSide(false);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _lock() {
    _isUnlocked = false;
    _clearEntry();
    _requestLockFocus();
  }

  void _clearEntry() {
    _sequenceIndex = 0;
    _lastInputAt = null;
  }

  void _registerFailedAttempt() {
    _clearEntry();
    _failedAttempts++;
    if (_failedAttempts < _maxFailedAttempts) return;

    _failedAttempts = 0;
    _lockedUntil = DateTime.now().add(_lockoutDuration);
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer(_lockoutDuration, () {
      if (!mounted) return;
      setState(() => _lockedUntil = null);
      _requestLockFocus();
    });
  }

  void _requestLockFocus() {
    if (!mounted || _isUnlocked) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isUnlocked) _lockFocusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          ignoring: !_isUnlocked,
          child: ExcludeSemantics(
            excluding: !_isUnlocked,
            child: TickerMode(enabled: _isUnlocked, child: widget.child),
          ),
        ),
        if (!_isUnlocked)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black,
              child: LayoutBuilder(
                builder: (context, constraints) => Semantics(
                  label: 'Gizli kilit ekranı',
                  hint: 'Tanımlı dokunma veya yön tuşu dizisini girin.',
                  child: Focus(
                    focusNode: _lockFocusNode,
                    onKeyEvent: _handleKeyEvent,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (details) =>
                          _handleTap(details, constraints.maxWidth),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
