/*
Copyright 2016 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.extensions.tabbedApplication
{
	import starling.display.DisplayObject;
	import feathers.controls.ScreenNavigator;

	public class TabbedScreenNavigator extends ScreenNavigator
	{
		public function TabbedScreenNavigator()
		{
			super();
		}
		
		public function set activeScreenID(value:String):void
		{
			this._activeScreenID = value;
		}
		
		public function set activeScreen(value:DisplayObject):void
		{
			this._activeScreen = value;
		}
		
		public function get _views():Object
		{
			return this._screens;
		}
		
		public function clearViewInternal(transition:Function = null):void
		{
			clearScreenInternal(transition);
		}
	}
}