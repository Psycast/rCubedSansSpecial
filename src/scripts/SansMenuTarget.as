package scripts
{
    import flash.display.Sprite;
    import ext.scripts.SansTargetMC;

    public class SansMenuTarget extends Sprite {
        private var gfx:SansTargetMC;
        public var State:int = 0;

        public function SansMenuTarget():void
        {
            gfx = new SansTargetMC();
            addChild(gfx);
        }

        public function destroy():void
        {
            if(this.parent && this.parent.contains(this))
                this.parent.removeChild(this);
        }
    }
}