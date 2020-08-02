package scripts
{
    import flash.geom.Point;
    import ext.scripts.SansSpriteTorsoMC;

    public class SansSpriteTorso extends SansSpriteBase
    {
        public function SansSpriteTorso():void
        {
            gfx = new SansSpriteTorsoMC();
            super();

            ImagePoints = {"Head": new Point(0, -19)};
        }
    }
}