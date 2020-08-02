package scripts 
{
	import flash.display.Sprite;
	import com.greensock.motionPaths.Direction;
	import flash.geom.Rectangle;
	
	public class SansPlatform extends Sprite implements ISansTickable
	{
		public static var ALIVE_PLATFORMS:Array = [];

		private var container:SansAttackContainer;

		public var Reverse:Boolean = false;
		public var Direction:int = 0;

		public var CustomMovement:SansCustomMovement = new SansCustomMovement();

		public var Platform1:Sprite = new Sprite();
		public var Platform2:Sprite = new Sprite();
		
		public function SansPlatform(container:SansAttackContainer, X:Number, Y:Number, Width:Number, Direction:int, Speed:int, Reverse:Boolean = false) 
		{
			this.container = container;

			this.x = X;
			this.y = Y;

			addChild(Platform1);
			addChild(Platform2);

			Platform2.y = -4;

			drawBox(Platform1, Width, 0xFFFFFF);
			drawBox(Platform2, Width, 0x2e5f2e);

			CustomMovement.speed = Speed;
			CustomMovement.angle = Direction * 90;

			this.Reverse = Reverse;
			this.Direction = Direction;

			this.container.layer_combat_zone.addChild(this);

			ALIVE_PLATFORMS[ALIVE_PLATFORMS.length] = this;
		}

		public function drawBox(target:Sprite, width:int, color:uint):void
		{
			target.graphics.clear();
			target.graphics.lineStyle(1, color, 1, false);
			target.graphics.beginFill(0, 0);
			target.graphics.drawRect(0, 0, width - 1, 6);
			target.graphics.endFill();
		}
		

		public function update(delta:Number, eclipsed:Number, script:SansBattleScript):void
		{
			this.x += CustomMovement.dx * eclipsed;
			this.y += CustomMovement.dy * eclipsed;

			if(Reverse) {
				var BBPadding:int = container.combat_zone.Border_Stroke;
				var BBox:Rectangle = container.combat_zone.getBoundsBox();

				if(Direction == 0 && (this.x + this.width > BBox.x + (BBox.width - BBPadding))) {
					Direction = 2;
					CustomMovement.angle = Direction * 90;
				} else if(Direction == 1 && (this.y + this.height > SansAttackContainer.CONTAINER_HEIGHT)) {
					Direction = 3;
					CustomMovement.angle = Direction * 90;
				} else if(Direction == 2 && this.x < BBox.x + BBPadding) {
					Direction = 0;
					CustomMovement.angle = Direction * 90;
				} else if(Direction == 3 && this.y < 0) {
					Direction = 1;
					CustomMovement.angle = Direction * 90;
				}
			}
		}

		public function destroy():void
		{
			var i:int = ALIVE_PLATFORMS.indexOf(this);
			ALIVE_PLATFORMS.splice(i, 1);
		}
	}

}