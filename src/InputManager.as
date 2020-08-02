package
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.GameInputEvent;
	import flash.events.IEventDispatcher;
	import flash.ui.GameInput;
	import flash.ui.GameInputControl;
	import flash.ui.GameInputDevice;
	
	public class InputManager extends EventDispatcher
	{
		
		private var gameInput:GameInput;
		private var device:GameInputDevice;
		private var control:GameInputControl;
		
		public function InputManager(stage:Stage)
		{
			// Setup GameInputs from Controller
			gameInput = new GameInput();
			gameInput.addEventListener(GameInputEvent.DEVICE_ADDED, GIE_added);
			gameInput.addEventListener(GameInputEvent.DEVICE_REMOVED, GIE_onRemoved);
			gameInput.addEventListener(GameInputEvent.DEVICE_UNUSABLE, GIE_unusable);
		}
		
		private function GIE_added(gameInputEvent:GameInputEvent)
		{
			//
			trace("Controller Added! GameInput.numDevices is " + GameInput.numDevices);
			//
			trace("GameInput.getDeviceAt(0): " + GameInput.getDeviceAt(0));
			//Controller #1 - lazy test
			device = GameInput.getDeviceAt(0);
			//get all the buttons (loop through number of controls) and add the on change listener
			//this indicates if a button pressed, and gets the value...
			for (var i:Number = 0; i < device.numControls; ++i)
			{
				control = device.getControlAt(i);
				control.addEventListener(Event.CHANGE, GIE_onChange);//capture change
				//what buttons does it have (names)
				trace("CONTROLS: " + control.id);
			}
			//set to enabled
			device.enabled = true;
			//return info
			trace("device.enabled - " + device.enabled);
			trace("device.id - " + device.id);
			trace("device.name - " + device.name);
			trace("device.numControls - " + device.numControls);
			trace("device.sampleInterval - " + device.sampleInterval);
			trace("device.MAX_BUFFER - " + GameInputDevice.MAX_BUFFER_SIZE);
			trace("device.numControls - " + device.numControls);
		}
		
		private function GIE_onChange(event:Event)
		{
			var control:GameInputControl = event.target as GameInputControl;
			//To get the value of the press you can use .value, or minValue and maxValue for on/off
			//var num_val:Number = control.value;
			//
			//constant stream (Axis is very sensitive)
			if (control.id.indexOf("AXIS_1") != -1)
			{
				//trace("control.id=" + control.id);
				trace("control.value=" + control.value + " (" + control.minValue + " .. " + control.maxValue + ")");
				if (control.value <= control.minValue || control.value >= control.maxValue)
				{
					trace("control.id=" + control.id + " has been pressed [" + control.value + "]");
				}
			}
			//trace just on/off to see each button
			else if (control.value >= control.maxValue)
			{
				trace("control.id=" + control.id + " has been pressed [" + control.value + "]");
			}
		}
		
		private function GIE_onRemoved(gameInputEvent:GameInputEvent)
		{
			//detects if you unplugged it
			trace("Controller Removed.");
			trace("GameInput.numDevices: " + GameInput.numDevices);
		}
		
		private function GIE_unusable(gameInputEvent:GameInputEvent)
		{
			//throw error now...
			trace("Controller Unusable.");
			trace("GameInput.numDevices: " + GameInput.numDevices);
		}
	
	}

}