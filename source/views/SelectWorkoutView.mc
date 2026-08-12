using Toybox.Lang;

class SelectWorkoutView extends FiveByFiveMainSelectionView {
  var _workoutManager;
  var _onWorkoutSelected;

  function initialize(workoutManager, onWorkoutSelected) {
    FiveByFiveMainSelectionView.initialize("Select Workout", getWorkoutOptions(workoutManager));

    _workoutManager = workoutManager;
    _onWorkoutSelected = onWorkoutSelected;
    assignOnSelectHandler(method(:selectWorkout));
  }

  function selectWorkout(selectedIndex, selectedOption) {
    if (selectedIndex == 0) {
      _workoutManager.selectWorkout("A");
    } else {
      _workoutManager.selectWorkout("B");
    }
    // Invoke parent method
    if (_onWorkoutSelected != null) {
      _onWorkoutSelected.invoke();
    }
  }
}

function getWorkoutOptions(workoutManager) {
  var workouts = workoutManager.getWorkouts() as Lang.Array;
  var workoutOptions = [];
  for (var i = 0; i < workouts.size(); i += 1) {
    var workout = workouts[i] as Lang.Dictionary;
    workoutOptions.add([workout[:name]]);
  }

  return workoutOptions;
}
