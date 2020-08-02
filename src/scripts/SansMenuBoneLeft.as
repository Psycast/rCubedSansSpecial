package scripts
{
    import flash.display.MovieClip;
    import ext.scripts.SansMenuBoneMC;
    import flash.display.Sprite;

    public class SansMenuBoneLeft extends Sprite implements ISansDamageable
    {
        private var gfx:MovieClip;

        public var Damage:int = 1;
        public var Timer:Number = 0;
        public var DoDestroy:Boolean = false;

        public function SansMenuBoneLeft():void
        {
            gfx = new SansMenuBoneMC();
            addChild(gfx);
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
        	return 0;
        }

		public function setKarma(val:int):void { }
    }
}