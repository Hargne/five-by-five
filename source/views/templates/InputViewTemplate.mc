using Toybox.Graphics;
using Toybox.Lang;
using Toybox.Math;
using Toybox.Timer;
using Toybox.WatchUi;
using Toybox.System;

class InputViewTemplate extends WatchUi.View {
  var _title;
  var _min;
  var _max;
  var _onSelect;
  var _onCancel;

  var _currentValue = 0;
  var _editingDecimal = false;
  var _decimalPlaces = 1;
  var _decimalStep = 5;

  // Garmin's built-in fonts (FONT_NUMBER_* especially) report a getFontHeight() that
  // includes headroom above the visible digit ink, so centering by the full height
  // renders the digits slightly low. Nudge upward by this fraction of the font height
  // to compensate; tune by eye in the simulator/device if the fit changes.
  const INTEGER_FONT_TOP_PADDING_RATIO = 0.08;

  function initialize(title, min, max, startValue, onSelect, onCancel) {
    _title = title;
    _min = min;
    _max = max;
    _currentValue = startValue;
    _onSelect = onSelect;
    _onCancel = onCancel;

    View.initialize();
  }

  function setTitle(title) {
    _title = title;
    WatchUi.requestUpdate();
  }

  function onUpdate(dc) {
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    dc.clear();

    var width = dc.getWidth();
    var height = dc.getHeight();
    var centerX = width / 2;
    var centerY = height / 2;

    var selectedHeight = height * 0.40;
    var normalHeight = height * 0.30;

    var titleHeight = ((height - selectedHeight) / 2).toNumber();
    var titleFont = Graphics.FONT_TINY;
    var titleTextHeight = dc.getFontHeight(titleFont);
    var selectedCenterY = 0;

    // Title
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.drawText(centerX, ((titleHeight - titleTextHeight) / 2) + (titleHeight * 0.10), titleFont, _title, Graphics.TEXT_JUSTIFY_CENTER);

    // Background
    var backgroundHeight = height - titleHeight;
    var backgroundY = titleHeight;
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.fillRectangle(0, backgroundY, width, backgroundHeight);

    // Current Value
    
    // Grab the current value as two variables: the integer part and the decimal part,
    // zero-padded so its length always matches _decimalPlaces (e.g. 2 places -> "05").
    var integerPart = _currentValue.toNumber();
    var decimalMultiplier = Math.pow(10, _decimalPlaces).toNumber();
    var decimalPart = Math.round((_currentValue - integerPart) * decimalMultiplier).toNumber().format("%0" + _decimalPlaces.toString() + "d");

    // Draw the integer part large and the ".decimal" part smaller next to it,
    // matching how native Garmin number-edit screens present a value.
    var integerText = integerPart.toString();
    var decimalText = " . " + decimalPart;
    
    var integerFont = Graphics.FONT_NUMBER_HOT;
    var decimalFont = Graphics.FONT_NUMBER_MILD;

    var integerWidth = dc.getTextWidthInPixels(integerText, integerFont);
    var decimalWidth = dc.getTextWidthInPixels(decimalText, decimalFont);

    var integerFontHeight = dc.getFontHeight(integerFont);
    var integerVerticalNudge = (integerFontHeight * INTEGER_FONT_TOP_PADDING_RATIO).toNumber();
    var integerY = backgroundY + (backgroundHeight / 2) - (integerFontHeight / 2) - integerVerticalNudge;
    var integerX = centerX;

    var decimalX = integerX + (integerWidth / 2) + (decimalWidth / 2);
    var decimalY = integerY + (integerFontHeight - dc.getFontHeight(decimalFont)) / 2;

    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
    dc.drawText(integerX, integerY, integerFont, integerText, Graphics.TEXT_JUSTIFY_CENTER);
    dc.drawText(decimalX, decimalY, decimalFont, decimalText, Graphics.TEXT_JUSTIFY_CENTER);

    // Draw a line under the current value to indicate that it's editable.
    var lineY = integerY + integerFontHeight - 5;
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
    dc.setPenWidth(2);
    dc.drawLine(integerX - (integerWidth / 2) - 10, lineY, integerX + (integerWidth / 2) + 10, lineY);
    dc.drawLine(integerX - (integerWidth / 2) - 10, lineY - 10, integerX - (integerWidth / 2) - 10, lineY);
    dc.drawLine(integerX + (integerWidth / 2) + 10, lineY - 10, integerX + (integerWidth / 2) + 10, lineY);
    dc.setPenWidth(1);
  }

  function handleDownPress() {
    if (_currentValue >= _max) {
        return;
    }
    _currentValue = _currentValue + 1;
    System.println("Current value: " + _currentValue);
    WatchUi.requestUpdate();
  }

  function handleUpPress() {
    if (_currentValue <= _min) {
        return;
    }
    _currentValue = _currentValue - 1;
    System.println("Current value: " + _currentValue);
    WatchUi.requestUpdate();
  }

  function handleLapPress() {
    if (_onSelect == null) {
      return;
    }
    _onSelect.invoke(_currentValue);
  }

  function handleBackPress() {
    if (_onCancel == null) {
      return false;
    }

    _onCancel.invoke();
    return true;
  }
}