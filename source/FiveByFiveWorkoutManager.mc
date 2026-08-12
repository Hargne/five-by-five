using Toybox.System;
using Toybox.Lang;

class FiveByFiveWorkoutManager {
  const PROFILE_KEY = "five_by_five_profile_v1";

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
  ] ;

  var _currentWorkout = null;

  function initialize() {
    loadSavedData();
  }

  function loadSavedData() {
    var data = Application.Storage.getValue(PROFILE_KEY);
    // If no saved data or invalid format, return without modifying state.
    if (!(data instanceof Lang.Dictionary)) {
      return;
    }

    var savedData = data as Lang.Dictionary;

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

    var lastWorkoutName = savedData[:lastWorkout];
    if (lastWorkoutName != null) {
      // Select the opposite workout if the saved last workout is the same as the currently selected workout.
      selectWorkout(lastWorkoutName.equals("B") ? "B" : "A");
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

  function formatWeightKg(value) {
    return value.format("%0.1f") + " kg";
  }

  function getWorkouts() {
    return _workouts as Lang.Array;
  }

  function getExerciseWeight(exercise) {
    exercise = exercise as Lang.Dictionary;
    return formatWeightKg(exercise[:weight]);
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
