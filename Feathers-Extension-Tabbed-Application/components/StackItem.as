/*
Copyright 2016 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package components
{
	public class StackItem
	{
		public function StackItem(id:String, properties:Object)
		{
			this.id = id;
			this.properties = properties;
		}

		public var id:String;
		public var properties:Object;
	}
}