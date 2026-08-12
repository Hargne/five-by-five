using Toybox.Lang;

module WorkoutMenuOptions {
  const START_WORKOUT = :START_WORKOUT;
  const VIEW_EXERCISES = :VIEW_EXERCISES;
  const SWITCH_WORKOUT = :SWITCH_WORKOUT;
}

class WorkoutMenuView extends FiveByFiveMainSelectionView {
  var _onOptionSelected;

  function initialize(onOptionSelected) {
    FiveByFiveMainSelectionView.initialize("", [
      ["Start"],
      ["View Exercises"],
      ["Switch Workout"]
    ]);

    _onOptionSelected = onOptionSelected;
    assignOnSelectHandler(method(:selectMenuItem));
  }

  function setWorkout(workout) {
    if (workout == null) {
      setTitle("Workout Menu");
      return;
    }
    workout = workout as Lang.Dictionary;
    setTitle("Workout " + workout[:name]);
  }

  function selectMenuItem(selectedIndex, selectedOption) {
    var option = selectedOption as Lang.String;

    if (option.equals("Start")) {
      _onOptionSelected.invoke(WorkoutMenuOptions.START_WORKOUT);
    } else if (option.equals("View Exercises")) {
      _onOptionSelected.invoke(WorkoutMenuOptions.VIEW_EXERCISES);
    } else if (option.equals("Switch Workout")) {
      _onOptionSelected.invoke(WorkoutMenuOptions.SWITCH_WORKOUT);
    }
  }

  function setSelectedItem(option) {
    var options = [
      ["Start"],
      ["View Exercises"],
      ["Switch Workout"]
    ] as Lang.Array;
    for (var i = 0; i < options.size(); i++) {
      var currentOption = options[i] as Lang.Array;
      var currentOptionTitle = currentOption[0] as Lang.String;
      if (currentOptionTitle.equals(option)) {
        setSelectedIndex(i);
        break;
      }
    }
  }
}
