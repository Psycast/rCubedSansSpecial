package scripts 
{
	public class SansCustomMovement 
	{
		private var _dx:Number = 0;
		private var _dy:Number = 0;
		
		public var last_x:Number = 0;
		public var last_y:Number = 0;

		private var _speed:Number = 0;
		private var _angle:Number = 0;

		public var Disabled:Boolean = false;

		public function set angle(val:Number):void
		{
			_angle = deg2rad(val);
			speed = _speed;
		}
		
		public function set speed(val:Number):void
		{
			_speed = val;
			dx = Math.cos(_angle) * val;
			dy = Math.sin(_angle) * val;

			if(Math.abs(dx) < 0.01) dx = 0;
			if(Math.abs(dy) < 0.01) dy = 0;
		}
		
		public function get dx():Number 
		{
			return Disabled ? 0 : _dx;
		}
		
		public function set dx(value:Number):void 
		{
			_dx = value;
		}
		
		public function get dy():Number 
		{
			return Disabled ? 0 : _dy;
		}
		
		public function set dy(value:Number):void 
		{
			_dy = value;
		}
		
		public function toString():String 
		{
			return "[dx=" + dx + " dy=" + dy + " last_x=" + last_x + " last_y=" + last_y + "]";
		}
	}

}