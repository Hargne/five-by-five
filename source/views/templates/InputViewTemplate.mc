using Toybox.Graphics;
using Toybox.Lang;
using Toybox.Math;
using Toybox.Timer;
using Toybox.WatchUi;
using Toybox.System;

module FiveByFiveInputType {
  const NUMERIC = :NUMERIC;
  const TIME = :TIME;
}

class InputViewTemplate extends WatchUi.View {
  var _title;
  var _type;
  var minValue = 0;
  var maxValue = 0;
  var _onSelect;
  var _onCancel;

  var _currentValue = 0;
  var _parts = [];
  var _currentlyEditingPartIndex = 0;
  var _decimalPlaces = 1;
  var _decimalStep = 5;

  var _editFont = Graphics.FONT_NUMBER_HOT;
  var _nonEditFont = Graphics.FONT_NUMBER_MILD;

  // Garmin's built-in fonts (FONT_NUMBER_* especially) report a getFontHeight() that
  // includes headroom above the visible digit ink, so centering by the full height
  // renders the digits slightly low. Nudge upward by this fraction of the font height
  // to compensate; tune by eye in the simulator/device if the fit changes.
  const INTEGER_FONT_TOP_PADDING_RATIO = 0.08;

  function initialize(title, type, startValue, onSelect, onCancel) {
    _title = title;
    _type = type;
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

    _parts = extractParts();

    var editedValue = _parts[_currentlyEditingPartIndex];
    var editedValueWidth = dc.getTextWidthInPixels(editedValue, _editFont);
    var editedValueFontHeight = dc.getFontHeight(_editFont);
    var editedValueVerticalNudge = (editedValueFontHeight * INTEGER_FONT_TOP_PADDING_RATIO).toNumber();
    var editedValueY = backgroundY + (backgroundHeight / 2) - (editedValueFontHeight / 2) - editedValueVerticalNudge;
    var editedValueX = centerX;

    var delimiter = getDelimiter();

    var leftValue = (_currentlyEditingPartIndex > 0) ? _parts[_currentlyEditingPartIndex - 1] + delimiter + " " : null;
    var leftValueX = editedValueX - (editedValueWidth / 2);
    var leftValueY = editedValueY + (editedValueFontHeight - dc.getFontHeight(_nonEditFont)) / 2;

    var rightValue = (_currentlyEditingPartIndex < _parts.size() - 1) ? " " + delimiter + _parts[_currentlyEditingPartIndex + 1] : null;
    var rightValueWidth = (rightValue != null) ? dc.getTextWidthInPixels(rightValue, _nonEditFont) : 0;
    var rightValueX = editedValueX + (editedValueWidth / 2) + (rightValueWidth / 2);
    var rightValueY = editedValueY + (editedValueFontHeight - dc.getFontHeight(_nonEditFont)) / 2;

    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
    if (leftValue != null) {
      dc.drawText(leftValueX, leftValueY, _nonEditFont, leftValue, Graphics.TEXT_JUSTIFY_RIGHT);
    }
    dc.drawText(editedValueX, editedValueY, _editFont, editedValue, Graphics.TEXT_JUSTIFY_CENTER);
    if (rightValue != null) {
      dc.drawText(rightValueX, rightValueY, _nonEditFont, rightValue, Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Draw a line under the current value to indicate that it's editable.
    var lineY = editedValueY + editedValueFontHeight - 5;
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
    dc.setPenWidth(2);
    dc.drawLine(editedValueX - (editedValueWidth / 2) - 10, lineY, editedValueX + (editedValueWidth / 2) + 10, lineY);
    dc.drawLine(editedValueX - (editedValueWidth / 2) - 10, lineY - 10, editedValueX - (editedValueWidth / 2) - 10, lineY);
    dc.drawLine(editedValueX + (editedValueWidth / 2) + 10, lineY - 10, editedValueX + (editedValueWidth / 2) + 10, lineY);
    dc.setPenWidth(1);
  }

  function extractParts() {
    if (_type == FiveByFiveInputType.NUMERIC) {
      // Grab the current value as two variables: the integer part and the decimal part,
      // zero-padded so its length always matches _decimalPlaces (e.g. 2 places -> "05").
      var integerPart = _currentValue.toNumber();
      var decimalMultiplier = Math.pow(10, _decimalPlaces).toNumber();
      var decimalPart = Math.round((_currentValue - integerPart) * decimalMultiplier).toNumber().format("%0" + _decimalPlaces.toString() + "d");
      var integerText = integerPart.toString();
      var decimalText = decimalPart.toString();
      return [integerText, decimalText];
    }
    return [];
  }

  function getDelimiter() {
    switch (_type) {
      case FiveByFiveInputType.TIME:
        return ":";
      default:
        return ".";
    }
  }

  function handleDownPress() {
    if (_currentValue >= maxValue) {
        return;
    }
    _currentValue = roundToDecimals(_currentValue + Math.pow(10, -_currentlyEditingPartIndex));
    WatchUi.requestUpdate();
  }

  function handleUpPress() {
    if (_currentValue <= minValue) {
        return;
    }
    _currentValue = roundToDecimals(_currentValue - Math.pow(10, -_currentlyEditingPartIndex));
    WatchUi.requestUpdate();
  }

  function handleLapPress() {
    if (_currentlyEditingPartIndex < _parts.size() - 1) {
      _currentlyEditingPartIndex += 1;
      WatchUi.requestUpdate();
      return;
    }
    
    if (_onSelect == null) {
      return;
    }
    _onSelect.invoke(_currentValue);
  }

  function handleBackPress() {
    if (_currentlyEditingPartIndex > 0) {
      _currentlyEditingPartIndex -= 1;
      WatchUi.requestUpdate();
      return true;
    }

    if (_onCancel == null) {
      return false;
    }

    _onCancel.invoke();
    return true;
  }

  function roundToDecimals(value) {
    var multiplier = Math.pow(10, _decimalPlaces);
    return Math.round(value * multiplier) / multiplier;
  }
}