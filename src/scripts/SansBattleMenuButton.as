package scripts 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	public class SansBattleMenuButton extends Sprite
	{
		public var gfx:MovieClip;

		public var ID:int;
		public var Action:String;
		
		public function SansBattleMenuButton(par:DisplayObjectContainer, gfx:MovieClip) 
		{
			this.gfx = gfx;
			addChild(gfx);
			par.addChild(this);
			gfx.stop();
		}
		
		public function setActive():void
		{
			gfx.gotoAndStop(2);
		}
		
		public function clear():void
		{
			gfx.gotoAndStop(1);
		}
		
		public function HeartPointX():Number
		{
			return this.x + 15;
		}

		public function HeartPointY():Number
		{
			return this.y + 21;
		}
	}

}