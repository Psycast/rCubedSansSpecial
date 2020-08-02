package scripts 
{
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import ext.scripts.SansBattleBoneStabMC;
	import flash.display.BitmapData;
	
	public class SansBoneStabBase extends Sprite implements ISansDamageable
	{
		private static var BITMAP_DATA:BitmapData;

		public var Direction:int;
		public var gfx:Sprite;

		public var DestX:Number = 0;
		public var DestY:Number = 0;
		public var Damage:Number = 1;
		public var Karma:Number = 6;
		
		public var container:SansAttackContainer;
		
		public function SansBoneStabBase(container:SansAttackContainer, Direction:int) 
		{
			this.container = container;
			this.Direction = Direction;

			if(!BITMAP_DATA) BITMAP_DATA = new SansBattleBoneStabMC() as BitmapData;

			container.layer_combat_zone_clipped.addChild(this);

			var gfx:Bitmap = new Bitmap(BITMAP_DATA);
			gfx.rotation = Direction * 90;
			this.addChild(gfx);

			if(Direction == 1)
				gfx.x += gfx.width;
			if(Direction == 2)
				gfx.y += gfx.height;
		}
		
		public function setSize(nw:Number, nh:Number):void
		{
			// Unused, SansBattleBoneStabMC already contains the max size used and is clipped anyway.
		}

		/* INTERFACE scripts.ISansDamageable */
		
        public function getHitbox():Sprite
        {
        	return this;
        }

		public function getColor():int
		{
			return 0;
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