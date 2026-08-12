using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.Timer;
using Toybox.WatchUi;

module FiveByFiveView {
  const SELECT_WORKOUT = :SELECT_WORKOUT;
  const WORKOUT_MENU = :WORKOUT_MENU;
  const WORKOUT_EXERCISES_LIST = :WORKOUT_EXERCISES_LIST;
}

class FiveByFiveMainViewManager {
  var _workoutManager;
  var _currentView;
  var _selectWorkoutView;
  var _workoutMenuView;
  var _workoutExercisesListView;

  function initialize() {
    _workoutManager = new FiveByFiveWorkoutManager();
    _selectWorkoutView = null;
    _workoutMenuView = null;
    _workoutExercisesListView = null;
  }

  function getInitialView() {
    var viewName = _workoutManager.getCurrentWorkout() == null ? FiveByFiveView.SELECT_WORKOUT : FiveByFiveView.WORKOUT_MENU;
    _currentView = viewName;

    var view = _getViewByName(viewName);
    return [view, new FiveByFiveInputDelegate(view)];
  }

  function transitionTo(viewName, transition) {
    var targetView = _getViewByName(viewName);
    WatchUi.switchToView(targetView, new FiveByFiveInputDelegate(targetView), transition);
    _currentView = viewName;
  }

  function _getViewByName(viewName) {
    if (viewName == FiveByFiveView.SELECT_WORKOUT) {
      if (_selectWorkoutView == null) {
        _selectWorkoutView = new SelectWorkoutView(_workoutManager, method(:onWorkoutSelected));
      }
      return _selectWorkoutView;
    }

    if (viewName == FiveByFiveView.WORKOUT_MENU) {
      if (_workoutMenuView == null) {
        _workoutMenuView = new WorkoutMenuView(method(:onWorkoutMenuSelection));
        _workoutMenuView.assignOnBackHandler(method(:onWorkoutMenuBack));
      }
      _workoutMenuView.setWorkout(_workoutManager.getCurrentWorkout());
      return _workoutMenuView;
    }

    if (viewName == FiveByFiveView.WORKOUT_EXERCISES_LIST) {
      if (_workoutExercisesListView == null) {
        _workoutExercisesListView = new WorkoutExercisesListView(method(:onStartEditExercise));
        _workoutExercisesListView.assignOnBackHandler(method(:onWorkoutExercisesListBack));
      }
      _workoutExercisesListView.setExercises(_workoutManager.getCurrentWorkoutExercises());
      return _workoutExercisesListView;
    }

    return null;
  }

  function onWorkoutSelected() {
    transitionTo(FiveByFiveView.WORKOUT_MENU, WatchUi.SLIDE_LEFT );
  }
  
  function onWorkoutMenuBack() {
    transitionTo(FiveByFiveView.SELECT_WORKOUT, WatchUi.SLIDE_RIGHT);
  }

  function onWorkoutMenuSelection(selectedOption) {
    var option = selectedOption;

    if (option == WorkoutMenuOptions.START_WORKOUT) {
      System.println("Starting workout");
    } else if (option == WorkoutMenuOptions.VIEW_EXERCISES) {
      transitionTo(FiveByFiveView.WORKOUT_EXERCISES_LIST, WatchUi.SLIDE_LEFT);
    } else if (option == WorkoutMenuOptions.SWITCH_WORKOUT) {
      transitionTo(FiveByFiveView.SELECT_WORKOUT, WatchUi.SLIDE_RIGHT);
    }
  }

  function onWorkoutExercisesListBack() {
    var workoutMenuView = _getViewByName(FiveByFiveView.WORKOUT_MENU) as WorkoutMenuView;
    //workoutMenuView.setSelectedItem("View Exercises");
    transitionTo(FiveByFiveView.WORKOUT_MENU, WatchUi.SLIDE_RIGHT);
  }

  function onStartEditExercise(exercise) {
    var selectedExercise = exercise as Lang.Dictionary;
    var exerciseName = selectedExercise[:name] as Lang.String;
    System.println("Starting edit for exercise: " + exerciseName);
  }

}
