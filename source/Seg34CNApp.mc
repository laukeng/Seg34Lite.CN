import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class Seg34CNApp extends Application.AppBase {
    
    var mView;
    
    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() {
        mView = new Seg34CNView();
        var delegate = new Seg34CNDelegate(mView);
        return [mView, delegate];
    }

    function onSettingsChanged() as Void {
        mView.onSettingsChanged();
        WatchUi.requestUpdate();
    }

}

function getApp() as Seg34CNApp {
    return Application.getApp() as Seg34CNApp;
}