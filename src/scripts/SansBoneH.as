package scripts 
{
	import ext.scripts.SansBattleBoneH;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.display.BitmapData;
	
	public class SansBoneH extends Sprite implements ISansTickable, ISansDamageable
	{
		private static const SCALE_9_GRID:Rectangle = new Rectangle(6, 4, 12, 2);
		private static var BITMAP_DATA:BitmapData;
		
		public var Direction:int;
		public var Speed:Number;
		public var Color:int;
		
		public var Karma:Number = 6;
		public var Damage:Number = 1;
		
		public var gfx:Sprite = new Sprite();
		
		public function SansBoneH(container:SansAttackContainer, X:Number, Y:Number, Width:Number, Direction:int, Speed:Number, Color:int = 0) 
		{
			container.layer_combat_zone.addChild(this);
			
			if(!BITMAP_DATA) BITMAP_DATA = new SansBattleBoneH() as BitmapData;

			this.x = X;
			this.y = Y;
			
			drawIntoSprite(gfx, BITMAP_DATA, SCALE_9_GRID);

			gfx.scaleX = Width / 24;

			this.addChild(gfx);
			
			this.Direction = Direction;
			this.Speed = Speed;
			this.Color = Color;
			
			if (Color == 1)
				this.transform.colorTransform = new ColorTransform(0, 0.65, 1);
		}
		
		
		/* INTERFACE scripts.ISansTickable */
		
		public function update(delta:Number, eclipsed:Number, script:SansBattleScript):void 
		{
			this.x += Math.cos(deg2rad(Direction * 90)) * eclipsed * Speed;
			this.y += Math.sin(deg2rad(Direction * 90)) * eclipsed * Speed;
			
			if (Direction == 0 && this.x > SansAttackContainer.CONTAINER_WIDTH) script.RemoveTickable(this);
			if (Direction == 1 && this.y > SansAttackContainer.CONTAINER_HEIGHT) script.RemoveTickable(this);
			if (Direction == 2 && this.x < -gfx.width) script.RemoveTickable(this);
			if (Direction == 3 && this.y < -gfx.height) script.RemoveTickable(this);
		}
		
		public function destroy():void { }
		
		/* INTERFACE scripts.ISansDamageable */
		
        public function getHitbox():Sprite
        {
        	return this;
        }

		public function getColor():int
		{
			return Color;
		}

        public function getDamage():int
        {
        	return Damage;
        }

        public function getKarma():int
        {
        	return Karma;
        }

		public function setKarma(val:int):void
		{
			Karma = val;
		}
	}

}