using Toybox.Graphics;
using Toybox.Lang;
using Toybox.Timer;
using Toybox.WatchUi;
using Toybox.System;

class FiveByFiveMainSelectionView extends WatchUi.View {
  var _title;
  var _options;
  var _selectedIndex = 0;
  var _onSelect;
  var _onBack;
  var _separatorHeight = 2;

  function initialize(title, options) {
    _title = title;
    _options = options as Lang.Array;
    _onSelect = null;
    _onBack = null;

    View.initialize();
  }

  function setTitle(title) {
    _title = title;
    WatchUi.requestUpdate();
  }

  function setOptions(options) {
    _options = options as Lang.Array;
    WatchUi.requestUpdate();
  }

  function setSelectedIndex(index) {
    var options = _options as Lang.Array;
    if (index < 0 || index >= options.size()) {
      System.println("Invalid index: " + index);
      return;
    }
    _selectedIndex = index;
    WatchUi.requestUpdate();
  }

  function assignOnSelectHandler(onSelect) {
    _onSelect = onSelect;
  }

  function assignOnBackHandler(onBack) {
    _onBack = onBack;
  }

  function onUpdate(dc) {
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    dc.clear();

    var width = dc.getWidth();
    var height = dc.getHeight();
    var centerX = width / 2;
    var centerY = height / 2;

    var options = _options as Lang.Array;
    var selectedHeight = height * 0.40;
    var normalHeight = height * 0.30;
    var titleHeight = ((height - selectedHeight) / 2).toNumber();
    var titleFont = Graphics.FONT_TINY;
    var titleTextHeight = dc.getFontHeight(titleFont);
    var selectedCenterY = 0;

    // Measure the selected option in the page's natural layout.
    var measuredOptionY = titleHeight;
    for (var i = 0; i < options.size(); i += 1) {
      var optionHeight = (i == _selectedIndex) ? selectedHeight : normalHeight;
      if (i == _selectedIndex) {
        selectedCenterY = measuredOptionY + (optionHeight / 2);
      }
      measuredOptionY += optionHeight + _separatorHeight;
    }

    var pageOffsetY = centerY - selectedCenterY;

    // Title
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.drawText(centerX, ((titleHeight - titleTextHeight) / 2) + pageOffsetY + (titleHeight * 0.10), titleFont, _title, Graphics.TEXT_JUSTIFY_CENTER);

    // Options
    var optionY = titleHeight + pageOffsetY;

    for (var i = 0; i < options.size(); i += 1) {
      var isSelected = (i == _selectedIndex);
      var optionHeight = isSelected ? selectedHeight : normalHeight;
      var option = options[i] as Lang.Array;
      var optionTitle = _getOptionTitle(option);
      var optionDescription = _getOptionDescription(option);
      var hasDescription = !optionDescription.equals("") && isSelected;

      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
      dc.fillRectangle(0, optionY, width, optionHeight);

      var font = isSelected ? Graphics.FONT_MEDIUM : Graphics.FONT_XTINY;
      var optionTitleTextHeight = dc.getFontHeight(font);
      var descriptionFont = Graphics.FONT_XTINY;
      var descriptionGap = hasDescription ? 3 : 0;
      var descriptionTextHeight = hasDescription ? dc.getFontHeight(descriptionFont) : 0;
      var textBlockHeight = optionTitleTextHeight + descriptionGap + descriptionTextHeight;
      var textY = optionY + ((optionHeight - textBlockHeight) / 2);
      dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
      dc.drawText(
        centerX,
        textY,
        font,
        optionTitle,
        Graphics.TEXT_JUSTIFY_CENTER
      );

      if (hasDescription) {
        dc.drawText(
          centerX,
          textY + optionTitleTextHeight + descriptionGap,
          descriptionFont,
          optionDescription,
          Graphics.TEXT_JUSTIFY_CENTER
        );
      }

      optionY += optionHeight + _separatorHeight;
    }
  }

  function _getOptionTitle(option) {
    var optionParts = option as Lang.Array;
    return optionParts[0] as Lang.String;
  }

  function _getOptionDescription(option) {
    var optionParts = option as Lang.Array;
    if (optionParts.size() < 2 || optionParts[1] == null) {
      return "";
    }
    return optionParts[1] as Lang.String;
  }

  function handleDownPress() {
    var options = _options as Lang.Array;
    if (_selectedIndex >= options.size() - 1) {
      return;
    }
    _selectedIndex = _selectedIndex + 1;
    WatchUi.requestUpdate();
  }

  function handleUpPress() {
    if (_selectedIndex <= 0) {
        return;
    }
    _selectedIndex = _selectedIndex - 1;
    WatchUi.requestUpdate();
  }

  function handleLapPress() {
    if (_onSelect == null) {
      return;
    }
    var options = _options as Lang.Array;
    var selectedOption = options[_selectedIndex] as Lang.Array;
    _onSelect.invoke(_selectedIndex, _getOptionTitle(selectedOption));
  }

  function handleBackPress() {
    if (_onBack == null) {
      return false;
    }

    _onBack.invoke();
    return true;
  }
}
