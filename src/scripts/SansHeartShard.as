package scripts
{
    import flash.display.Sprite;
    import ext.scripts.SansHeartShardMC;

    public class SansHeartShard extends Sprite implements ISansTickable
    {
        private var gfx:SansHeartShardMC;
        public var CustomMovement:SansCustomMovement = new SansCustomMovement();

        public function SansHeartShard(container:SansAttackContainer, source:Sprite):void
        {
            container.layer_overlay.addChild(this);

            gfx = new SansHeartShardMC();
            addChild(gfx);

            this.x = source.x;
            this.y = source.y;

            CustomMovement.speed = 180;
            CustomMovement.angle = Math.random() * 360;
        }

        public function update(delta:Number, eclipsed:Number, script:SansBattleScript):void
        {
        	CustomMovement.dy += 300 * eclipsed;

            this.x += CustomMovement.dx * eclipsed;
            this.y += CustomMovement.dy * eclipsed;
        }

        public function destroy():void
        {
        	if(this.parent)
                this.parent.removeChild(this);
        }
    }
}