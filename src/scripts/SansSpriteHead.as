package scripts
{
    import flash.geom.Point;
    import ext.scripts.SansSpriteHeadMC;

    public class SansSpriteHead extends SansSpriteBase
    {
        public function SansSpriteHead():void
        {
            gfx = new SansSpriteHeadMC();
            super();

            ImagePoints = {"Sweat": new Point(0, -30)};
        }
    }
}