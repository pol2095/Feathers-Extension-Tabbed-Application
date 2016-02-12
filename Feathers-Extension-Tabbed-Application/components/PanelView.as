package components
{
	import feathers.controls.PanelScreen;
	
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
