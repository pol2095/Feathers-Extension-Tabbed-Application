/*
Copyright 2015 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package components
{
	import feathers.controls.PanelScreen;
	
	/**
	 * A view for use with <code>ViewNavigator</code>, based on <code>PanelScreen</code>
	 * in order to provide a header and layout.
	 *
	 * @see http://pol2095.free.fr/Feathers-Extension-Tabbed-Application/TabbedViewNavigatorApplication.html How to use TabbedViewNavigatorApplication with mxml
	 * @see http://pol2095.free.fr/Feathers-Extension-Tabbed-Application/ViewNavigatorApplication.html How to use ViewNavigatorApplication with mxml
	 * @see components.TabbedViewNavigator
	 * @see components.ViewNavigator
	 * @see feathers.controls.PanelScreen
	 */
	public class PanelView extends PanelScreen implements IView
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
		public function PanelView()
		{
			super();
		}
	}
}
