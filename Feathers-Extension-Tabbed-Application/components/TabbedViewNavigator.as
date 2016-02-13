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
		private var layoutDataTB:AnchorLayoutData;
		/**
		 * The navigators that showing the views
		 */
		private var screenNavigator:ScreenNavigator;
		private var layoutDataVN:AnchorLayoutData;
		
		/**
		 * Constructor. 
		 */
		public function TabbedViewNavigator()
		{
			super();
			
			var container:LayoutGroup = new LayoutGroup();
			container.layout = new AnchorLayout();
			
			tabBar = new TabBar();
			layoutDataTB = new AnchorLayoutData();
			layoutDataTB.right = layoutDataTB.top = layoutDataTB.left = 0;
			tabBar.layoutData = layoutDataTB;
			container.addChild( tabBar );
			
			screenNavigator = new ScreenNavigator();
			layoutDataVN = new AnchorLayoutData();
			screenNavigator.layoutData = layoutDataVN;
			container.addChild( screenNavigator );
			layoutDataVN.bottom = layoutDataVN.right = layoutDataVN.top = layoutDataVN.left = 0;
			layoutDataVN.topAnchorDisplayObject = this.tabBar;
			
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
		
		private var _bottom:Number;
		/**
		 * Distance from the bottom of the application.
		 *
		 * @default NaN.
		 *
		 * <p><b>Note:</b> If you use "bottom" property, don't use "top" property in the same time.</p>
		 */
		public function get bottom():Number
		{
			return _bottom;
		}
		public function set bottom(value:Number):void
		{
			_bottom = value;
			if(!isNaN(value))
			{
				layoutDataTB.top = NaN;
				layoutDataTB.bottom = value;
				layoutDataVN.bottom = NaN;
				layoutDataVN.topAnchorDisplayObject = null;
				layoutDataVN.bottomAnchorDisplayObject = this.tabBar;
			}
			else 
			{
				layoutDataTB.top = 0;
				layoutDataTB.bottom = NaN;
				layoutDataVN.bottom = 0;
				layoutDataVN.topAnchorDisplayObject = this.tabBar;
				layoutDataVN.bottomAnchorDisplayObject = null;
			}
		}
		
		private var _top:Number;
		/**
		 * Distance from the top of the application.
		 *
		 * @default 0.
		 *
		 * <p><b>Note:</b> If you use "top" property, don't use "bottom" property in the same time.</p>
		 */
		public function get top():Number
		{
			return _top;
		}
		public function set top(value:Number):void
		{
			_top = value;
			if(!isNaN(value)) layoutDataTB.top = top;
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
					tabBar.selectedIndex = 0;
					screenNavigator.showScreen(vnID);
				}
				else
				{
					var tabBarHistory:Vector.<Object> = Vector.<Object>(my_so.data.tabBarHistory);
					var navigatorsHistory:Vector.<Object> = Vector.<Object>(my_so.data.viewsHistory);
					for(var i:uint = 0; i < tabBarHistory.length; i++)
					{
						createElement(tabBarHistory[i].label, tabBarHistory[i].vnID, screen, data, transition, Vector.<String>(navigatorsHistory[i]._history), Vector.<Object>(navigatorsHistory[i]._historyData));
					}
					tabBar.selectedIndex = my_so.data.tabBarSelected;
					screenNavigator.showScreen(tabBar.selectedItem.vnID);
				}
			}
			else if(!init)
			{
				createElement(label, newID(), screen, data, transition);
			}
		}
		
		private function createElement(label:String, vnID:String, screen:Object, data:Object, transition:Function = null, _history:Vector.<String> = null, _historyData:Vector.<Object> = null):void
		{
			tabBar.dataProvider.addItem( { label: label, vnID: vnID } );
			var navigator:ViewNavigator = new ViewNavigator(screen, data, transition, this, vnID, _history, _historyData);
			screenNavigator.addScreen(vnID, new ScreenNavigatorItem(navigator));
			(tabBar.dataProvider.length == 1) ? hideTabBar() : showTabBar();
			tabBar.validate();
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
				my_so.data.tabBarSelected = tabBar.selectedIndex;
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
			if(!tabBar.visible || !tabBarAutoHide) return;
			tabBar.visible = false;
			!bottom ? layoutDataVN.topAnchorDisplayObject = null : layoutDataVN.bottomAnchorDisplayObject = null;
		}
		
		/**
		 * Show the tab bar.
		 */
		public function showTabBar():void
		{			
			if(tabBar.visible || !tabBarAutoHide) return;
			tabBar.visible = true;
			!bottom ? layoutDataVN.topAnchorDisplayObject = this.tabBar : layoutDataVN.bottomAnchorDisplayObject = this.tabBar;
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
				if(tabBar.selectedIndex != index) 
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
				tabBar.selectedIndex = dpIndexOf(tabBar.dataProvider, tempIndexID);
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
		 * @param index new tab name.
		 *
		 * @param index tab position.
		 */
		public function renameElement(value:String, index:int):void
		{			
			tabBar.dataProvider.setItemAt( { label: value, vnID: tabBar.dataProvider.getItemAt(index).vnID }, index);
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
				tabBar.selectedIndex = dpIndexOf(tabBar.dataProvider, tempIndexID);
			}
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
			return screenNavigator.getScreen(tabBar.dataProvider.getItemAt(tabBar.selectedIndex).vnID).getScreen() as ViewNavigator;
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
			return tabBar.visible ? tabBar.height : 0;
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
			if(keyCode && !hasEventListener_keyCode)
			{
				hasEventListener_keyCode = true;
				stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			}
		}
	}
}