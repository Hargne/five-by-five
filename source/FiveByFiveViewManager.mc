using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.Timer;
using Toybox.WatchUi;

module FiveByFiveScreen {
  const SELECT_WORKOUT = :SELECT_WORKOUT;
  const WORKOUT_MENU = :WORKOUT_MENU;
  const WORKOUT_EXERCISES_LIST = :WORKOUT_EXERCISES_LIST;
}

class FiveByFiveMainViewManager {
  var _workoutManager;
  var _currentScreen;

  function initialize() {
    _workoutManager = new FiveByFiveWorkoutManager();
  }

  function getInitialView() {
    // If the user has not yet started a workout previously
    if (_workoutManager.getCurrentWorkout() == null) {
      _currentScreen = FiveByFiveScreen.SELECT_WORKOUT;
      var view = getViewFromScreen(FiveByFiveScreen.SELECT_WORKOUT);
      var inputDelegate = new FiveByFiveInputDelegate(view);
      return [view, inputDelegate];
    }

    _currentScreen = FiveByFiveScreen.WORKOUT_MENU;
    var view = getViewFromScreen(FiveByFiveScreen.WORKOUT_MENU);
    var inputDelegate = new FiveByFiveInputDelegate(view);
    return [view, inputDelegate];
  }

  function getViewFromScreen(screen) {
    if (screen == FiveByFiveScreen.SELECT_WORKOUT) {
      var workouts = _workoutManager.getWorkouts();
      var workoutOptions = [];
      for (var i = 0; i < workouts.size(); i += 1) {
        var workout = workouts[i] as Lang.Dictionary;
        workoutOptions.add([workout[:name], _workoutManager.exercisesToString(workout[:exercises])]);
      }
      var workoutView = new FiveByFiveMainSelectionView("Select workout", workoutOptions);
      workoutView.assignOnSelectHandler(method(:onWorkoutSelected));
      return workoutView;
    } else if (screen == FiveByFiveScreen.WORKOUT_MENU) {
      var currentWorkout = _workoutManager.getCurrentWorkout();
      var title = "Workout " + currentWorkout[:name];
      var workoutMenuView = new FiveByFiveMainSelectionView(title, [
        ["Start"],
        ["View Exercises"],
        ["Switch Workout"]
      ]);
      workoutMenuView.assignOnSelectHandler(method(:onWorkoutMenuSelection));
      return workoutMenuView;
    } else if (screen == FiveByFiveScreen.WORKOUT_EXERCISES_LIST) {
      var title = "Exercises";
      var exercises = _workoutManager.getCurrentWorkoutExercises();
      var exerciseOptions = [];
      for (var i = 0; i < exercises.size(); i += 1) {
        var exercise = exercises[i];
        exerciseOptions.add([
          exercise[:sets] + "x " + exercise[:name],
          _workoutManager.getExerciseWeight(exercise)
        ]);
      }

      var workoutExercisesView = new FiveByFiveMainSelectionView(title, exerciseOptions);
      return workoutExercisesView;
    }
    
    return null;
  }

  function changeScreen(screen, transition) {
    _currentScreen = screen;
    var view = getViewFromScreen(screen);
    // Transition to view
    if (view != null) {
      WatchUi.switchToView(view, new FiveByFiveInputDelegate(view), transition);
    }
    return null;
  }

  function onWorkoutSelected(selectedIndex, selectedOption) {
    if (selectedIndex == 0) {
      _workoutManager.selectWorkout("A");
    } else {
      _workoutManager.selectWorkout("B");
    }
    changeScreen(FiveByFiveScreen.WORKOUT_MENU, WatchUi.SLIDE_LEFT);
  }

  function onWorkoutMenuSelection(selectedIndex, selectedOption) {
    var option = selectedOption as Lang.String;

    if (option.equals("Start")) {
      System.println("Starting workout");
    } else if (option.equals("View Exercises")) {
      changeScreen(FiveByFiveScreen.WORKOUT_EXERCISES_LIST, WatchUi.SLIDE_LEFT);
    } else if (option.equals("Switch Workout")) {
      changeScreen(FiveByFiveScreen.SELECT_WORKOUT, WatchUi.SLIDE_RIGHT);
    }
  }

}
