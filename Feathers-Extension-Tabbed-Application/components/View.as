/*
Copyright 2016 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package components
{
	import feathers.controls.Screen;
	
	/**
	 * A basic view to be displayed by <code>ViewNavigator</code>, based on <code>Screen</code>. Provides
	 * layout capabilities, but no scrolling.
	 *
	 * @see http://pol2095.free.fr/Feathers-Extension-Tabbed-Application/TabbedViewNavigatorApplication.html How to use TabbedViewNavigatorApplication with mxml
	 * @see http://pol2095.free.fr/Feathers-Extension-Tabbed-Application/ViewNavigatorApplication.html How to use ViewNavigatorApplication with mxml
	 * @see components.TabbedViewNavigator
	 * @see components.ViewNavigator
	 * @see feathers.controls.Screen
	 */
	public class View extends Screen implements IView
	{
		private var _data:Object;
		/**
		 * Properties saved in a view.
		 */
		public function get data():Object
		{
			return _data;
		}
		public function set data(value:Object):void
		{
			_data = value;
		}
		
		/**
		 * Constructor.
		 */
		public function View()
		{
			super();
		}
	}
}
