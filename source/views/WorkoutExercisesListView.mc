using Toybox.Lang;

class WorkoutExercisesListView extends FiveByFiveMainSelectionView {
  var _onExerciseSelected;
  var _exercises;

  function initialize(onExerciseSelected) {
    FiveByFiveMainSelectionView.initialize("Exercises", []);

    _onExerciseSelected = onExerciseSelected;
    assignOnSelectHandler(method(:selectExercise));
  }

  function setExercises(exercises) {
    _exercises = exercises as Lang.Array;
    setOptions(getWorkoutExerciseOptions(_exercises));
  }

  function selectExercise(selectedIndex, selectedOption) {
    var exercises = _exercises as Lang.Array;
    _onExerciseSelected.invoke(exercises[selectedIndex]);
  }
}

function getWorkoutExerciseOptions(exercises) {
  var options = [];
  exercises = exercises as Lang.Array;
  for (var i = 0; i < exercises.size(); i += 1) {
    var exercise = exercises[i] as Lang.Dictionary;
    options.add([
      exercise[:sets] + "x " + exercise[:name],
      FiveByFiveWorkoutLogic.formatWeight(exercise[:weight])
    ]);
  }

  return options;
}
