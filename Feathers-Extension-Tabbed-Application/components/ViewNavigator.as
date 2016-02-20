/*
Copyright 2016 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package components
{
	import starling.display.DisplayObject;
	import feathers.controls.StackScreenNavigatorItem;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getDefinitionByName;
	//import feathers.controls.StackScreenNavigator;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.net.SharedObject;
	import feathers.motion.Slide;
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import feathers.events.FeathersEventType;
	import feathers.controls.IScreen;
	import feathers.controls.supportClasses.IScreenNavigatorItem;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import flash.geom.Point;
	import starling.events.Touch;
	import flash.events.MouseEvent;
	import starling.events.EnterFrameEvent;
	import feathers.core.FocusManager;
	import feathers.controls.TextArea;
	import feathers.controls.TextInput;
	
	/**
	 * A "view stack"-like container that supports navigation between views
	 * (any display object) through events, based on <code>StackScreenNavigator</code>.
	 *
	 * @see http://pol2095.free.fr/Feathers-Extension-Tabbed-Application/TabbedViewNavigatorApplication.html How to use TabbedViewNavigatorApplication with mxml
	 * @see http://pol2095.free.fr/Feathers-Extension-Tabbed-Application/ViewNavigatorApplication.html How to use ViewNavigatorApplication with mxml
	 * @see components.View
	 * @see components.PanelView
	 * @see feathers.controls.StackScreenNavigator
	 */
	public class ViewNavigator extends StackScreenNavigator
	{
		/**
		 * Persistence views shared object
		 * 
		 * @private 
		 */
		public var _history:Vector.<String> = new Vector.<String>();
		/**
		 * Persistence data shared object
		 * 
		 * @private 
		 */
		public var _historyData:Vector.<Object> = new Vector.<Object>();
		private var my_so:SharedObject;
		private var init:Boolean;
		/**
		 * The tabbed navigators that is currently displaying this navigator
		 *
		 * [TabbedViewNavigatorApplication-only].
		 */
		public var owner:Object;
		/**
		 * The navigator id that is currently displaying by the tabbed navigators
		 *
		 * [TabbedViewNavigatorApplication-only].
		 */
		public var vnID:String;
		
		private var hasEventListener_keyCode:Boolean;
		private var _keyCode:String;
		/**
		 * Keyboard key code to pop view
		 *
		 * [ViewNavigatorApplication-only].
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
		public function ViewNavigator(screen:Object = null, data:Object = null, transition:Function = null, owner:Object = null, vnID:String = null, _history:Vector.<String> = null, _historyData:Vector.<Object> = null, position:uint = 0)
		{
			super();
			this.owner = owner;
			this.vnID = vnID;
			if(screen) {
				_pushView(screen, data, null, transition, _history, _historyData, position);
				
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
		 * In-memory persistence saves navigators, views and data as the user navigates the application
		 *
		 * [ViewNavigatorApplication-only].
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
		
		private function pushFirstView(screen:Object, data:Object = null, transition:Function = null, _history:Vector.<String> = null, _historyData:Vector.<Object> = null, position:uint = 0):void
		{
			if(!owner)
			{
				if(my_so.data.viewsHistory)
				{
					_history = Vector.<String>(my_so.data.viewsHistory);
					_historyData = Vector.<Object>(my_so.data.viewsHistoryData);
					position = my_so.data.viewsPosition;
				}
			}
			if(_history)
			{
				var length:uint = _history.length;
				for(var i:uint = 0; i < length; i++)
				{
					_pushView( getDefinitionByName( getHistoryClassName(_history[i]) ), _historyData[i], null, transition, null, null, position, true);
				}
				for(i = position+1; i < length; i++)
				{
					popView();
				}
			}
			else
			{
				_pushView(screen, data, null, transition, null, null, position, true);
			}
		}
		
		/**
		 * Pushes a new view to the top of the navigation stack.
		 
		 * @param screen view class.
		 *
		 * @param data Properties saved in a view.
		 *
		 * @param transition.
		 */
		public function pushView(screen:Object, data:Object = null, transition:Function = null):void
		{
			removeScreens();
			_pushView(screen, data, null, transition);
		}
		
		private function _pushView(screen:Object, data:Object = null, savedPreviousScreenProperties:Object = null, transition:Function = null, _history:Vector.<String> = null, _historyData:Vector.<Object> = null, position:uint = 0, firstView:Boolean = false):void
		{
			if(!init)
			{
				init = true;
				pushFirstView(screen, data, transition, _history, _historyData, position);
				return;
			}
			if(!firstView)
			{
				if(!savedPreviousScreenProperties) savedPreviousScreenProperties = {};
				savedPreviousScreenProperties.data = (this.activeScreen as IView).data;
				if(persistNavigatorState) historyDataUpdate();
			}
			var id:String = screenId( getQualifiedClassName(screen) );
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
			return (_history.length > 1) ? popScreen(transition) : null;
		}
		
		/**
		 * Number of views in the navigation stack.
		 */
		public function get length():uint
		{
			return _history.length;
		}
		
		/**
		 * Position in the navigation stack.
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
		 * [ViewNavigatorApplication-only].
		 */
		public function save():void
		{
			if(owner) return;
			if(persistNavigatorState)
			{
				my_so.data.viewsHistory = _history;
				historyDataUpdate();
				my_so.data.viewsHistoryData = _historyData;
				my_so.data.viewsPosition = position;
				my_so.flush();
			}
		}
		
		/**
		 * Clear the persistence views and data
		 *
		 * [ViewNavigatorApplication-only].
		 */
		public function clear():void
		{
			if(owner) return;
			if(my_so.data.viewsHistory)
			{
				delete my_so.data.viewsHistory;
				delete my_so.data.viewsHistoryData;
				delete my_so.data.viewsPosition;
			}
		}
		
		/**
		 * Exit to the application and clear the persistence navigators, views and data
		 *
		 * [ViewNavigatorApplication-only].
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
		 * Update data in a view.
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
			if(!owner) stage.addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		/**
		 * @private 
		 */
		override protected function feathersControl_addedToStageHandler(event:starling.events.Event):void
		{
			preinitialize();
		}
		/**
		 * Override this method to perform other tasks before the application is displayed.
		 *
		 * <listing version="3.0">
		 * override protected function preinitialize():void
		 * {
		 *     //perform other tasks here
		 *     setTimeout(otherTasks, 5000);
		 * }
		 * 
		 * private function otherTasks():void
		 * {
		 *     left = 100;
		 *     super.preinitialize();
		 * }</listing> 
		 */
		protected function preinitialize():void
		{
			if(!isInitialized) super.feathersControl_addedToStageHandler(null);
		}
		
		/**
		 * @private
		 */
		public var tempScreen:DisplayObject;
		private function showViewInternal(id:String, transition:Function = null, properties:Object = null):void
		{
			if(!this.hasScreen(id))
			{
				throw new ArgumentError("Screen with id '" + id + "' cannot be shown because it has not been defined.");
			}

			var item:IScreenNavigatorItem = IScreenNavigatorItem(this._screens[id]);
			tempScreen = item.getScreen();
			var tempScreenID:String = id;
			for(var propertyName:String in properties)
			{
				tempScreen[propertyName] = properties[propertyName];
			}
			if(tempScreen is IScreen)
			{
				var screen:IScreen = IScreen(tempScreen);
				screen.x = 0;
				screen.y = 0;
				screen.screenID = tempScreenID;
				screen.owner = this; //subclasses will implement the interface
			}
			tempScreen_resizeHandler();
			tempScreen.addEventListener(starling.events.Event.RESIZE, tempScreen_resizeHandler);
			this.addChild(tempScreen);
		}
		private function tempScreen_resizeHandler(event:starling.events.Event = null):void
		{
			var navigatorWidth:Number = owner ? stage.stageWidth - owner.left - owner.right : stage.stageWidth;
			tempScreen.width = navigatorWidth;
			tempScreen.x = movingBack ? this.activeScreen.x - navigatorWidth : this.activeScreen.x + navigatorWidth;
		}
		
		/**
		 * @private 
		 */
		public function onTouch(event:TouchEvent):void
		{
			var touchBegan:Touch = event.getTouch(stage, TouchPhase.BEGAN);
			if (touchBegan)
			{
				beginMove( touchBegan.getLocation(stage) );
			}
			var touchMoved:Touch = event.getTouch(stage, TouchPhase.MOVED);
			if (touchMoved)
			{
				if(isMoving) onMove( touchMoved.getLocation(stage) );
			}
			var touchEnded:Touch = event.getTouch(stage, TouchPhase.ENDED);
			if (touchEnded)
			{
				onMouseUp( touchEnded.getLocation(stage) );
			}
		}
		private var startMoveX:Number;
		private var previousMoveX:Number;
		private var isMoving:Boolean;
		private var movingBack:Boolean;
		private var hasMoveEnterFrame:Boolean;
		private function beginMove( mouse:Point ):void
		{
			if(hasMoveEnterFrame)
			{
				hasMoveEnterFrame = false;
				this.removeEventListener(EnterFrameEvent.ENTER_FRAME, onBackReleaseSwipe);
			}
			if(!swipeView) return;
			var left:Number = 0, right:Number, top:Number = 0, bottom:Number;
			if(owner)
			{
				left = owner.left;
				right = stage.stageWidth - owner.right;
				top = (owner.tabBarAlign == "top") ? owner.top + owner.tabBarHeight : owner.top;
				bottom = isNaN(owner.bottom) ? 0 : owner.bottom;
				bottom = (owner.tabBarAlign == "bottom") ? stage.stageHeight - (bottom + owner.tabBarHeight) : stage.stageHeight - bottom;
			}
			else
			{
				right = stage.stageWidth;
				bottom = stage.stageHeight;
			}
			if(mouse.x < left || mouse.y < top || mouse.x > right || mouse.y > bottom) return;
			for each(var _class:String in (this.activeScreen as Object)._excludeClassesForSlide) //exclude classes
			{
				if(getQualifiedClassName(FocusManager.focus) == _class && _class != "") return;
			}
			for each(var object:String in (this.activeScreen as Object)._excludeComponentsForSlide) //exclude components
			{
				if((this.activeScreen as Object).hasOwnProperty(object))
				{
					if(FocusManager.focus == (this.activeScreen as Object)[object]) return;
				}
				else
				{
					throw new Error("The components \""+object+"\" doesn't exist in \""+getQualifiedClassName( getDefinitionByName( getHistoryClassName( this.activeScreenID ) ) )+"\" class.");
				}
			}
			isMoving = true;
			previousMoveX = startMoveX = mouse.x;
		}
		private function onMove( mouse:Point ):void
		{
			if(mouse.x < 0 || mouse.y < 0 || mouse.x > stage.stageWidth || mouse.y > stage.stageHeight)
			{
				onMouseUp();
				return;
			}
			if(!tempScreen)
			{
				if(mouse.x < startMoveX - latencyToStartSwipe) //next
				{
					if(position == _history.length-1) return;
					previousMoveX = mouse.x;
					showViewInternal(_history[position+1], null, {data : _historyData[position+1]});
					tempScreen.x = stage.stageWidth;
					movingBack = false;
				}
				else if(mouse.x > startMoveX + latencyToStartSwipe) //previous
				{
					if(position == 0) return;
					previousMoveX = mouse.x;
					showViewInternal(_history[position-1], null, {data : _historyData[position-1]});
					tempScreen.x = -stage.stageWidth;
					movingBack = true;
				}
			}
			else
			{
				this.activeScreen.x += (mouse.x - previousMoveX ) * speedSwipe;
				tempScreen.x += (mouse.x - previousMoveX ) * speedSwipe;
				if(mouse.x < previousMoveX)
				{
					if(!movingBack && tempScreen.x < 0) //next and left
					{
						tempScreen.x = 0;
						this._stack[this._stack.length] = new StackItem(this.activeScreenID, null);
						this.clearScreenInternal();
						this._activeScreen = tempScreen;
						this._activeScreenID = (tempScreen as IScreen).screenID;
						removeTemp(true);
					}
					else if(movingBack && this._activeScreen.x < 0) //previous and left
					{
						this._activeScreen.x = 0;
					}
				}
				else if(mouse.x > previousMoveX)
				{
					if(movingBack && tempScreen.x > 0)  //previous and right
					{
						tempScreen.x = 0;
						this._stack.pop();
						this.clearScreenInternal();
						this._activeScreen = tempScreen;
						this._activeScreenID = (tempScreen as IScreen).screenID;
						removeTemp(true);
					}
					else if(!movingBack && this._activeScreen.x > 0) //next and right
					{
						this._activeScreen.x = 0;
					}
				}
				previousMoveX = mouse.x;
			}
		}
		private function onMouseUp( mouse:Point = null ):void
		{
			isMoving = false;
			
			if(!tempScreen) return;
			if(!hasMoveEnterFrame)
			{
				hasMoveEnterFrame = true;
				this.addEventListener(EnterFrameEvent.ENTER_FRAME, onBackReleaseSwipe);
			}
		}
		private function onBackReleaseSwipe(event:EnterFrameEvent):void
		{
			if(!movingBack)
			{
				tempScreen.x += speedBackReleaseSwipe;
				this.activeScreen.x += speedBackReleaseSwipe;
				if(this._activeScreen.x > 0) //next and right
				{
					this._activeScreen.x = 0;
					removeTemp();
				}
			}
			else
			{
				tempScreen.x -= speedBackReleaseSwipe;
				this.activeScreen.x -= speedBackReleaseSwipe;
				if(this._activeScreen.x < 0) //previous and left
				{
					this._activeScreen.x = 0;
					removeTemp();
				}
			}
		}
		private function removeTemp(isMove:Boolean = false):void
		{
			if(tempScreen != this.activeScreen) this.removeChild(tempScreen);
			tempScreen.removeEventListener(Event.RESIZE, tempScreen_resizeHandler);
			tempScreen = null;
			if(hasMoveEnterFrame)
			{
				hasMoveEnterFrame = false;
				this.removeEventListener(EnterFrameEvent.ENTER_FRAME, onBackReleaseSwipe);
			}
			if(isMove) onMouseUp();
		}
		
		private var _swipeView:Boolean;
		/**
		 * Swipe to change View
		 *
		 * [ViewNavigatorApplication-only].
		 *
		 * @default false
		 */
		public function get swipeView():Boolean
		{
			return owner ? owner.swipeView : _swipeView;
		}
		public function set swipeView(value:Boolean):void
		{
			_swipeView = value;
		}
		
		private var _speedSwipe:Number = 3;
		/**
		 * Swipe speed to change View
		 *
		 * [ViewNavigatorApplication-only].
		 *
		 * @default 3
		 */
		public function get speedSwipe():Number
		{
			return owner ? owner.speedSwipe : _speedSwipe;
		}
		public function set speedSwipe(value:Number):void
		{
			_speedSwipe = value;
		}
		
		private var _speedBackReleaseSwipe:uint = 10;
		/**
		 * Speed back in pixels when you release swipe
		 *
		 * [ViewNavigatorApplication-only].
		 *
		 * @default 10
		 */
		public function get speedBackReleaseSwipe():uint
		{
			return owner ? owner.speedBackReleaseSwipe : _speedBackReleaseSwipe;
		}
		public function set speedBackReleaseSwipe(value:uint):void
		{
			_speedBackReleaseSwipe = value;
		}
		
		private var _latencyToStartSwipe:uint = 10;
		/**
		 * The latency in pixels to start swipe
		 *
		 * [ViewNavigatorApplication-only].
		 *
		 * @default 10
		 */
		public function get latencyToStartSwipe():uint
		{
			return owner ? owner.latencyToStartSwipe : _latencyToStartSwipe;
		}
		public function set latencyToStartSwipe(value:uint):void
		{
			_latencyToStartSwipe = value;
		}
	}
}