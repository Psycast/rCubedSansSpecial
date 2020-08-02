package scripts
{
    import flash.display.MovieClip;
    import ext.scripts.SansMenuBoneMC;
    import flash.display.Sprite;

    public class SansMenuBoneBottom extends Sprite implements ISansDamageable
    {
        private var gfx:MovieClip;

        public var Damage:int = 1;
        public var Button:int = 0;
        public var State:int = 0;

        public function SansMenuBoneBottom():void
        {
            gfx = new SansMenuBoneMC();
            addChild(gfx);
        }

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