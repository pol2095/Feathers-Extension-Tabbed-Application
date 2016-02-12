package components
{
	import feathers.controls.Screen;
	
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
