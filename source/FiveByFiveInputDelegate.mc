using Toybox.Lang;
using Toybox.System;
using Toybox.WatchUi;

class FiveByFiveInputDelegate extends WatchUi.BehaviorDelegate {
    const HOLD_MS = 700;

    var _view;
    var _upPressedAt;
    var _upHandledAt;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
        _upPressedAt = 0;
        _upHandledAt = 0;
    }

    function onKeyPressed(keyEvent) as Lang.Boolean {
        var key = keyEvent.getKey();

        if (_isLapKey(key)) {
            _view.handleLapPress();
            return true;
        }

        if (_isDownKey(key)) {
            _view.handleDownPress();
            return true;
        }

        if (_isBackKey(key)) {
            return _handleBackPress();
        }

        if (_isUpKey(key)) {
            _upPressedAt = System.getTimer();
            _upHandledAt = _upPressedAt;
            return true;
        }

        return false;
    }

    function onKeyReleased(keyEvent) as Lang.Boolean {
        var key = keyEvent.getKey();
        if (_isBackKey(key)) {
            return true;
        }
        if (_isUpKey(key)) {
            var heldFor = System.getTimer() - _upPressedAt;
            if (heldFor >= HOLD_MS) {
                _view.handleUpHold();
            } else {
                _view.handleUpPress();
            }
            return true;
        }
        return false;
    }

    function onKey(keyEvent) as Lang.Boolean {
        var key = keyEvent.getKey();
        if (_isBackKey(key)) {
            return _handleBackPress();
        }

        // Other key handling is done in onKeyPressed/onKeyReleased to support FR245 START/STOP behavior.
        return false;
    }

    function onBack() as Lang.Boolean {
        return _handleBackPress();
    }

    function onPreviousPage() as Lang.Boolean {
        // On devices where the up key already triggered handleUpPress/handleUpHold,
        // the system also echoes it as onPreviousPage; ignore that echo.
        if (System.getTimer() - _upHandledAt < HOLD_MS) {
            return true;
        }
        return _handleBackPress();
    }

    function _handleBackPress() as Lang.Boolean {
        _view.handleBackPress();
        return true;
    }

    function _isLapKey(key) {
        if ((WatchUi has :KEY_LAP) && (key == WatchUi.KEY_LAP)) {
            return true;
        }
        if ((WatchUi has :KEY_ENTER) && (key == WatchUi.KEY_ENTER)) {
            return true;
        }
        if ((WatchUi has :KEY_START) && (key == WatchUi.KEY_START)) {
            return true;
        }
        return false;
    }

    function _isUpKey(key) {
        return (WatchUi has :KEY_UP) && (key == WatchUi.KEY_UP);
    }

    function _isBackKey(key) {
        if ((WatchUi has :KEY_ESC) && (key == WatchUi.KEY_ESC)) {
            return true;
        }
        if ((WatchUi has :KEY_BACK) && (key == WatchUi.KEY_BACK)) {
            return true;
        }
        return false;
    }

    function _isDownKey(key) {
        return (WatchUi has :KEY_DOWN) && (key == WatchUi.KEY_DOWN);
    }
}
