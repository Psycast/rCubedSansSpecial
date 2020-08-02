package scripts 
{
	import flash.display.JointStyle;
	import flash.display.Sprite;
	public class SansBoneStabWarnBorder extends Sprite
	{
		public var isValid:Boolean = true;
		private var _width:Number;
		private var _height:Number;
		
		public function SansBoneStabWarnBorder(par:SansBoneStabWarn) 
		{
			par.container.layer_combat_zone.addChild(this);
		}
		
		public function setSize(nw:Number, nh:Number):void
		{
			this.graphics.clear();
			this.graphics.lineStyle(0, 0x8f2f2f, 1, false, "none", "none", JointStyle.MITER);
			this.graphics.beginFill(0, 0);
			this.graphics.drawRect(0, 0, nw, nh);
			this.graphics.endFill();
		}
		
		public function setPos(mx:Number, my:Number):void
		{
			this.x = mx;
			this.y = my;
		}
		
		public function destroy():void 
		{
			this.parent.removeChild(this);
			isValid = false;
		}
	}

}