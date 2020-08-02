package scripts
{
    import flash.display.Sprite;
    import ext.scripts.SansTargetChoiceMC;

    public class SansMenuTargetChoice extends Sprite {
        private var gfx:SansTargetChoiceMC;
        public var Direction:int = 0;

        public function SansMenuTargetChoice():void
        {
           gfx = new SansTargetChoiceMC();
           addChild(gfx);
        }

        public function Animation(animation:String):void {
            gfx.gotoAndPlay(animation);
        }

        public function destroy():void
        {
            if(this.parent && this.parent.contains(this))
                this.parent.removeChild(this);
        }
    }
}