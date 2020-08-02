package scripts
{
    import flash.geom.Point;
    import ext.scripts.SansSpriteSweatMC;

    public class SansSpriteSweat extends SansSpriteBase
    {
        public function SansSpriteSweat():void
        {
            gfx = new SansSpriteSweatMC();

            super();
        }
    }
}