package scripts
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	public class SansBoneStabWarn extends Sprite implements ISansTickable, ISansDamageable
	{
		public var container:SansAttackContainer;
		
		public var Border:SansBoneStabWarnBorder;
		public var Bones:SansBoneStabBase;
		
		public var Direction:Number;
		public var Distance:int;
		public var WarnTime:Number;
		public var StayTime:Number;
		
		public var Reverse:Boolean = false;
		
		public function SansBoneStabWarn(container:SansAttackContainer, Direction:Number, Distance:int, WarnTime:Number, StayTime:Number)
		{
			this.container = container;
			
			this.Direction = Direction;
			this.Distance = Distance;
			this.WarnTime = WarnTime;
			this.StayTime = StayTime;
			
			container.PlaySound("Warning");
			
			var BBox:Rectangle = container.combat_zone.getBoundsBox();
			
			Border = new SansBoneStabWarnBorder(this);
			
			if (Direction == 0)
			{
				Border.setSize(Distance - 3, BBox.height - 16);
				Border.setPos(BBox.right - Border.width - 8, BBox.top + 8);
			}
			if (Direction == 1)
			{
				Border.setSize(BBox.width - 16, Distance - 3);
				Border.setPos(BBox.left + 8, BBox.bottom - Border.height - 8);
			}
			if (Direction == 2)
			{
				Border.setSize(Distance - 3, BBox.height - 16)
				Border.setPos(BBox.left + 8, BBox.top + 8);
			}
			if (Direction == 3)
			{
				Border.setSize(BBox.width - 16, Distance - 3);
				Border.setPos(BBox.left + 8, BBox.top + 8);
			}
		}
		
		/* INTERFACE scripts.ISansTickable */
		
		public function update(delta:Number, eclipsed:Number, script:SansBattleScript):void
		{
			if (WarnTime > 0)
				WarnTime -= Math.min(eclipsed, WarnTime);
			
			else if (WarnTime <= 0 && Border.isValid)
			{
				Border.destroy();
				container.PlaySound("BoneStab");
				
				var BBox:Rectangle = container.combat_zone.getBoundsBox();
				
				if (Direction == 1 || Direction == 3)
				{
					Bones = new SansBoneStabBase(container, Direction);
					Bones.x = Bones.DestX = BBox.left;
					Bones.setSize(BBox.width, Distance + 8);
					
					if (Direction == 1)
					{
						Bones.y = BBox.bottom - 5;
						Bones.DestY = BBox.bottom - 5 - Distance;
					}
					else
					{
						Bones.y = BBox.top + 5;
						Bones.DestY = BBox.top + 5 + Distance;
					}
				}
				if (Direction == 0 || Direction == 2)
				{
					Bones = new SansBoneStabBase(container, Direction);
					Bones.y = Bones.DestY = BBox.top;
					Bones.setSize(Distance + 8, BBox.height);
					
					if (Direction == 0)
					{
						Bones.x = BBox.right - 5;
						Bones.DestX = BBox.right - 5 - Distance;
					}
					else
					{
						Bones.x = BBox.left + 5;
						Bones.DestX = BBox.left + 5 + Distance;
					}
				}
			}
			else if (WarnTime <= 0 && Bones)
			{
				var Speed:Number = Distance * 10;
				var _rad:Number = deg2rad(Direction * 90);
				
				if (Reverse)
				{
					Bones.x += Math.cos(_rad) * eclipsed * Speed;
					Bones.y += Math.sin(_rad) * eclipsed * Speed;
				}
				else
				{
					Bones.x -= Math.cos(_rad) * eclipsed * Speed;
					Bones.y -= Math.sin(_rad) * eclipsed * Speed;
					
					if (Direction == 0 && Bones.x < Bones.DestX) Bones.x = Bones.DestX;
					if (Direction == 1 && Bones.y < Bones.DestY) Bones.y = Bones.DestY;
					if (Direction == 2 && Bones.x > Bones.DestX) Bones.x = Bones.DestX;
					if (Direction == 3 && Bones.y > Bones.DestY) Bones.y = Bones.DestY;
					
					if (Bones.x == Bones.DestX && Bones.y == Bones.DestY)
					{
						StayTime -= Math.min(eclipsed, StayTime);
						
						if (StayTime <= 0) {
							Reverse = true;
						}
					}
				}
			}
			if (Bones) {
				var isRemoved:Boolean = false;
				if (Bones.x > SansAttackContainer.CONTAINER_WIDTH) isRemoved = true;
				if (Bones.y > SansAttackContainer.CONTAINER_HEIGHT) isRemoved = true;
				if (Bones.x < -Bones.width) isRemoved = true;
				if (Bones.y < -Bones.height) isRemoved = true;
				
				if (isRemoved)
				{
					script.RemoveTickable(this);
				}
			}
		}
		
		public function destroy():void {
			if(Border.isValid)
				Border.destroy();
			if(Bones && Bones.parent && Bones.parent.contains(Bones))
				Bones.parent.removeChild(Bones);
		}
		
		/* INTERFACE scripts.ISansDamageable */
		
        public function getHitbox():Sprite
        {
        	return Bones ? Bones.getHitbox() : this;
        }

		public function getColor():int
		{
			return Bones ? Bones.getColor() : 0;
		}

        public function getDamage():int
        {
        	return Bones ? Bones.getDamage() : 0;
        }

        public function getKarma():int
        {
        	return Bones ? Bones.getKarma() : 0;
        }

		public function setKarma(val:int):void
		{
			if(Bones)
				Bones.Karma = val;
		}
	}
}