using Toybox.Application;
using Toybox.System;
using Toybox.Lang;
using Toybox.Math;

class FiveByFiveWorkoutManager {
  const PROFILE_KEY = "five_by_five_profile_v1";
  // Profile key used by earlier versions of the app; read so existing users keep their data.
  const LEGACY_PROFILE_KEY = "stronglifts_5x5_profile_v1";

  const UNIT_KG = "kg";
  const UNIT_LB = "lb";
  const KG_TO_LB = 2.20462;
  // Plate increments in lb are double the kg ones (2.5 kg -> 5 lb, 5 kg -> 10 lb).
  const LB_INCREMENT_FACTOR = 2.0;

  var _unit = UNIT_KG;
  // Default weights and increments are in kg; they are converted when the unit is lb.
  var _workouts = [
      { :name => "A", :exercises => [
        { :name => "Squat", :sets => 5, :increment => 2.5, :weight => 20.0 },
        { :name => "Bench Press", :sets => 5, :increment => 2.5, :weight => 20.0 },
        { :name => "Barbell Row", :sets => 5, :increment => 2.5, :weight => 20.0 }
      ] },
      { :name => "B", :exercises => [
        { :name => "Squat", :sets => 5, :increment => 2.5, :weight => 20.0 },
        { :name => "Overhead Press", :sets => 5, :increment => 2.5, :weight => 20.0 },
        { :name => "Deadlift", :sets => 1, :increment => 5.0, :weight => 40.0 }
      ] }
  ];

  var _currentWorkout = null;

  function initialize() {
    loadSavedData();
  }

  function loadSavedData() {
    var data = Application.Storage.getValue(PROFILE_KEY);
    if (!(data instanceof Lang.Dictionary)) {
      data = Application.Storage.getValue(LEGACY_PROFILE_KEY);
    }

    // No saved data: start in the unit the watch itself is set to.
    if (!(data instanceof Lang.Dictionary)) {
      if (_deviceUsesPounds()) {
        _convertWorkouts(UNIT_LB);
        _unit = UNIT_LB;
      }
      return;
    }

    var savedData = data as Lang.Dictionary;

    // Weights are saved in the saved unit. Data from before units existed has no unit and is kg.
    var savedUnit = savedData["unit"];
    if (UNIT_LB.equals(savedUnit)) {
      _convertIncrements(UNIT_LB);
      _unit = UNIT_LB;
    }

    // Saved weights
    var savedWeights = savedData["weights"];
    if (savedWeights instanceof Lang.Dictionary) {
      savedWeights = savedWeights as Lang.Dictionary;

      _workouts = _workouts as Lang.Array;
      for (var i = 0; i < _workouts.size(); i += 1) {
        var workout = _workouts[i] as Lang.Dictionary;
        var exercises = workout[:exercises] as Lang.Array;
        for (var j = 0; j < exercises.size(); j += 1) {
          var exercise = exercises[j] as Lang.Dictionary;
          var exerciseName = exercise[:name] as Lang.String;
          if (savedWeights[exerciseName] != null) {
            exercise[:weight] = savedWeights[exerciseName].toFloat();
          }
        }
      }
    }

    var lastWorkoutName = savedData["lastWorkout"];
    if (lastWorkoutName != null) {
      // Select the opposite workout if the saved last workout is the same as the currently selected workout.
      selectWorkout(lastWorkoutName.equals("B") ? "B" : "A");
    }
  }

  function saveData() {
    var weights = {};
    var allWorkouts = _workouts as Lang.Array;
    for (var i = 0; i < allWorkouts.size(); i += 1) {
      var exercises = (allWorkouts[i] as Lang.Dictionary)[:exercises] as Lang.Array;
      for (var j = 0; j < exercises.size(); j += 1) {
        var exercise = exercises[j] as Lang.Dictionary;
        weights[exercise[:name]] = exercise[:weight].toFloat();
      }
    }

    var lastWorkout = (_currentWorkout != null) ? (_currentWorkout as Lang.Dictionary)[:name] : null;

    Application.Storage.setValue(PROFILE_KEY, {
      "unit" => _unit,
      "weights" => weights,
      "lastWorkout" => lastWorkout
    });
  }

  function getUnit() {
    return _unit;
  }

  // Switches unit and converts every weight, rounded to the nearest plate increment of the new unit.
  function setUnit(newUnit) {
    if (!UNIT_KG.equals(newUnit) && !UNIT_LB.equals(newUnit)) {
      return;
    }
    if (_unit.equals(newUnit)) {
      return;
    }
    _convertWorkouts(newUnit);
    _unit = newUnit;
    saveData();
  }

  function _deviceUsesPounds() {
    return System.getDeviceSettings().weightUnits == System.UNIT_STATUTE;
  }

  function _convertWorkouts(toUnit) {
    _convertIncrements(toUnit);

    var weightFactor = UNIT_LB.equals(toUnit) ? KG_TO_LB : 1.0 / KG_TO_LB;
    var allWorkouts = _workouts as Lang.Array;
    for (var i = 0; i < allWorkouts.size(); i += 1) {
      var exercises = (allWorkouts[i] as Lang.Dictionary)[:exercises] as Lang.Array;
      for (var j = 0; j < exercises.size(); j += 1) {
        var exercise = exercises[j] as Lang.Dictionary;
        var increment = exercise[:increment].toFloat();
        var converted = exercise[:weight].toFloat() * weightFactor;
        exercise[:weight] = Math.round(converted / increment) * increment;
      }
    }
  }

  function _convertIncrements(toUnit) {
    var factor = UNIT_LB.equals(toUnit) ? LB_INCREMENT_FACTOR : 1.0 / LB_INCREMENT_FACTOR;
    var allWorkouts = _workouts as Lang.Array;
    for (var i = 0; i < allWorkouts.size(); i += 1) {
      var exercises = (allWorkouts[i] as Lang.Dictionary)[:exercises] as Lang.Array;
      for (var j = 0; j < exercises.size(); j += 1) {
        var exercise = exercises[j] as Lang.Dictionary;
        exercise[:increment] = exercise[:increment].toFloat() * factor;
      }
    }
  }

  function getWorkoutByName(input) {
    var workoutName = input as Lang.String;
    if (!workoutName.equals("A") && !workoutName.equals("B")) {
        System.println("Invalid workout name: " + workoutName);
        return null;
    }
    var allWorkouts = _workouts as Lang.Array;
    for (var i = 0; i < allWorkouts.size(); i += 1) {
      var workout = allWorkouts[i] as Lang.Dictionary;
      if (workoutName.equals(workout[:name])) {
          return workout;
      }
    }
    return null;
  }

  function selectWorkout(workoutName) {
    var workout = getWorkoutByName(workoutName);
    if (workout != null) {
      _currentWorkout = workout;
    }
  }

  function getCurrentWorkout() {
    return _currentWorkout;
  }

  function getCurrentWorkoutExercises() {
    var currentWorkout = _currentWorkout as Lang.Dictionary;
    return currentWorkout[:exercises] as Lang.Array;
  }

  // Updates every workout containing the exercise (Squat is in both A and B), then saves.
  function editExerciseWeight(exerciseName, newWeight) {
    var found = false;
    var allWorkouts = _workouts as Lang.Array;
    for (var i = 0; i < allWorkouts.size(); i += 1) {
      var exercises = (allWorkouts[i] as Lang.Dictionary)[:exercises] as Lang.Array;
      for (var j = 0; j < exercises.size(); j += 1) {
        var exercise = exercises[j] as Lang.Dictionary;
        if (exercise[:name].equals(exerciseName)) {
          exercise[:weight] = newWeight;
          found = true;
        }
      }
    }

    if (!found) {
      System.println("Exercise not found: " + exerciseName);
      return;
    }
    saveData();
  }

  function formatWeight(value) {
    var w = value.toFloat();
    var text = (w == w.toNumber()) ? w.toNumber().toString() : w.format("%.1f");
    return text + " " + _unit;
  }

  function getWorkouts() {
    return _workouts as Lang.Array;
  }

  function getExerciseWeight(exercise) {
    exercise = exercise as Lang.Dictionary;
    return formatWeight(exercise[:weight]);
  }

  function exercisesToString(exercises) {
    var names = "";
    exercises = exercises as Lang.Array;
    for (var i = 0; i < exercises.size(); i += 1) {
      var exercise = exercises[i] as Lang.Dictionary;
      if (i > 0) {
          names += ", ";
      }
      names += exercise[:name];
    }
    return names;
  }
}
