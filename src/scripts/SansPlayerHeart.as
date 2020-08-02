package scripts
{
	import ext.scripts.SansPlayerHeartGraphic;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import com.greensock.core.Animation;
	
	public class SansPlayerHeart extends Sprite implements ISansTickable
	{
		private var gfx:SansPlayerHeartGraphic;
		public var hitbox:Sprite;
		
		private var container:SansAttackContainer;
		
		public static const HEARTMODE_RED:int = 0;
		public static const HEARTMODE_BLUE:int = 1;
		
		public static const HEART_JUMP_STRENGTH:int = 180;
		public static const HEART_JUMPHOLD_CUTOFF:int = 30;
		
		public var HeartSpeed:int = 150;
		public static var MaxFallSpeed:int = 750;
		
		public var Slammed:Boolean = false;
		public var SlamDamage:Boolean = false;
		
		public var HP:int = 92;
		public var MaxHP:int = 92;
		public var KR:int = 0;
		public var KR_T:Number = 0;
		
		public var Angle:Number = 90;
		
		public var Mode:int = HEARTMODE_RED;
		
		public var CustomMovement:SansCustomMovement = new SansCustomMovement();
		
		public function SansPlayerHeart(container:SansAttackContainer)
		{
			this.container = container;
			this.container.layer_combat_zone.addChild(this);
			
			this.gfx = new SansPlayerHeartGraphic();
			this.gfx.gotoAndStop(1);
			this.gfx.rotation = this.Angle;
			addChild(gfx);

			this.hitbox = new Sprite();
			this.hitbox.graphics.lineStyle(0, 0, 0);
			this.hitbox.graphics.beginFill(0xffff00, 1);
			this.hitbox.graphics.drawRect(-2, -2, 4, 4);
			this.graphics.endFill();
			this.hitbox.alpha = 0;
			addChild(this.hitbox);
		}

		public function Animation(label:String):void
		{
			this.gfx.gotoAndPlay(label);
		}
		
		public function HeartMode(mode:int):void
		{
			this.Mode = mode;
			this.Angle = 90;
			this.gfx.gotoAndStop(mode + 1);
			gfx.rotation = this.Angle;
		}
		
		public function HeartTeleport(x:Number, y:Number):void
		{
			this.x = x;
			this.y = y;
			
			this.alpha = 1;
			this.visible = true;
		}
		
		public function HeartMaxFallSpeed(speed:int):void
		{
			MaxFallSpeed = speed;
		}
		
		public function SansSlam(dir:int):void
		{
			HeartMode(HEARTMODE_BLUE);
			this.Slammed = true;
			this.Angle = Math.floor(dir * 90);
			CustomMovement.dx = Math.cos(deg2rad(this.Angle)) * MaxFallSpeed;
			CustomMovement.dy = Math.sin(deg2rad(this.Angle)) * MaxFallSpeed;
			
			gfx.rotation = this.Angle;
		}
		
		public function SansSlamDamage(val:int):void
		{
			this.SlamDamage = val != 0;
		}
		
		public function HeartCheckSolid(tx:Number, ty:Number):Boolean
		{
			return HeartCheckWall(tx, ty);
		}
		
		public function HeartCheckWall(tx:Number, ty:Number):Boolean // TODO Finish
		{
			var out:Boolean = false;
			
			var ox:Number = this.x;
			var oy:Number = this.y;
			
			// Move Offset
			this.x += tx;
			this.y += ty;
			
			// Combat Zone
			if (container.combat_zone.hitTest(this))
				out = true;
			
			// Platforms
			var platforms:Array = SansPlatform.ALIVE_PLATFORMS;
			for each(var platform:SansPlatform in platforms)
			{
				if(this.hitTestObject(platform))
				{
					if(this.Angle == 90 && CustomMovement.dy >= platform.CustomMovement.dy && (this.y + 8 <= platform.y + 2)) {
						out = true;
						break;
					}
				}
			}
			
			// Move Back
			this.x = ox;
			this.y = oy;
			
			return out;
		
		}
		
		public function HeartJump():void
		{
			if (this.Mode == HEARTMODE_BLUE)
			{
				var _tx:Number = Math.round(Math.cos(deg2rad(this.Angle)));
				var _ty:Number = Math.round(Math.sin(deg2rad(this.Angle)));
				
				if (HeartCheckSolid(_tx, _ty))
				{
					CustomMovement.dx = CustomMovement.dx - _tx * HEART_JUMP_STRENGTH;
					CustomMovement.dy = CustomMovement.dy - _ty * HEART_JUMP_STRENGTH;
				}
			}
		}
		
		public function OnMovementHorizonalStep(delta:Number, eclipsed:Number):void
		{
			this.x += CustomMovement.dx * eclipsed;
			
			if (HeartCheckWall(0, 0))
			{
				if (this.Slammed)
				{
					this.Slammed = false;
					if (Math.abs(CustomMovement.dx) > 330)
					{
						container.PlaySound("Slam");
						container.SansShake(Math.floor(Math.abs(CustomMovement.dx) / 30 / 3));
						
						if (this.SlamDamage && this.HP > 1)
						{
							HP -= 1;
						}
					}
				}
				if (CustomMovement.dx != 0)
				{
					AlignToWall(true, CustomMovement.dx);
					CustomMovement.dx = 0;
					return;
				}
			}
			
			CustomMovement.last_x = this.x;
		}
		
		public function OnMovementVerticalStep(delta:Number, eclipsed:Number):void
		{
			this.y += CustomMovement.dy * eclipsed;
			
			if (HeartCheckWall(0, 0))
			{
				if (this.Slammed)
				{
					this.Slammed = false;
					if (Math.abs(CustomMovement.dy) > 330)
					{
						container.PlaySound("Slam");
						container.SansShake(Math.floor(Math.abs(CustomMovement.dy) / 30 / 3));
						
						if (this.SlamDamage && this.HP > 1)
						{
							HP -= 1;
						}
					}
				}
				if (CustomMovement.dy != 0)
				{
					AlignToWall(false, CustomMovement.dy);
					CustomMovement.dy = 0;
					return;
				}
			}
			
			CustomMovement.last_y = this.y;
		}
		
		private function AlignToWall(AxisX:Boolean, Speed:Number):void 
		{
			if (HeartCheckWall(0, 0)) {
				var zone_bounds:Rectangle = container.combat_zone.CombatZone.getBounds(container.combat_zone.CombatZone.parent);
				var heart_bounds:Rectangle = this.getBounds(this.parent);
				
				if(AxisX) {
					if (Speed < 0 && heart_bounds.left < zone_bounds.left + 5)
						this.x = zone_bounds.left + 13;
					if (Speed > 0 && heart_bounds.right > zone_bounds.right - 5)
						this.x = zone_bounds.right - 13;
				}
				else {
					if (Speed > 0 && heart_bounds.bottom > zone_bounds.bottom - 5)
						this.y = zone_bounds.bottom - 13;
					if (Speed < 0 && heart_bounds.top < zone_bounds.top + 5)
						this.y = zone_bounds.top + 13;
				}
			}
		}
		
		public function update(delta:Number, eclipsed:Number, script:SansBattleScript):void
		{
			HeartSpeed = script.vpad.Cancel ? 75 : 150;
			
			if (Mode == HEARTMODE_RED)
			{
				if (script.vpad.U == script.vpad.D)
					CustomMovement.dy = 0;
				else
				{
					if (script.vpad.U == 1)
						CustomMovement.dy = -HeartSpeed;
					else if (script.vpad.D == 1)
						CustomMovement.dy = HeartSpeed;
				}
				
				if (script.vpad.L == script.vpad.R)
					CustomMovement.dx = 0;
				else
				{
					if (script.vpad.L == 1)
						CustomMovement.dx = -HeartSpeed;
					else if (script.vpad.R == 1)
						CustomMovement.dx = HeartSpeed;
				}
			}
			
			if (Mode == HEARTMODE_BLUE)
			{
				var DownSpeed:Number = 0;
				var Gravity:Number = 0;
				
				// Inputs & Jump
				if (Angle == 0)
				{
					if (script.vpad.L > script.vpad.LastL)
					{
						HeartJump();
					}
					if (script.vpad.L < script.vpad.LastL && CustomMovement.dx < -HEART_JUMPHOLD_CUTOFF)
					{
						CustomMovement.dx = -HEART_JUMPHOLD_CUTOFF;
					}
					
					DownSpeed = CustomMovement.dx;
				}
				
				if (Angle == 90)
				{
					if (script.vpad.U > script.vpad.LastU)
					{
						HeartJump();
					}
					if (script.vpad.U < script.vpad.LastU && CustomMovement.dy < -HEART_JUMPHOLD_CUTOFF)
					{
						CustomMovement.dy = -HEART_JUMPHOLD_CUTOFF;
					}
					
					DownSpeed = CustomMovement.dy;
				}
				
				if (Angle == 180)
				{
					if (script.vpad.R > script.vpad.LastR)
					{
						HeartJump();
					}
					if (script.vpad.R < script.vpad.LastR && CustomMovement.dx > HEART_JUMPHOLD_CUTOFF)
					{
						CustomMovement.dx = HEART_JUMPHOLD_CUTOFF;
					}
					
					DownSpeed = -CustomMovement.dx;
				}
				
				if (Angle == 270)
				{
					if (script.vpad.D > script.vpad.LastD)
					{
						HeartJump();
					}
					if (script.vpad.D < script.vpad.LastD && CustomMovement.dy > HEART_JUMPHOLD_CUTOFF)
					{
						CustomMovement.dy = HEART_JUMPHOLD_CUTOFF;
					}
					
					DownSpeed = -CustomMovement.dy;
				}
				
				// Gravity
				if (DownSpeed < 240 && DownSpeed > 15)
					Gravity = 540;
				if (DownSpeed <= 15 && DownSpeed > -30)
					Gravity = 180;
				if (DownSpeed <= -30 && DownSpeed > -120)
					Gravity = 450;
				if (DownSpeed <= -120)
					Gravity = 180;
				
				// 
				var LX:Number = Math.cos(deg2rad(this.Angle));
				var LY:Number = Math.sin(deg2rad(this.Angle));
				
				if (!HeartCheckWall(LX * 0.2, LY * 0.2))
				{
					CustomMovement.dx += LX * Gravity * eclipsed;
					CustomMovement.dy += LY * Gravity * eclipsed;
					
					if (this.Angle == 0 && CustomMovement.dx > MaxFallSpeed)
						CustomMovement.dx = MaxFallSpeed;
					if (this.Angle == 90 && CustomMovement.dy > MaxFallSpeed)
						CustomMovement.dy = MaxFallSpeed;
					if (this.Angle == 180 && CustomMovement.dx < -MaxFallSpeed)
						CustomMovement.dx = -MaxFallSpeed;
					if (this.Angle == 270 && CustomMovement.dy < -MaxFallSpeed)
						CustomMovement.dy = -MaxFallSpeed;
				}
				
				if (this.Angle == 0 || this.Angle == 180)
				{
					CustomMovement.dy = 0;
					if (script.vpad.U != script.vpad.D)
					{
						if (script.vpad.U == 1)
							CustomMovement.dy -= HeartSpeed;
						if (script.vpad.D == 1)
							CustomMovement.dy += HeartSpeed;
					}
				}
				
				if (this.Angle == 90 || this.Angle == 270)
				{
					CustomMovement.dx = 0;

					// Platforms Check
					var platforms:Array = SansPlatform.ALIVE_PLATFORMS;
					for each(var platform:SansPlatform in platforms)
					{
						if(this.hitTestObject(platform))
						{
							if(this.Angle == 90 && CustomMovement.dy >= platform.CustomMovement.dy && (this.y + 8 <= platform.y + 2)) {
								CustomMovement.dx = platform.CustomMovement.dx;
								CustomMovement.dy = platform.CustomMovement.dy;
								this.y = platform.y - 8.05;
								break;
							}
						}
					}

					if (script.vpad.L != script.vpad.R)
					{
						if (script.vpad.L == 1)
							CustomMovement.dx -= HeartSpeed;
						if (script.vpad.R == 1)
							CustomMovement.dx += HeartSpeed;
					}
				}
				
			}
			
			OnMovementHorizonalStep(delta, eclipsed);
			OnMovementVerticalStep(delta, eclipsed);
		}
		
		public function destroy():void {}
	}

}