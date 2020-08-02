package scripts
{
    import flash.geom.Point;
    import ext.scripts.SansSpriteLegsMC;

    public class SansSpriteLegs extends SansSpriteBase
    {
        public function SansSpriteLegs():void
        {
            gfx = new SansSpriteLegsMC();
            super();

            ImagePoints = {"Torso": new Point(0, -23)};
            ImageAnimationPoints = {"Sitting": {"Torso": new Point(0, -14)}};
        }
    }
}