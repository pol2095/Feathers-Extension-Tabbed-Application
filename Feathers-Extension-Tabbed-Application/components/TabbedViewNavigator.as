/*
Copyright 2016 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package components
{
	import feathers.data.ListCollection;
	import feathers.controls.ScreenNavigatorItem;
	import flash.events.Event;
	import starling.events.Event;
	import starling.events.EnterFrameEvent;
	import feathers.controls.LayoutGroup;
	import feathers.controls.TabBar;
	import feathers.layout.AnchorLayoutData;
	import feathers.controls.ScreenNavigator;
	import flash.net.SharedObject;
	import feathers.layout.AnchorLayout;
	import flash.desktop.NativeApplication;
	import starling.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import feathers.events.FeathersEventType;
	import feathers.controls.ScrollContainer;
	import feathers.controls.ToggleButton;
	
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
		private var screenNavigator:ScreenNavigator;
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
			
			screenNavigator = new ScreenNavigator();
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
		 * @default NaN.
		 */
		public function get bottom():Number
		{
			return _bottom;
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
		 * @default 0.
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
		
		/**
		 * The vertical alignment of the tabBar.
		 *
		 * <p>Possible values are "top" or "bottom".</p>
		 *
		 * @default "top".
		 */
		public var tabBarAlign:String = "top";
		
		private var _left:Number = 0;
		/**
		 * Distance from the left of the application.
		 *
		 * @default 0.
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
		 * @default 0.
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
				init = true;
				if(!my_so.data.viewsHistory)
				{
					init = false;
					var vnID:String = newID();
					createElement(label, vnID, screen, data, transition);
					this.selectedIndex = 0;
				}
				else
				{
					var tabBarHistory:Vector.<Object> = Vector.<Object>(my_so.data.tabBarHistory);
					var navigatorsHistory:Vector.<Object> = Vector.<Object>(my_so.data.viewsHistory);
					for(var i:uint = 0; i < tabBarHistory.length; i++)
					{
						createElement(tabBarHistory[i].label, tabBarHistory[i].vnID, screen, data, transition, Vector.<String>(navigatorsHistory[i]._history), Vector.<Object>(navigatorsHistory[i]._historyData));
					}
					this.selectedIndex = my_so.data.tabBarSelected;
				}
			}
			else if(!init)
			{
				createElement(label, newID(), screen, data, transition);
			}
		}
		
		private function createElement(label:String, vnID:String, screen:Object, data:Object, transition:Function, _history:Vector.<String> = null, _historyData:Vector.<Object> = null):void
		{
			tabBar.dataProvider.addItem( { label: label, vnID: vnID } );
			var navigator:ViewNavigator = new ViewNavigator(screen, data, transition, this, vnID, _history, _historyData);
			screenNavigator.addScreen(vnID, new ScreenNavigatorItem(navigator));
			_validate();
			(tabBar.dataProvider.length == 1) ? hideTabBar() : showTabBar();
		}
		
		private function newID():String
		{
			var ids:Vector.<String> = screenNavigator.getScreenIDs().sort(1);
			for (var i:uint=0; i < ids.length; i++)
			{
				if("vn"+(i+1) != ids[i]) break;
			}
			return "vn"+(i+1);
		}
		
		private function tabBar_changeHandler( event:starling.events.Event ):void
		{
			//if(this.selectedIndex < 0) return;
			if(screenNavigator.activeScreenID != tabBar.selectedItem.vnID) screenNavigator.showScreen(tabBar.selectedItem.vnID);
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
					navigator.removeScreens();
					navigator.historyDataUpdate();
					navigatorsHistory.push( { _history: navigator._history, _historyData: navigator._historyData } );
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
			stage.addEventListener(EnterFrameEvent.ENTER_FRAME, onInit);
		}
		
		/**
		 * Hide the tab bar.
		 */
		public function hideTabBar():void
		{			
			if(scroller.height == 0 || !tabBarAutoHide) return;
			tabBar.height = scroller.height = 0;
			_validate();
		}
		
		/**
		 * Show the tab bar.
		 */
		public function showTabBar():void
		{			
			if(isNaN(scroller.height) || !tabBarAutoHide) return;
			tabBar.height = scroller.height = NaN;
			_validate();
		}
		
		/**
		 * Remove a tab at the specified index.
		 *
		 * If you the remove the last and only tab, you trigger the exit function
		 *
		 * @param index tab position.
		 */
		public function removeElement(index:int):void
		{			
			if(tabBar.dataProvider.length > 1)
			{
				var tempIndexID:String; 
				if(this.selectedIndex != index) 
				{
					tempIndexID = tabBar.selectedItem.vnID;
				}
				else if(index == tabBar.dataProvider.length-1)
				{
					tempIndexID = tabBar.dataProvider.getItemAt(index-1).vnID;
				}
				else
				{
					tempIndexID = tabBar.dataProvider.getItemAt(index+1).vnID;
				}
				screenNavigator.removeScreen(tabBar.dataProvider.getItemAt(index).vnID);
				tabBar.dataProvider.removeItemAt(index);
				isScrollToIndex = false;
				this.selectedIndex = dpIndexOf(tabBar.dataProvider, tempIndexID);
				isScrollToIndex = true;
				_validate();
				if(tabBar.dataProvider.length == 1) hideTabBar();
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
		public function renameElement(index:int, label:String):void
		{			
			tabBar.dataProvider.setItemAt( { label: label, vnID: tabBar.dataProvider.getItemAt(index).vnID }, index);
			_validate();
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
				var tempIndexID:String = tabBar.selectedItem.vnID;
				var tempItem:Object = tabBar.dataProvider.getItemAt(indexToMove);
				tabBar.dataProvider.removeItemAt(indexToMove);
				tabBar.dataProvider.addItemAt(tempItem, newIndex);
				isScrollToIndex = false;
				this.selectedIndex = dpIndexOf(tabBar.dataProvider, tempIndexID);
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
		public function replaceElement(index:int, label:String, screen:Object, data:Object = null, transition:Function = null):void
		{			
			renameElement(index, label);
			if(index == this.selectedIndex) screenNavigator.clearScreen();
			screenNavigator.removeScreen(tabBar.dataProvider.getItemAt(index).vnID);
			clear();
			var navigator:ViewNavigator = new ViewNavigator(screen, data, transition, this, tabBar.dataProvider.getItemAt(index).vnID);
			screenNavigator.addScreen(tabBar.dataProvider.getItemAt(index).vnID, new ScreenNavigatorItem(navigator));
			if(index == this.selectedIndex) screenNavigator.showScreen(tabBar.dataProvider.getItemAt(index).vnID);
			_validate();
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
			return scroller.height;
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
		}
		
		private function resizeHandler(event:starling.events.Event = null):void
		{
			var scrollerWidth:Number = Math.min(scroller.viewPort.width, stage.stageWidth - left - right);
			if(scroller.width != scrollerWidth) scroller.width = scrollerWidth;
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
				scrollToIndex();
			}
		}
		
		/**
		 * Scroll to the index currently selected in the tabBar.
		 */
		private function scrollToIndex():void
		{
			if(!isScrollToIndex) return;
			if(scroller.viewPort.width > scroller.width)
			{
				var tabs:Array = [];
				for(var i:uint; i<tabBar.numChildren; i++) tabs.push(tabBar.getChildAt(i));
				tabs.sortOn("x", Array.NUMERIC);
				var pos:Number = tabs[this.selectedIndex].x + tabs[this.selectedIndex].width;
				if(pos > scroller.width)
				{
					scroller.horizontalScrollPosition = pos - scroller.width;
				}
				else
				{
					scroller.horizontalScrollPosition = 0;
				}
			}
		}
		
		private function _validate():void
		{
			tabBar.validate();
			scroller.validate();
		}
	}
}