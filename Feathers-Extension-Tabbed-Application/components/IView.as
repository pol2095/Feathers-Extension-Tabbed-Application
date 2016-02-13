/*
Feathers
Copyright 2012-2015 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package components
{
	/**
	 *  The IView interface defines the interface for View and PanelView.
	 */
	public interface IView
	{
		/**
		 * Properties saved in a view.
		 */
		function get data():Object;
		function set data(value:Object):void;
	}
}