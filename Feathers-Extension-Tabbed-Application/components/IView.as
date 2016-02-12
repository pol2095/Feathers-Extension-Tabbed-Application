package components
{
	public interface IView
	{
		/**
		 * Properties saved in a view.
		 */
		function get data():Object;
		function set data(value:Object):void;
	}
}