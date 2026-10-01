using Toybox.Lang;

class EditExerciseView extends InputViewTemplate {
  var _workoutManager;
  var _exercise as Lang.Dictionary;
  var _onLeave;

  function initialize(workoutManager, onLeave, exercise) {
    _exercise = exercise as Lang.Dictionary;
    _onLeave = onLeave;

    InputViewTemplate.initialize(
      _exercise[:name],
      FiveByFiveInputType.NUMERIC,
      _exercise[:weight],
      method(:handleSetWeight),
      onLeave
    );
    _workoutManager = workoutManager;
    maxValue = 999;
  }

  function handleSetWeight(newWeight) {
    System.println("Setting weight for exercise: " + _exercise[:name] + " to: " + newWeight);
    _workoutManager.editExerciseWeight(_exercise[:name], newWeight);

    if (_onLeave == null) {
      return false;
    }
    _onLeave.invoke();
    return true;
  }
}