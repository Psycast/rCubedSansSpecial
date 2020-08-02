package scripts 
{
	import flash.display.Sprite;
	import flash.display.MovieClip;
	
	public class SansSpriteBase extends Sprite
	{
		public var gfx:MovieClip;
		public var CurrentAnimation:String = "";

		public var ImagePoints:Object = {};
		public var ImageAnimationPoints:Object = {};
        public var XSpeed:Number = 0;
        public var YSpeed:Number = 0;

		public var T:Number = 0;
		public var OffsetX:Number = 0;
		public var OffsetY:Number = 0;

		public function SansSpriteBase() 
		{
			gfx.scaleX = gfx.scaleY = 2;
			addChild(gfx);
		}
		
        public function Animation(animation:String):void
        {
			CurrentAnimation = animation;
			gfx.gotoAndPlay(animation);
        }

		public function ImagePointX(point:String):Number
		{
			if(ImageAnimationPoints[CurrentAnimation] != null)
				return this.x + (ImageAnimationPoints[CurrentAnimation][point].x * 2);
			return this.x + (ImagePoints[point].x * 2);
		}

		public function ImagePointY(point:String):Number
		{
			if(ImageAnimationPoints[CurrentAnimation] != null)
				return this.x + (ImageAnimationPoints[CurrentAnimation][point].y * 2);
			return this.y + (ImagePoints[point].y * 2);
		}
	}

}