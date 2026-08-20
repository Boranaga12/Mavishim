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
  int _phase =
      0; // 0: accumulating Rights, 1: got >=2 Rights, accumulating Lefts

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
    if (state == AppLifecycleState.resumed || !_isUnlocked) return;
    // Bottom sheets, dialogs and pushed game pages live above this widget's
    // route. Close them before presenting the privacy screen so no panel can
    // remain visible over the lock after the app returns to foreground.
    Navigator.maybeOf(
      context,
      rootNavigator: true,
    )?.popUntil((route) => route.isFirst);
    setState(_lock);
  }

  void _handleTap(TapDownDetails details, double screenWidth) {
    if (_isUnlocked) return;
    _handleSide(details.localPosition.dx >= (screenWidth / 2));
  }

  void _handleSide(bool isRightSide) {
    if (_isUnlocked) return;

    if (isRightSide) {
      // User tapped RIGHT side
      if (_phase == 0) {
        _rightCount++;
        if (_rightCount >= 2) {
          _phase = 1;
        }
      } else if (_phase == 1) {
        if (_leftCount == 0) {
          // Still accumulating extra Right taps (e.g., 3rd, 4th, 5th Right tap)
          _rightCount++;
        } else if (_leftCount >= 2) {
          // Final Right tap after at least 2 Lefts -> UNLOCK!
          setState(() {
            _isUnlocked = true;
          });
        } else {
          // Tapped Right too early (only 1 Left tapped) -> Reset
          _resetLock(startWithRight: true);
        }
      }
    } else {
      // User tapped LEFT side
      if (_phase == 0 || _rightCount < 2) {
        // Tapped Left before getting at least 2 Rights -> Reset
        _resetLock();
      } else if (_phase == 1) {
        // Accumulating Left taps after >=2 Rights
        _leftCount++;
      }
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
    if (_isUnlocked) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Semantics(
            label: 'Gizli kilit ekranı',
            hint: 'Tanımlı dokunma veya yön tuşu dizisini girin.',
            child: Focus(
              autofocus: true,
              onKeyEvent: _handleKeyEvent,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) =>
                    _handleTap(details, constraints.maxWidth),
                child: const ColoredBox(
                  color: Colors.black,
                  child: SizedBox.expand(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
