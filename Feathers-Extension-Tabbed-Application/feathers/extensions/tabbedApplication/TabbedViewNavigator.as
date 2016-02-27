/*
Copyright 2016 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.extensions.tabbedApplication
{
	import feathers.data.ListCollection;
	import feathers.controls.ScreenNavigatorItem;
	import flash.events.Event;
	import starling.events.Event;
	import starling.events.EnterFrameEvent;
	import feathers.controls.LayoutGroup;
	import feathers.controls.TabBar;
	import feathers.layout.AnchorLayoutData;
	//import feathers.controls.ScreenNavigator;
	import flash.net.SharedObject;
	import feathers.layout.AnchorLayout;
	import flash.desktop.NativeApplication;
	import starling.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import feathers.events.FeathersEventType;
	import feathers.controls.ScrollContainer;
	import feathers.controls.ToggleButton;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.events.Touch
	import flash.geom.Point;
	import feathers.controls.IScreen;
	import feathers.controls.supportClasses.IScreenNavigatorItem;
	import feathers.core.FocusManager;
	import starling.display.DisplayObject;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getDefinitionByName;
	import starling.core.Starling;

	/**
	 * A container takes a <code>tab Bar</code> and <code>ViewNavigator</code>s , based on <code>LayoutGroup</code>.
	 *
	 * @see http://pol2095.free.fr/Feathers-Extension-Tabbed-Application/TabbedViewNavigatorApplication.html How to use TabbedViewNavigatorApplication with mxml
	 * @see feathers.controls.TabBar
	 * @see components.ViewNavigator
	 * @see components.View
	 * @see components.PanelView
	 * @see feathers.controls.LayoutGroup
	 */
	public class TabbedViewNavigator extends LayoutGroup
	{
		/**
		 * The tab bar.
		 */
		public var tabBar:TabBar;
		/**
		 * The tab bar scroller.
		 * 
		 * @private 
		 */
		public var scroller:ScrollContainer;
		private var layoutDataTB:AnchorLayoutData;
		/**
		 * The navigators that showing the views
		 */
		private var screenNavigator:TabbedScreenNavigator;
		private var layoutDataVN:AnchorLayoutData;
		private var isScrollToIndex:Boolean = true;
		private var _tabBarHeight:Number = 0;
		private var scrollerHeight:Number = 0;
		
		/**
		 * Constructor. 
		 */
		public function TabbedViewNavigator()
		{
			super();
			
			var container:LayoutGroup = new LayoutGroup();
			container.layout = new AnchorLayout();
			
			scroller = new ScrollContainer();
			layoutDataTB = new AnchorLayoutData();
			layoutDataTB.right = layoutDataTB.top = layoutDataTB.left = 0;
			scroller.layoutData = layoutDataTB;
			tabBar = new TabBar();
			scroller.addChild( tabBar );
			container.addChild( scroller );
			
			screenNavigator = new TabbedScreenNavigator();
			layoutDataVN = new AnchorLayoutData();
			screenNavigator.layoutData = layoutDataVN;
			layoutDataVN.bottom = layoutDataVN.right = layoutDataVN.top = layoutDataVN.left = 0;
			layoutDataVN.topAnchorDisplayObject = this.scroller;
			container.addChild( screenNavigator );
			
			this.addChild( container );
			
			tabBar.addEventListener(starling.events.Event.CHANGE, tabBar_changeHandler);
			
			this.addEventListener(FeathersEventType.CREATION_COMPLETE, creationCompleteHandler);
		}
		
		private var listCollection:ListCollection = new ListCollection();
		/**
		 * Persistence shared object
		 * 
		 * @private 
		 */
		public var my_so:SharedObject = SharedObject.getLocal("feathersPersistenceManager");
		private var init:Boolean;
		
		private var _tabBarAutoHide:Boolean = true;
		/**
		 * Auto-hide the tab bar.
		 *
		 * @default true
		 */
		public function get tabBarAutoHide():Boolean
		{
			return _tabBarAutoHide;
		}
		public function set tabBarAutoHide(value:Boolean):void
		{
			_tabBarAutoHide = value;
		}
		
		private var hasEventListener_keyCode:Boolean;
		private var _keyCode:String;
		/**
		 * Keyboard key code to pop view.
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
			if(!stage) return;
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
		
		private var hasEventListener_persistNavigatorState:Boolean;
		private var _persistNavigatorState:Boolean;
		/**
		 * In-memory persistence saves navigators, views and data as the user navigates the application.
		 *
		 * @default false
		 */
		public function get persistNavigatorState():Boolean
		{
			return _persistNavigatorState;
		}
		public function set persistNavigatorState(value:Boolean):void
		{
			_persistNavigatorState = value;
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
		
		private var _bottom:Number = NaN;
		/**
		 * Distance from the bottom of the application.
		 *
		 * @default NaN
		 */
		public function get bottom():Number
		{
			return isNaN(_bottom) ? 0 : _bottom;
		}
		public function set bottom(value:Number):void
		{
			_bottom = value;
			if(!isCreated) return;
			if(tabBarAlign != "top")
			{
				layoutDataTB.bottom = bottom + top;
			}
		}
		
		private var _top:Number = 0;
		/**
		 * Distance from the top of the application.
		 *
		 * @default 0
		 */
		public function get top():Number
		{
			return _top;
		}
		public function set top(value:Number):void
		{
			_top = value;
			if(!isCreated) return;
			if(tabBarAlign == "top")
			{
				layoutDataTB.top = top;
			}
			else
			{
				layoutDataTB.bottom = bottom + top;
				layoutDataVN.top = top;
			}
		}
		
		private var _tabBarAlign:String = "top";
		/**
		 * The vertical alignment of the tabBar.
		 *
		 * <p>Possible values are "top" or "bottom".</p>
		 *
		 * @default "top"
		 */
		public function get tabBarAlign():String
		{
			return _tabBarAlign;
		}
		public function set tabBarAlign(value:String):void
		{
			_tabBarAlign = value;
		}
		
		private var _left:Number = 0;
		/**
		 * Distance from the left of the application.
		 *
		 * @default 0
		 */
		public function get left():Number
		{
			return _left;
		}
		public function set left(value:Number):void
		{
			_left = value;
			layoutDataTB.left = value;
			layoutDataVN.left = value;
			if(isCreated) resizeHandler();
		}
		
		private var _right:Number = 0;
		/**
		 * Distance from the right of the application.
		 *
		 * @default 0
		 */
		public function get right():Number
		{
			return _right;
		}
		public function set right(value:Number):void
		{
			_right = value;
			if(isCreated) resizeHandler(); 
		}
		
		/**
		 * Add a new tab to the navigation bar.
		 *
		 * @param label tab name.
		 *
		 * @param screen view class.
		 *
		 * @param data data send to the view.
		 *
		 * @param transition.
		 */
		public function addElement(label:String, screen:Object, data:Object = null, transition:Function = null):void
		{
			stage.addEventListener(EnterFrameEvent.ENTER_FRAME, onInit);
			if(!tabBar.dataProvider)
			{
				tabBar.dataProvider = new ListCollection();
				if(!my_so.data.viewsHistory)
				{
					var vnID:String = newID();
					createElement(label, vnID, screen, data, transition);
					this.selectedIndex = 0;
				}
				else
				{
					init = true;
					var tabBarHistory:Vector.<Object> = Vector.<Object>(my_so.data.tabBarHistory);
					var navigatorsHistory:Vector.<Object> = Vector.<Object>(my_so.data.viewsHistory);
					for(var i:uint = 0; i < tabBarHistory.length; i++)
					{
						createElement(tabBarHistory[i].label, tabBarHistory[i].vnID, screen, data, transition, Vector.<String>(navigatorsHistory[i]._history), Vector.<Object>(navigatorsHistory[i]._historyData), navigatorsHistory[i].position);
					}
					validateNow();
					this.selectedIndex = my_so.data.tabBarSelected;
				}
			}
			else if(!init)
			{
				createElement(label, newID(), screen, data, transition);
			}
		}
		
		/**
		 * Add a new tab to the navigation bar at the specified index.
		 *
		 * @param index tab position.
		 *
		 * @param label tab name.
		 *
		 * @param screen view class.
		 *
		 * @param data data send to the view.
		 *
		 * @param transition.
		 */
		public function addElementAt(index:uint, label:String, screen:Object, data:Object = null, transition:Function = null):void
		{
			addElement(label, screen, data, transition);
			if(this.length != 1) moveElement(this.length-1, index);
		}
		
		private function createElement(label:String, vnID:String, screen:Object, data:Object, transition:Function, _history:Vector.<String> = null, _historyData:Vector.<Object> = null, position:uint = 0):void
		{
			tabBar.dataProvider.addItem( { label: label, vnID: vnID } );
			validateNow();
			var tab:ToggleButton = tabBar.getChildAt(tabBar.dataProvider.length-1) as ToggleButton;
			tab.isLongPressEnabled = dragTab;
			tab.addEventListener( FeathersEventType.LONG_PRESS, longPresshandler);
			var navigator:ViewNavigator = new ViewNavigator(screen, data, transition, this, vnID, _history, _historyData, position);
			screenNavigator.addScreen(vnID, new ScreenNavigatorItem(navigator));
			if(!tabBarAutoHide) return;
			if(tabBar.dataProvider.length == 1)
			{
				hideTabBar();
			}
			else if(tabBar.dataProvider.length == 2)
			{
				showTabBar();
			}
		}
		
		private function newID():String
		{
			var ids:Vector.<String> = screenNavigator.getScreenIDs();
			var i:uint;
			while(ids.indexOf("vn"+i) != -1) i++;
			return "vn"+i;
		}
		
		private function tabBar_changeHandler( event:starling.events.Event ):void
		{
			if(screenNavigator.activeScreenID != tabBar.selectedItem.vnID)
			{
				screenNavigator.showScreen(tabBar.selectedItem.vnID);
				screenNavigator.activeScreen.x = 0;
				(screenNavigator.activeScreen as Object).activeScreen.width = stage.stageWidth - left - right;
				resizeHandler();
			}
		}
		
		private function onDeactivate(event:flash.events.Event):void
		{
			save();
		}
		
		/**
		 * Save the navigators, views and data.
		 */
		public function save():void
		{
			if(persistNavigatorState)
			{
				var tabBarHistory:Vector.<Object> = new Vector.<Object>();
				var navigatorsHistory:Vector.<Object> = new Vector.<Object>();
				var navigator:ViewNavigator;
				for(var i:uint; i < tabBar.dataProvider.length; i++)
				{
					tabBarHistory.push( { label:tabBar.dataProvider.getItemAt(i).label, vnID:tabBar.dataProvider.getItemAt(i).vnID } );
					navigator = screenNavigator.getScreen(tabBar.dataProvider.getItemAt(i).vnID).getScreen() as ViewNavigator;
					navigator.historyDataUpdate();
					navigatorsHistory.push( { _history: navigator._history, _historyData: navigator._historyData, position: navigator.position } );
				}
				my_so.data.tabBarSelected = this.selectedIndex;
				my_so.data.tabBarHistory = tabBarHistory;
				my_so.data.viewsHistory = navigatorsHistory;
				my_so.flush();
			}
		}
		
		/**
		 * Clear the persistence navigators, views and data.
		 */
		public function clear():void
		{
			if(my_so.data.viewsHistory)
			{
				delete my_so.data.tabBarSelected;
				delete my_so.data.tabBarHistory;
				delete my_so.data.viewsHistory;
			}
		}
		
		/**
		 * Exit to the application and clear the persistence navigators, views and data.
		 */
		public function exit(errorCode:int = 0):void
		{
			_persistNavigatorState = false;
			clear();
			NativeApplication.nativeApplication.exit(errorCode);
		}
		
		private function onInit(event:EnterFrameEvent):void
		{
			init = false;
			stage.removeEventListener(EnterFrameEvent.ENTER_FRAME, onInit);
		}
		
		/**
		 * Hide the tab bar.
		 */
		public function hideTabBar():void
		{			
			if(scroller.visible) scroller.includeInLayout = scroller.visible = false;
		}
		
		/**
		 * Show the tab bar.
		 */
		public function showTabBar():void
		{			
			if(!scroller.visible) scroller.includeInLayout = scroller.visible = true;
		}
		
		/**
		 * Remove a tab at the specified index.
		 *
		 * If you the remove the last and only tab, you trigger the exit function
		 *
		 * @param index tab position.
		 */
		public function removeElementAt(index:int):void
		{			
			if(tabBar.dataProvider.length > 1)
			{
				var selectedItemID:String; 
				if(this.selectedIndex != index) 
				{
					selectedItemID = tabBar.selectedItem.vnID;
				}
				else if(index == tabBar.dataProvider.length-1)
				{
					selectedItemID = tabBar.dataProvider.getItemAt(index-1).vnID;
				}
				else
				{
					selectedItemID = tabBar.dataProvider.getItemAt(index+1).vnID;
				}
				screenNavigator.removeScreen(tabBar.dataProvider.getItemAt(index).vnID);
				tabBar.dataProvider.removeItemAt(index);
				isScrollToIndex = false;
				this.selectedIndex = dpIndexOf(tabBar.dataProvider, selectedItemID);
				isScrollToIndex = true;
				if(tabBar.dataProvider.length == 1 && tabBarAutoHide) hideTabBar();
			}
			else
			{
				exit();
			}
		}
		
		/**
		 * Rename a tab at the specified index.
		 *
		 * @param index tab position.
		 *
		 * @param label new tab name.
		 */
		public function renameElementAt(index:int, label:String):void
		{			
			tabBar.dataProvider.setItemAt( { label: label, vnID: tabBar.dataProvider.getItemAt(index).vnID }, index);
		}
		
		/**
		 * Move a tab at the specified index.
		 *
		 * @param indexToMove tab to move.
		 *
		 * @param newIndex new position of this tab.
		 */
		public function moveElement(indexToMove:int, newIndex:int):void
		{			
			if(tabBar.dataProvider.length > 1 && indexToMove != newIndex)
			{
				var selectedItemID:String = tabBar.selectedItem.vnID;
				var itemToMove:Object = tabBar.dataProvider.getItemAt(indexToMove);
				tabBar.dataProvider.removeItemAt(indexToMove);
				tabBar.dataProvider.addItemAt(itemToMove, newIndex);
				isScrollToIndex = false;
				this.selectedIndex = dpIndexOf(tabBar.dataProvider, selectedItemID);
				isScrollToIndex = true;
			}
		}
		
		/**
		 * Replace a tab at the specified index.
		 *
		 * @param index tab position.
		 *
		 * @param name new tab name.
		 *
		 * @param screen view class.
		 *
		 * @param data data send to the view.
		 *
		 * @param transition.
		 */
		public function replaceElementAt(index:int, label:String, screen:Object, data:Object = null, transition:Function = null):void
		{			
			renameElementAt(index, label);
			if(index == this.selectedIndex) screenNavigator.clearScreen();
			screenNavigator.removeScreen(tabBar.dataProvider.getItemAt(index).vnID);
			clear();
			var navigator:ViewNavigator = new ViewNavigator(screen, data, transition, this, tabBar.dataProvider.getItemAt(index).vnID);
			screenNavigator.addScreen(tabBar.dataProvider.getItemAt(index).vnID, new ScreenNavigatorItem(navigator));
			if(index == this.selectedIndex) screenNavigator.showScreen(tabBar.dataProvider.getItemAt(index).vnID);
		}
		
		private function dpIndexOf(dataProvider:ListCollection, search:String):int
		{			
			for(var i:uint; i < tabBar.dataProvider.length; i++)
			{
				if(dataProvider.getItemAt(i).vnID == search) return i;
			}
			return -1;
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
				if(activeNavigator.position != 0)
				{
					activeNavigator.popView();
					event.preventDefault();
				}
			}
		}
		
		/**
		 * The active navigator.
		 */
		public function get activeNavigator():ViewNavigator
		{
			return screenNavigator.getScreen(tabBar.dataProvider.getItemAt(this.selectedIndex).vnID).getScreen() as ViewNavigator;
		}
		
		/**
		 * Number of tabs.
		 */
		public function get length():uint
		{
			return tabBar.dataProvider.length;
		}
		
		/**
		 * The tab bar height.
		 */
		public function get tabBarHeight():Number
		{
			return scroller.visible ? scroller.height : 0;
		}
		
		/**
		 * Return the navigator at the specified index.
		 *
		 * @param index tab position
		 */
		public function getNavigatorAt(index:uint):ViewNavigator
		{
			return screenNavigator.getScreen(tabBar.dataProvider.getItemAt(index).vnID).getScreen() as ViewNavigator;
		}
		
		private function creationCompleteHandler(event:starling.events.Event):void
		{
			this.removeEventListener(FeathersEventType.CREATION_COMPLETE, creationCompleteHandler);
			tabBar.distributeTabSizes = distributeTabSizes;
			
			if(tabBarAlign == "top")
			{
				layoutDataTB.top = top;
			}
			else
			{
				layoutDataTB.top = NaN;
				layoutDataTB.bottom = bottom + top;
				layoutDataVN.bottom = NaN;
				layoutDataVN.top = top;
				layoutDataVN.topAnchorDisplayObject = null;
				layoutDataVN.bottomAnchorDisplayObject = this.scroller;
			}
			
			if(keyCode && !hasEventListener_keyCode)
			{
				hasEventListener_keyCode = true;
				stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			}
			scroller.addEventListener(starling.events.Event.RESIZE, resizeHandler);
			stage.addEventListener(starling.events.Event.RESIZE, resizeHandler);
			
			stage.addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		private function resizeHandler(event:starling.events.Event = null):void
		{
			var scrollerWidth:Number = Math.min(scroller.viewPort.width, stage.stageWidth - left - right);
			if(scroller.width != scrollerWidth) scroller.width = scrollerWidth;
			
			if(screenNavigator.activeScreen)
			{
				if((screenNavigator.activeScreen as Object).activeScreen)
				{
					(screenNavigator.activeScreen as Object).activeScreen.width = stage.stageWidth - left - right;
					(screenNavigator.activeScreen as Object).activeScreen.height = stage.stageHeight - top - bottom - tabBarHeight;
				}
			}
		}
		
		private var _selectedIndex:int = -1;
		/**
		 * The index of the currently selected tabBar.
		 */
		public function get selectedIndex():int
		{
			return tabBar.selectedIndex;
		}
		public function set selectedIndex(value:int):void
		{
			if(value < 0)
			{
				/*tabBar.selectedIndex = -1;
				screenNavigator.clearScreen();*/
				return;
			}
			if(screenNavigator.activeScreenID != tabBar.dataProvider.getItemAt(value).vnID)
			{
				tabBar.selectedIndex = value;
				scrollToIndex(this.selectedIndex);
			}
		}
		
		/**
		 * Scroll to the index currently selected in the tabBar.
		 */
		private function scrollToIndex(index:int):void
		{
			if(!isScrollToIndex) return;
			if(scroller.viewPort.width > scroller.width)
			{
				var tabs:Array = [];
				for(var i:uint; i<tabBar.numChildren; i++) tabs.push(tabBar.getChildAt(i));
				tabs.sortOn("x", Array.NUMERIC);
				
				if(tabs[index].width > scroller.width) //tab width > scroller width
				{
					scroller.horizontalScrollPosition = tabs[index].x; //tab begin
				}
				else if(tabs[index].x < scroller.horizontalScrollPosition) //tab begin < scroller begin
				{
					scroller.horizontalScrollPosition = tabs[index].x; //tab begin
				}
				else if(tabs[index].x + tabs[index].width > scroller.horizontalScrollPosition + scroller.width) //tab end > scroller end
				{
					scroller.horizontalScrollPosition = tabs[index].x + tabs[index].width - scroller.width; //tab end - scroller width
				}
			}
		}
		
		/**
		 * Immediately validates the display object, if it is invalid.
		 *
		 *  The validation system exists to postpone updating a display object after properties are changed until until the last possible moment the display object is rendered. This allows multiple properties to be changed at a time without requiring a full update every time.
		 */
		public function validateNow():void
		{
			tabBar.validate();
			scroller.validate();
		}
		
		/**
		 * Return the tab name at the specified index.
		 *
		 * @param index tab position
		 */
		public function getElementNameAt(index:uint):String
		{
			return tabBar.dataProvider.getItemAt(index).label;
		}
		
		/**
		 * The active tab name.
		 */
		public function get activeElementName():String
		{
			return getElementNameAt(this.selectedIndex);
		}
		public function set activeElementName(value:String):void
		{
			renameElementAt(this.selectedIndex, value);
		}
		
		/**
		 * @private 
		 */
		override protected function feathersControl_addedToStageHandler(event:starling.events.Event):void
		{
			preinitialize();
		}
		/**
		 * override this method to perform other tasks before the application is displayed.
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
		 *     super.preinitialize();
		 * }</listing> 
		 */
		protected function preinitialize():void
		{
			if(!isInitialized) super.feathersControl_addedToStageHandler(null);
		}
		
		private var _swipeView:Boolean;
		/**
		 * Swipe to change View
		 *
		 * @default false
		 */
		public function get swipeView():Boolean
		{
			return _swipeView;
		}
		public function set swipeView(value:Boolean):void
		{
			_swipeView = value;
		}
		
		private var _swipeSpeed:Number = 3;
		/**
		 * Swipe speed to change View.
		 *
		 * @default 3
		 */
		public function get swipeSpeed():Number
		{
			return _swipeSpeed;
		}
		public function set swipeSpeed(value:Number):void
		{
			_swipeSpeed = value;
		}
		
		private var _swipeSpeedBackRelease:uint = 10;
		/**
		 * Speed back in pixels when you release swipe.
		 *
		 * @default 10
		 */
		public function get swipeSpeedBackRelease():uint
		{
			return _swipeSpeedBackRelease;
		}
		public function set swipeSpeedBackRelease(value:uint):void
		{
			_swipeSpeedBackRelease = value;
		}
		
		private var _swipeLatencyToStart:uint = 10;
		/**
		 * The latency in pixels to start swipe.
		 *
		 * @default 10
		 */
		public function get swipeLatencyToStart():uint
		{
			return _swipeLatencyToStart;
		}
		public function set swipeLatencyToStart(value:uint):void
		{
			_swipeLatencyToStart = value;
		}
		
		private var _swipeNavigator:Boolean;
		/**
		 * Swipe to change Navigator
		 *
		 * @default false
		 */
		public function get swipeNavigator():Boolean
		{
			return _swipeNavigator;
		}
		public function set swipeNavigator(value:Boolean):void
		{
			_swipeNavigator = value;
		}
		
		private function onTouch(event:TouchEvent):void
		{
			if(!swipeNavigator)
			{
				activeNavigator.onTouch( event );
			}
			else
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
					if(isTabMoving) onTabMove( touchMoved.getLocation(stage) );
				}
				var touchEnded:Touch = event.getTouch(stage, TouchPhase.ENDED);
				if (touchEnded)
				{
					onMouseUp( touchEnded.getLocation(stage) );
					if(isTabMoving) onTabMouseUp( touchEnded.getLocation(stage) );
				}
			}
		}
		
		private var isTabMoving:Boolean;
		private var tabIndexMoving:uint;
		private var tabMoving:ToggleButton;
		private var mouse:Point;
		private var tabMouseX:Number; //mouseX on tab
		private function longPresshandler( event:starling.events.Event ):void
		{
			if(this.length == 1 || !dragTab) return;
			tabMoving = (event.target as Object) as ToggleButton;
			tabMouseX = mouse.x - (left + tabMoving.x - scroller.horizontalScrollPosition);
			var tabs:Array = [];
			for(var i:uint; i<tabBar.numChildren; i++) tabs.push(tabBar.getChildAt(i));
			tabs.sortOn("x", Array.NUMERIC);
			for(i=0; i<tabs.length; i++)
			{
				if(tabs[i] == tabMoving)
				{
					tabIndexMoving = i;
					break;
				}
			}
			tabMoving.includeInLayout = false;
			tabBar.invalidate("content");
			validateNow();
			
			if(scroller.viewPort.width == scroller.width) //scroller width and the right border position of the tabBar
			{
				scrollerWidth = 0;
				for(i=0; i<tabBar.numChildren; i++)
				{
					if(tabBar.getChildAt(i) != tabMoving) scrollerWidth += tabBar.getChildAt(i).width;
				}
				rightTabBar = left + scrollerWidth;
			}
			else
			{
				scrollerWidth = stage.stageWidth - left - right;
				rightTabBar = stage.stageWidth - right;
			}
			
			onTabMove( mouse );
			tabMoving.parent.setChildIndex(tabMoving, tabMoving.parent.numChildren - 1)
			isTabMoving = true;
			tabMoving.alpha = dragTabAlpha;
			Starling.current.stage.addEventListener(EnterFrameEvent.ENTER_FRAME, EnterFrameDragHandler);
			if(scroller.height > tabBar.height) return; //desktop
			scroller.horizontalScrollPolicy = "off";
		}
		
		private function EnterFrameDragHandler():void {
			if(scroller.viewPort.width > scroller.width)
			{
				if(mouse.x > left && mouse.x <= left + dragTabScrollEdgeStart / 2)
				{
					(scroller.horizontalScrollPosition > 0) ? scroller.horizontalScrollPosition -= dragTabScrollEdgeSpeed : scroller.horizontalScrollPosition = 0;
					onTabMove( mouse );
				}
				else if(mouse.x > left + dragTabScrollEdgeStart / 2 && mouse.x <= left + dragTabScrollEdgeStart)
				{
					(scroller.horizontalScrollPosition > 0) ? scroller.horizontalScrollPosition -= dragTabScrollEdgeSpeed / 2 : scroller.horizontalScrollPosition = 0;
					onTabMove( mouse );
				}
				else if(mouse.x >= stage.stageWidth - right - dragTabScrollEdgeStart && mouse.x < stage.stageWidth - right - dragTabScrollEdgeStart / 2)
				{
					(scroller.horizontalScrollPosition < scroller.maxHorizontalScrollPosition) ? scroller.horizontalScrollPosition += dragTabScrollEdgeSpeed / 2 : scroller.horizontalScrollPosition = scroller.maxHorizontalScrollPosition;
					onTabMove( mouse );
				}
				else if(mouse.x >= stage.stageWidth - right - dragTabScrollEdgeStart / 2 && mouse.x < stage.stageWidth - right)
				{
					(scroller.horizontalScrollPosition < scroller.maxHorizontalScrollPosition) ? scroller.horizontalScrollPosition += dragTabScrollEdgeSpeed : scroller.horizontalScrollPosition = scroller.maxHorizontalScrollPosition;
					onTabMove( mouse );
				}
			}
		}
		
		private var scrollerWidth:Number; //scroller width 
		private var rightTabBar:Number; //the right border position of the tabBar
		private function onTabMove( mouse:Point ):void
		{
			this.mouse = mouse;
			
			var endRightTabMoving:Number = (tabMoving.width > scrollerWidth) ? 0 : tabMoving.width;
			
			if(mouse.x - tabMouseX >= left && mouse.x - tabMouseX <= rightTabBar - endRightTabMoving)
			{
				tabMoving.x = scroller.horizontalScrollPosition + mouse.x - left - tabMouseX;
				tabMouseX = mouse.x - (left + tabMoving.x - scroller.horizontalScrollPosition);
			}
			else if(mouse.x - tabMouseX < left)
			{
				tabMoving.x = scroller.horizontalScrollPosition;
			}
			else if(mouse.x - tabMouseX > rightTabBar - endRightTabMoving)
			{
				tabMoving.x = scroller.horizontalScrollPosition - endRightTabMoving + rightTabBar - left;
			}
		}
		
		private function onTabMouseUp( mouse:Point = null ):void
		{
			var mouseX:Number = 0; //mouse.x position
			if(mouse.x >= left && mouse.x <= rightTabBar) mouseX = mouse.x - left;
			if(mouse.x > rightTabBar) mouseX = scrollerWidth;
			
			var tabMouseUpX:Number = scroller.horizontalScrollPosition + mouseX;
			var tabs:Array = [];
			for(var i:uint; i<tabBar.numChildren; i++)
			{
				if(tabBar.getChildAt(i) != tabMoving) tabs.push(tabBar.getChildAt(i));
			}
			tabs.sortOn("x", Array.NUMERIC);
			tabs.splice(tabIndexMoving, 0, tabMoving);
			var newIndex:uint;
			for(i=0; i<tabs.length; i++)
			{
				if(tabs[i] != tabMoving)
				{
					if(tabMouseUpX >= tabs[i].x && tabMouseUpX <= tabs[i].x + tabs[i].width)
					{
						if(tabMouseUpX >= tabs[i].x && tabMouseUpX <= tabs[i].x + tabs[i].width / 2)
						{
							newIndex = i;
						}
						else if(tabMouseUpX > tabs[i].x + tabs[i].width / 2 && tabMouseUpX <= tabs[i].x + tabs[i].width)
						{
							newIndex = i + 1;
						}
						break;
					}
				}
			}
			tabMoving.includeInLayout = true;
			tabBar.invalidate("content");
			if(tabIndexMoving < newIndex) newIndex--;
			moveElement(tabIndexMoving, newIndex);
			validateNow();
			scrollToIndex(newIndex);
			tabMoving.alpha = 1;
			isTabMoving = false;
			scroller.horizontalScrollPolicy = "auto";
			Starling.current.stage.removeEventListener(EnterFrameEvent.ENTER_FRAME, EnterFrameDragHandler);
		}
		
		/**
		 * @private
		 */
		public var tempScreen:DisplayObject;
		private function showViewInternal(id:String, transition:Function = null):void
		{
			if(!screenNavigator.hasScreen(id))
			{
				throw new ArgumentError("Screen with id '" + id + "' cannot be shown because it has not been defined.");
			}

			var item:IScreenNavigatorItem = IScreenNavigatorItem(screenNavigator._views[id]);
			tempScreen = item.getScreen();
			tempScreen_resizeHandler();
			stage.addEventListener(starling.events.Event.RESIZE, tempScreen_resizeHandler);
			screenNavigator.addChild(tempScreen);
		}
		private function tempScreen_resizeHandler(event:starling.events.Event = null):void
		{
			var navigatorWidth:Number = stage.stageWidth - left - right;
			(tempScreen as ViewNavigator).activeScreen.width = navigatorWidth;
			(tempScreen as ViewNavigator).activeScreen.height = stage.stageHeight - top - bottom - tabBarHeight;
			tempScreen.x = movingBack ? screenNavigator.activeScreen.x - navigatorWidth : screenNavigator.activeScreen.x + navigatorWidth;
		}
		
		private var startMoveX:Number;
		private var previousMoveX:Number;
		private var isMoving:Boolean;
		private var movingBack:Boolean;
		private var hasMoveEnterFrame:Boolean;
		private function beginMove( mouse:Point ):void
		{
			this.mouse = mouse;
			if(hasMoveEnterFrame)
			{
				hasMoveEnterFrame = false;
				screenNavigator.removeEventListener(EnterFrameEvent.ENTER_FRAME, onBackReleaseSwipe);
			}
			if(!swipeView && !swipeNavigator) return;
			var left:Number = 0, right:Number, top:Number = 0, bottom:Number;
			left = this.left;
			right = stage.stageWidth - this.right;
			top = (tabBarAlign == "top") ? this.top + tabBarHeight : this.top;
			bottom = this.bottom;
			bottom = (tabBarAlign == "bottom") ? stage.stageHeight - (bottom + tabBarHeight) : stage.stageHeight - bottom;
			if(mouse.x < left || mouse.y < top || mouse.x > right || mouse.y > bottom) return;
			for each(var _class:String in (this.activeNavigator.activeScreen as Object)._excludeClassesForSlide) //exclude classes
			{
				if(getQualifiedClassName(FocusManager.focus) == _class && _class != "") return;
			}
			for each(var object:String in (this.activeNavigator.activeScreen as Object)._excludeComponentsForSlide) //exclude components
			{
				if((this.activeNavigator.activeScreen as Object).hasOwnProperty(object))
				{
					if(FocusManager.focus == (this.activeNavigator.activeScreen as Object)[object]) return;
				}
				else
				{
					throw new Error("The components \""+object+"\" doesn't exist in \""+getQualifiedClassName( getDefinitionByName( activeNavigator.getHistoryClassName( this.activeNavigator.activeScreenID ) ) )+"\" class.");
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
				if(mouse.x < startMoveX - swipeLatencyToStart) //next
				{
					if(this.selectedIndex == this.length-1) return;
					previousMoveX = mouse.x;
					showViewInternal(tabBar.dataProvider.getItemAt(this.selectedIndex+1).vnID);
					tempScreen.x = stage.stageWidth;
					movingBack = false;
				}
				else if(mouse.x > startMoveX + swipeLatencyToStart) //previous
				{
					if(this.selectedIndex == 0) return;
					previousMoveX = mouse.x;
					showViewInternal(tabBar.dataProvider.getItemAt(this.selectedIndex-1).vnID);
					tempScreen.x = -stage.stageWidth;
					movingBack = true;
				}
			}
			else
			{
				screenNavigator.activeScreen.x += (mouse.x - previousMoveX ) * swipeSpeed;
				tempScreen.x += (mouse.x - previousMoveX ) * swipeSpeed;
				if(mouse.x < previousMoveX)
				{
					if(!movingBack && tempScreen.x < 0) //next and left
					{
						tempScreen.x = 0;
						screenNavigator.clearViewInternal();
						screenNavigator.activeScreen = tempScreen;
						screenNavigator.activeScreenID = (tempScreen as ViewNavigator).vnID;
						tabBar.selectedIndex += 1;
						scrollToIndex(this.selectedIndex);
						removeTemp(true);
					}
					else if(movingBack && screenNavigator.activeScreen.x < 0) //previous and left
					{
						screenNavigator.activeScreen.x = 0;
					}
				}
				else if(mouse.x > previousMoveX)
				{
					if(movingBack && tempScreen.x > 0)  //previous and right
					{
						tempScreen.x = 0;
						screenNavigator.clearViewInternal();
						screenNavigator.activeScreen = tempScreen;
						screenNavigator.activeScreenID = (tempScreen as ViewNavigator).vnID;
						tabBar.selectedIndex -= 1;
						scrollToIndex(this.selectedIndex);
						removeTemp(true);
					}
					else if(!movingBack && screenNavigator.activeScreen.x > 0) //next and right
					{
						screenNavigator.activeScreen.x = 0;
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
				screenNavigator.addEventListener(EnterFrameEvent.ENTER_FRAME, onBackReleaseSwipe);
			}
		}
		private function onBackReleaseSwipe(event:EnterFrameEvent):void
		{
			if(!movingBack)
			{
				tempScreen.x += swipeSpeedBackRelease;
				screenNavigator.activeScreen.x += swipeSpeedBackRelease;
				if(screenNavigator.activeScreen.x > 0) //next and right
				{
					screenNavigator.activeScreen.x = 0;
					removeTemp();
				}
			}
			else
			{
				tempScreen.x -= swipeSpeedBackRelease;
				screenNavigator.activeScreen.x -= swipeSpeedBackRelease;
				if(screenNavigator.activeScreen.x < 0) //previous and left
				{
					screenNavigator.activeScreen.x = 0;
					removeTemp();
				}
			}
		}
		private function removeTemp(isMove:Boolean = false):void
		{
			if(tempScreen != screenNavigator.activeScreen) screenNavigator.removeChild(tempScreen);
			stage.removeEventListener(starling.events.Event.RESIZE, tempScreen_resizeHandler);
			tempScreen = null;
			if(hasMoveEnterFrame)
			{
				hasMoveEnterFrame = false;
				screenNavigator.removeEventListener(EnterFrameEvent.ENTER_FRAME, onBackReleaseSwipe);
			}
			if(isMove) onMouseUp();
		}
		
		private var _dragTab:Boolean;
		/**
		 * The elements of the tab bar can be moved
		 *
		 * @default false
		 */
		public function get dragTab():Boolean
		{
			return _dragTab;
		}
		public function set dragTab(value:Boolean):void
		{
			_dragTab = value;
			if(!isCreated) return;
			for(var i:uint; i<tabBar.numChildren; i++) (tabBar.getChildAt(i) as ToggleButton).isLongPressEnabled = value;
		}
		
		private var _distributeTabSizes:Boolean;
		/**
		 * If true, the tabs will be equally sized in the direction of the layout. In other words, if the tab bar is horizontal, each tab will have the same width, and if the tab bar is vertical, each tab will have the same height. If false, the tabs will be sized to their ideal dimensions.
		 *
		 * @default false
		 */
		public function get distributeTabSizes():Boolean
		{
			return _distributeTabSizes;
		}
		public function set distributeTabSizes(value:Boolean):void
		{
			_distributeTabSizes = value;
			if(isCreated) tabBar.distributeTabSizes = value;
		}
		
		private var _dragTabScrollEdgeStart:Number = 20;
		/**
		 * The distance in pixels from the edge of the tab bar where the tab bar sroll automatically.
		 *
		 * @default 20
		 */
		public function get dragTabScrollEdgeStart():Number
		{
			return _dragTabScrollEdgeStart;
		}
		public function set dragTabScrollEdgeStart(value:Number):void
		{
			_dragTabScrollEdgeStart = value;
		}
		
		private var _dragTabScrollEdgeSpeed:Number = 5;
		/**
		 * Scroll speed in pixels when the mouse is near the edge of the tab bar which allows scroll automatically the tab bar.
		 *
		 * @default 5
		 */
		public function get dragTabScrollEdgeSpeed():Number
		{
			return _dragTabScrollEdgeSpeed;
		}
		public function set dragTabScrollEdgeSpeed(value:Number):void
		{
			_dragTabScrollEdgeSpeed = value;
		}
		
		private var _dragTabAlpha:Number = 0.5;
		/**
		 * Indicates the alpha transparency value of the tab dragging. Valid values are 0 (fully transparent) to 1 (fully opaque). If alpha is set to 0, the tab is active, even though it's invisible.
		 *
		 * @default 0.5
		 */
		public function get dragTabAlpha():Number
		{
			return _dragTabAlpha;
		}
		public function set dragTabAlpha(value:Number):void
		{
			_dragTabAlpha = value;
		}
	}
}