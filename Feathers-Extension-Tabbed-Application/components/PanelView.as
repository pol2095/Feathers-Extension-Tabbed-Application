/*
Copyright 2016 pol2095. All Rights Reserved.

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
		 * @private
		 */
		public var _excludeComponentsForSlide:Vector.<String> = new <String>[];
		/**
		 * Exlude components to slide view scroll.
		 *
		 * <listing version="3.0">
		 * textInput, textArea</listing> 
		 */
		public function set excludeComponentsForSlide(value:String):void
		{
			_excludeComponentsForSlide = Vector.<String>(value.replace(/, /g, ",").split(","));
		}
		
		/**
		 * @private
		 */
		public var _excludeClassesForSlide:Vector.<String> = new <String>["feathers.controls::TextInput", "feathers.controls::TextArea"];
		/**
		 * Exlude classes to slide view scroll.
		 *
		 * @default feathers.controls::TextInput, feathers.controls::TextArea
		 */
		public function set excludeClassesForSlide(value:String):void
		{
			_excludeClassesForSlide = Vector.<String>(value.replace(/, /g, ",").split(","));
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
