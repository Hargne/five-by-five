using Toybox.Application;
using Toybox.WatchUi;

class FiveByFiveApp extends Application.AppBase {

    var _viewManager;

    function initialize() {
        AppBase.initialize();
        _viewManager = new FiveByFiveMainViewManager();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }

    function getInitialView() {
        return _viewManager.getInitialView();
    }
}

function getApp() {
    return Application.getApp();
}
