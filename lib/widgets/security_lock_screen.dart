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
  bool _isUnlocked = false;
  int _rightCount = 0;
  int _leftCount = 0;
  int _phase = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed || !_isUnlocked || !mounted) return;
    setState(_lock);
  }

  void _handleTap(TapDownDetails details, double width) {
    if (!_isUnlocked) _handleSide(details.localPosition.dx >= width / 2);
  }

  void _handleSide(bool right) {
    if (_isUnlocked) return;
    if (right) {
      if (_phase == 0) {
        _rightCount++;
        if (_rightCount >= 2) _phase = 1;
      } else if (_leftCount == 0) {
        _rightCount++;
      } else if (_leftCount >= 2) {
        setState(() {
          _isUnlocked = true;
          _resetLock();
        });
      } else {
        _resetLock(startWithRight: true);
      }
    } else if (_phase == 1 && _rightCount >= 2) {
      _leftCount++;
    } else {
      _resetLock();
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
    _resetLock();
  }

  void _resetLock({bool startWithRight = false}) {
    _rightCount = startWithRight ? 1 : 0;
    _leftCount = 0;
    _phase = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Keep the navigator laid out behind the opaque lock so unlocking does
        // not trigger an expensive full-tree layout. Input, semantics and
        // tickers remain disabled while the black lock is visible.
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
                    autofocus: true,
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
