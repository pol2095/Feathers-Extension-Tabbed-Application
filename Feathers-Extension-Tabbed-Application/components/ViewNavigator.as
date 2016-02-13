package components
{
	import starling.display.DisplayObject;
	import feathers.controls.StackScreenNavigatorItem;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getDefinitionByName;
	import feathers.controls.StackScreenNavigator;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.net.SharedObject;
	import feathers.motion.Slide;
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import feathers.events.FeathersEventType;
	
	public class ViewNavigator extends StackScreenNavigator
	{
		/**
		 * Persistence views shared object
		 * 
		 * @private 
		 */
		public var _history:Vector.<String> = new Vector.<String>;
		/**
		 * Persistence data shared object
		 * 
		 * @private 
		 */
		public var _historyData:Vector.<Object> = new Vector.<Object>;
		private var my_so:SharedObject;
		private var init:Boolean;
		/**
		 * The tabbed navigators that is currently displaying this navigator
		 *
		 * [TabbedViewNavigatorApplication-only]
		 */
		public var owner:Object;
		/**
		 * The navigator id that is currently displaying by the tabbed navigators
		 *
		 * [TabbedViewNavigatorApplication-only]
		 */
		public var vnID:String;
		
		private var hasEventListener_keyCode:Boolean;
		private var _keyCode:String;
		/**
		 * Keyboard key code to pop view
		 *
		 * [ViewNavigatorApplication-only]
		 *
		 * <p>Possible values are "back", "left" or key code (uint).</p>
		 *
		 * @default null
		 */
		public function get keyCode():String
		{
			return _keyCode;
		}
		public function set keyCode(value:String):void
		{
			_keyCode = value;
			if(owner || !stage) return;
			if(value && !hasEventListener_keyCode)
			{
				hasEventListener_keyCode = true;
				stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			}
			else if(!value && hasEventListener_keyCode)
			{
				hasEventListener_keyCode = false;
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			}
		}
		
		/**
		 * Constructor. 
		 */
		public function ViewNavigator(screen:Object = null, data:Object = null, transition:Function = null, owner:Object = null, vnID:String = null, _history:Vector.<String> = null, _historyData:Vector.<Object> = null)
		{
			super();
			this.owner = owner;
			this.vnID = vnID;
			if(screen) {
				pushView(screen, data, null, transition, _history, _historyData);
				
				this.pushTransition = Slide.createSlideLeftTransition();
				this.popTransition = Slide.createSlideRightTransition();
				this.pushTransition = Slide.createSlideLeftTransition( 0.75, Transitions.EASE_IN_OUT );
			}
			else
			{
				my_so = SharedObject.getLocal("feathersPersistenceManager");
				this.addEventListener(FeathersEventType.CREATION_COMPLETE, creationCompleteHandler);
			}
		}
		
		private var hasEventListener_persistNavigatorState:Boolean;
		private var _persistNavigatorState:Boolean;
		/**
		 * In-memory persistence saves navigators, views and data as the user navigates the application.
		 *
		 * [ViewNavigatorApplication-only]
		 *
		 * @default false
		 */
		public function get persistNavigatorState():Boolean
		{
			return owner ? owner.persistNavigatorState : _persistNavigatorState;
		}
		public function set persistNavigatorState(value:Boolean):void
		{
			_persistNavigatorState = value;
			if(owner) return;
			if(value && !hasEventListener_persistNavigatorState)
			{
				hasEventListener_persistNavigatorState = true;
				NativeApplication.nativeApplication.addEventListener(flash.events.Event.DEACTIVATE, onDeactivate);
			}
			else if(!value && hasEventListener_persistNavigatorState)
			{
				hasEventListener_persistNavigatorState = false;
				NativeApplication.nativeApplication.removeEventListener(flash.events.Event.DEACTIVATE, onDeactivate);
				clear();
			}
		}
		
		private function pushFirstView(screen:Object, data:Object = null, transition:Function = null, _history:Vector.<String> = null, _historyData:Vector.<Object> = null):void
		{
			var my_soData:Object = owner ? owner.my_so.data : my_so.data;
			if(my_soData.viewsHistory)
			{
				if(!owner)
				{
					_history = Vector.<String>(my_so.data.viewsHistory);
					_historyData = Vector.<Object>(my_so.data.viewsHistoryData);
				}
				var length:uint = _history.length;
				for(var i:uint = 0; i < length; i++)
				{
					pushView( getDefinitionByName( getHistoryClassName(_history[i]) ), _historyData[i], null, transition, null, null, true);
				}
			}
			else
			{
				pushView(screen, data, null, transition, null, null, true);
			}
		}
		
		/**
		 * Pushes a new view to the top of the navigation stack.
		 
		 * @param screen view class.
		 *
		 * @param data Properties saved in a view.
		 *
		 * @param savedPreviousScreenProperties data send to the previous view. [for data properties is automatic]
		 *
		 * @param transition.
		 *
		 * @param _history. [don't use]
		 *
		 * @param _historyData. [don't use]
		 *
		 * @param firstView. [don't use]
		 */
		public function pushView(screen:Object, data:Object = null, savedPreviousScreenProperties:Object = null, transition:Function = null, _history:Vector.<String> = null, _historyData:Vector.<Object> = null, firstView:Boolean = false):void
		{
			if(!init)
			{
				init = true;
				pushFirstView(screen, data, transition, _history, _historyData);
				return;
			}
			if(!firstView)
			{
				if(!savedPreviousScreenProperties) savedPreviousScreenProperties = {};
				savedPreviousScreenProperties.data = (this.activeScreen as IView).data;
				if(persistNavigatorState) historyDataUpdate();
			}
			var id:String = screenId( getQualifiedClassName(screen) );
			removeScreens();
			var item:StackScreenNavigatorItem = new StackScreenNavigatorItem( screen );
			item.properties.data = data;
			this.addScreen( id, item );
			this._history.push(id);
			this._historyData.push(data);
			pushScreen(id, savedPreviousScreenProperties, transition);
		}
 
		/**
		 * Pops the current view off the navigation stack.
		 */
		public function popView(transition:Function = null):DisplayObject
		{
			return (_history.length > 1) ? super.popScreen(transition) : null;
		}
		
		/**
		 * Number of views in the navigation stack 
		 */
		public function get length():uint
		{
			return _history.length;
		}
		
		/**
		 * Position in the navigation stack
		 */
		public function get position():uint
		{
			return _history.indexOf(this.activeScreenID);
		}
		
		/**
		 * Remove screens after position
		 * 
		 * @private 
		 */
		public function removeScreens():void
		{
			var length:uint = this.length;
			var position:uint = this.position;
			for(var i:uint = length-1; i > position; i--)
			{
				this.removeScreen(_history[i]);
				_history.pop();
				_historyData.pop();
			}
		}
		
		private function screenId(id:String):String
		{
			var i:uint;
			id = vnID ? vnID+"_"+id : id;
			while(_history.indexOf(id+"_"+i) != -1) i++;
			return id+"_"+i;
		}
		
		private function onDeactivate(event:flash.events.Event):void
		{
			save();
		}
		
		/**
		 * Save views and data
		 *
		 * [ViewNavigatorApplication-only]
		 */
		public function save():void
		{
			if(owner) return;
			if(persistNavigatorState)
			{
				removeScreens();
				my_so.data.viewsHistory = _history;
				historyDataUpdate();
				my_so.data.viewsHistoryData = _historyData;
				my_so.flush();
			}
		}
		
		/**
		 * Clear the persistence views and data
		 *
		 * [ViewNavigatorApplication-only]
		 */
		public function clear():void
		{
			if(owner) return;
			if(my_so.data.viewsHistory)
			{
				delete my_so.data.viewsHistory;
				delete my_so.data.viewsHistoryData;
			}
		}
		
		/**
		 * Exit to the application and clear the persistence navigators, views and data
		 *
		 * [ViewNavigatorApplication-only]
		 */
		public function exit(errorCode:int = 0):void
		{
			if(owner) return;
			_persistNavigatorState = false;
			clear();
			NativeApplication.nativeApplication.exit(errorCode);
		}
		
		private function getHistoryClassName(value:String):String
		{
			return owner ? value.substring(value.indexOf("_")+1, value.lastIndexOf("_")) : value.substring(0, value.lastIndexOf("_"));
		}
		
		/**
		 * Update data in a view
		 */
		public function historyDataUpdate():void
		{
			_historyData[position] = (this.activeScreen as IView).data;
		}
		
		private function keyDownHandler(event:KeyboardEvent):void
		{
			var keyCode:uint;
			if(this.keyCode == "back")
			{
				keyCode = Keyboard.BACK;
			}
			else if(this.keyCode == "left")
			{
				keyCode = Keyboard.LEFT;
			}
			else
			{
				keyCode = uint(this.keyCode);
			}
			if(event.keyCode == keyCode)
			{
				if(position != 0)
				{
					popView();
					event.preventDefault();
				}
			}
		}
		
		private function creationCompleteHandler(event:starling.events.Event):void
		{
			this.removeEventListener(FeathersEventType.CREATION_COMPLETE, creationCompleteHandler);
			if(keyCode && !hasEventListener_keyCode && !owner)
			{
				hasEventListener_keyCode = true;
				stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			}
		}
	}
}