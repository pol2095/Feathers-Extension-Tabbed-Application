# Feathers Extension Tabbed Application 1.4.005

Say hello to [Feathers Extension Tabbed Application](http://pol2095.free.fr/Feathers-Extension-Tabbed-Application/).
This project adds two components (<b>ViewNavigatorApplication</b> and <b>TabbedViewNavigatorApplication</b>) to Feathers UI, a library of light-weight, skinnable, and extensible UI controls for mobile and desktop. The components run on Starling Framework and the Adobe Flash runtimes, offering blazing fast GPU powered graphics to create a smooth and responsive experience. Build completely standalone, native applications on iOS, Android, Windows, and Mac OS X, or target Adobe Flash Player in desktop browsers.
* The <b>ViewNavigatorApplication</b> class is an application class meant to provide a simple framework for applications that employ a view-based navigation model.<br />
A view-based navigation model is characterized by a user interface where the end user navigates between a series of full screen views in response to user interaction. This is a paradigm commonly used by mobile applications and is accomplished through the use of a built in ViewNavigator container.<br />
It adds persitence manager and swipe views (or screens to navigate in the history of views) to feathers.controls.StackScreenNavigator.
* The <b>TabbedViewNavigatorApplication</b> container defines an application with multiple sections (ViewNavigator).<br />It allows persitence manager, swipe views or swipe navigators and drag tabs.

## Quick Links

* [Website](http://pol2095.free.fr/Feathers-Extension-Tabbed-Application/)
* [API Reference](http://pol2095.free.fr/Starling-Feathers-Extensions/docs/feathers/extensions/tabbedApplication/package-detail.html)
* [Discussion Forum](http://forum.starling-framework.org/forum/feathers)
* [Github Project](https://github.com/pol2095/Feathers-Extension-Tabbed-Application)

## Minimum Requirements

* Adobe AIR 19.0 or Adobe Flash Player 19.0
* [Starling Framework 2.0](http://forum.starling-framework.org/topic/preview-starling-20)
* [Feathers Framework](https://github.com/BowlerHatLLC/feathers)

## Note
to compile for Flash player :
- add in compiler (mxmlc) "-define+=CONFIG::air,false"
- uncomment in "ViewNavigator.as" :
    - "CONFIG::air"
	- "if(CONFIG::air)"
- if you use "ViewNavigatorApplication" uncomment in "ViewNavigator.as" :
	- "else Starling.current.nativeStage.addEventListener(flash.events.Event.DEACTIVATE, onDeactivate);"
	- "else Starling.current.nativeStage.removeEventListener(flash.events.Event.DEACTIVATE, onDeactivate);
- if you use "TabbedViewNavigatorApplication" uncomment in "TabbedViewNavigator.as" :
	- "CONFIG::air"
	- "if(CONFIG::air)"
	- "else Starling.current.nativeStage.addEventListener(flash.events.Event.DEACTIVATE, onDeactivate);"
	- "else Starling.current.nativeStage.removeEventListener(flash.events.Event.DEACTIVATE, onDeactivate);