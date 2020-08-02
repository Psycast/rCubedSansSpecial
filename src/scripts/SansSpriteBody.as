package scripts
{
    import flash.geom.Point;
    import ext.scripts.SansSpriteBodyMC;

    public class SansSpriteBody extends SansSpriteBase
    {
        public function SansSpriteBody():void
        {
            gfx = new SansSpriteBodyMC();
            super();

            ImagePoints = {"Head": new Point(1, -42)};

        }
    }
}