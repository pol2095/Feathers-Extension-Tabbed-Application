/*
Copyright 2016 pol2095

See the NOTICE file distributed with this work for additional information
regarding copyright ownership. The author licenses this file to You under the
Apache License, Version 2.0 (the "License"); you may not use this file except in
compliance with the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.
*/
package feathers.extensions.tabbedApplication
{
	import feathers.controls.StackScreenNavigator;
	import feathers.utils.display.stageToStarling;

	import flash.display.Stage;

	import flash.errors.IllegalOperationError;

	import starling.core.Starling;
	import starling.events.Event;

	[Frame(factoryClass="feathers.core.StarlingBootstrap")]

	/**
	 * Base class for a Feathers application with a
	 * <code>ViewNavigator</code> as the root display object.
	 *
	 * @see http://pol2095.free.fr/Feathers-Extension-Tabbed-Application/ViewNavigatorApplication.php How to use ViewNavigatorApplication with mxml
	 * @see feathers.extensions.tabbedApplication.ViewNavigator
	 * @see feathers.extensions.tabbedApplication.View
	 * @see feathers.extensions.tabbedApplication.PanelView
	 */
	public class ViewNavigatorApplication extends ViewNavigator
	{
		/**
		 * Constructor.
		 */
		public function ViewNavigatorApplication()
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, application_addedToStageHandler);
		}

		/**
		 * @private
		 */
		protected var _theme:Class;

		/**
		 * @copy feathers.core.IApplication#theme
		 */
		public function get theme():Class
		{
			return this._theme;
		}

		/**
		 * @private
		 */
		public function set theme(value:Class):void
		{
			if(this._isInitialized)
			{
				throw new IllegalOperationError("theme can only be set in MXML before an application has initialized.");
			}
			this._theme = value;
		}

		/**
		 * @private
		 */
		protected var _context3DProfile:String;

		[Inspectable(type="String",enumeration="baselineConstrained,baseline,baselineExtended,standardConstrained,standard,standardExtended")]
		/**
		 * @copy feathers.core.IApplication#context3DProfile
		 */
		public function get context3DProfile():String
		{
			if(this._context3DProfile !== null)
			{
				return this._context3DProfile;
			}
			return Starling.current.profile;
		}

		/**
		 * @private
		 */
		public function set context3DProfile(value:String):void
		{
			if(this._isInitialized)
			{
				throw new IllegalOperationError("context3DProfile can only be set before an application has initialized.");
			}
			this._context3DProfile = value;
		}

		/**
		 * @private
		 */
		protected function application_addedToStageHandler(event:Event):void
		{
			//Flash Builder sets the visible element in the AIR application
			//descriptor to false for Flex projects. Flex dynamically sets it to
			//true, so we need to do the same.
			var starling:Starling = stageToStarling(this.stage);
			var nativeStage:Stage = starling.nativeStage;
			if("nativeWindow" in nativeStage)
			{
				var nativeWindow:Object = nativeStage["nativeWindow"];
				if(nativeWindow)
				{
					nativeWindow.visible = true;
				}
			}
		}
	}
}