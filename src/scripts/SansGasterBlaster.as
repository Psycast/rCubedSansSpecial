package scripts
{
	import ext.scripts.aniSansGasterBlaster;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	public class SansGasterBlaster extends Sprite implements ISansTickable, ISansDamageable
	{
		public static const STATE_ENTER:int = 0;
		public static const STATE_WAIT:int = 1;
		public static const STATE_FIRE:int = 2;
		public static const STATE_LEAVE:int = 3;
		
		private var container:SansAttackContainer;
		
		private var GFX_Head:aniSansGasterBlaster;
		private var GFX_BlastHit:SansGasterBlastBeam;
		private var GFX_Blast1:SansGasterBlastBeam;
		private var GFX_Blast2:SansGasterBlastBeam;
		private var GFX_Blast3:SansGasterBlastBeam;
		
		public var Damage:int = 0;
		public var Karma:int = 0;
		public var Ang:Number = 90;
		public var EndX:int = 0;
		public var EndY:int = 0;
		public var EndAng:int = 0;
		public var State:int = STATE_ENTER;
		public var Timer:Number = 0;
		public var LeaveSpeed:Number = 0;
		public var Angled:Boolean = false;
		
		public function SansGasterBlaster(container:SansAttackContainer, Size:int, X:int, Y:int, EndX:int, EndY:int, EndAng:int, Timer:Number, BlastTime:Number)
		{
			//trace(Size, X, Y, EndX, EndY, EndAng, Timer, BlastTime);
			
			this.container = container;
			
			this.x = X;
			this.y = Y;
			
			this.EndX = EndX;
			this.EndY = EndY;
			this.EndAng = EndAng;
			this.Timer = Timer;

			if(EndAng != 0 && EndAng != 90 && EndAng != 180 && EndAng != 270)
				this.Angled = true;
			
			// Components
			GFX_Head = new aniSansGasterBlaster();
			addChild(GFX_Head);
			
			GFX_Blast1 = new SansGasterBlastBeam(1000, 32);
			GFX_Blast1.BlastTime = BlastTime;
			addChild(GFX_Blast1);
			
			GFX_Blast2 = new SansGasterBlastBeam(16, 24);
			addChild(GFX_Blast2);
			
			GFX_Blast3 = new SansGasterBlastBeam(16, 16);
			addChild(GFX_Blast3);

			GFX_BlastHit = new SansGasterBlastBeam(1000, 16, 0xFF0000);
			GFX_BlastHit.alpha = 0;
			addChild(GFX_BlastHit);
			
			// Sounds
			this.container.StopAudio("GasterBlaster");
			this.container.PlaySound("GasterBlaster", 1.2, "GasterBlaster");
			
			if (X == EndX && Y == EndY)
			{
				this.Ang = this.EndAng;
				this.rotation = this.Ang;
			}
			
			// Resizing
			if (Size == 0)
				GFX_Head.scaleX = 2;
			if (Size == 1)
				GFX_Head.scaleX = GFX_Head.scaleY = 2;
			if (Size == 2)
				GFX_Head.scaleX = GFX_Head.scaleY = 3;
			
			// Blast Position
			var GasterScale:Number = GFX_Head.scaleY / 2;
			GFX_Blast1.x = 30 * GasterScale;
			GFX_Blast1.width = 1000;
			GFX_Blast2.x = 20 * GasterScale;
			GFX_Blast2.width = 10 * GasterScale;
			GFX_Blast2.x = 20 * GasterScale;
			GFX_Blast2.width = 10 * GasterScale;
			GFX_Blast3.x = 10 * GasterScale;
			GFX_Blast3.width = 20 * GasterScale;
			GFX_BlastHit.x = 30 * GasterScale;
			GFX_BlastHit.width = 1000;
			
			this.container.layer_combat_zone.addChild(this);
		}
		
		private function drawRect(w:Number, h:Number, mx:Number, my:Number):Sprite
		{
			var spr:Sprite = new Sprite();
			spr.graphics.lineStyle(0, 0, 0);
			spr.graphics.beginFill(0xFFFFFF);
			spr.graphics.drawRect(0, 0, w, h);
			
			spr.x = mx;
			spr.y = my;
			
			this.addChild(spr);
			
			return spr;
		}
		
		/* INTERFACE scripts.ISansTickable */
		
		public function update(delta:Number, eclipsed:Number, script:SansBattleScript):void
		{
			if (Timer > 0)
			{
				if (State == STATE_WAIT || State == STATE_FIRE)
				{
					Timer -= Math.min(eclipsed, Timer);
				}
			}
			
			if (State == STATE_ENTER)
			{
				if (Math.abs(this.x - EndX) >= 3)
					this.x += (EndX - this.x) * eclipsed * 10;
				else
					this.x = EndX;
				
				if (Math.abs(this.y - EndY) >= 3)
					this.y += (EndY - this.y) * eclipsed * 10;
				else
					this.y = EndY;
				
				if (Math.abs(this.Ang - EndAng) >= 3)
				{
					Ang += (EndAng - Ang) * eclipsed * 10;
					this.rotation = Ang;
				}
				else
				{
					this.Ang = EndAng;
					this.rotation = Ang;
				}
				//trace(x, EndX, Math.abs(this.x - EndX), (Math.abs(this.x - EndX) >= 3), " | ", y, EndY, Math.abs(this.y - EndY), (Math.abs(this.y - EndY) >= 3), " | ",  Ang, EndAng, Math.abs(this.Ang - EndAng), (Math.abs(this.Ang - EndAng) >= 3));
				if (Math.abs(this.x - EndX) < 0.1 && Math.abs(this.y - EndY) < 0.1 && Math.abs(Ang - EndAng) < 0.1)
				{
					State = STATE_WAIT;
				}
			}
			if (State == STATE_WAIT)
			{
				if (Timer <= 0)
				{
					GFX_Head.gotoAndPlay("Fire");
					State = STATE_FIRE;
					Timer = 0.1;
				}
			}
			if (State == STATE_FIRE)
			{
				if (Timer <= 0)
				{
					State = STATE_LEAVE;
					
					GFX_Blast1.visible = GFX_Blast2.visible = GFX_Blast3.visible =  GFX_BlastHit.visible = true;
					
					Damage = 1;
					Karma = 10;
					
					container.StopAudio("GasterBlast");
					container.StopAudio("GasterBlast2");
					
					container.PlaySound("GasterBlast", 1.2, "GasterBlast");
					container.PlaySound("GasterBlast2", 1.2, "GasterBlast2");
					
					if (GFX_Head.scaleY > 1) {
						container.SansShake(5);
					}
				}
			}
			if (State == STATE_LEAVE)
			{
				LeaveSpeed += 30;
				
				if (this.x < -width || this.y < -height || this.y > SansAttackContainer.CONTAINER_HEIGHT + height || this.x > SansAttackContainer.CONTAINER_WIDTH + width)
					LeaveSpeed = 0;
					
				this.x -= Math.cos(deg2rad(Ang)) * eclipsed * LeaveSpeed;
				this.y -= Math.sin(deg2rad(Ang)) * eclipsed * LeaveSpeed;
			}
			
			// Update Blast Field
			if (GFX_Blast1.visible)
			{
				
				GFX_Blast1.Timer += eclipsed;
				
				if (GFX_Blast1.Timer < (4 / 30))
				{
					GFX_Blast1.BaseSize += Math.floor(35 * GFX_Head.scaleY / 4) * eclipsed * 30;
				}
				
				if (GFX_Blast1.Timer >= (4 / 30) && GFX_Blast1.Timer < ((4 / 30) + eclipsed))
				{
					GFX_Blast1.BaseSize = 35 * GFX_Head.scaleY;
				}
				
				if (GFX_Blast1.Timer > ((5 / 30) + GFX_Blast1.BlastTime)) {
					GFX_Blast1.BaseSize = GFX_Blast1.BaseSize * Math.pow(0.8, (eclipsed * 30));
					GFX_Blast1.alpha = (1 - (((GFX_Blast1.Timer - GFX_Blast1.BlastTime) * 30 - 5) / 10));
					
					if (GFX_Blast1.BaseSize <= 2) {
						container.RemoveTickable(this);
					}
				}
				
				if (GFX_Blast1.alpha < 0.8) {
					Damage = 0;
					GFX_BlastHit.visible = false;
				}
				
				GFX_Blast1.SineSize = Math.sin(GFX_Blast1.Timer * 30 / 1.5) * GFX_Blast1.BaseSize / 4;
				GFX_Blast1.height = GFX_Blast1.BaseSize + GFX_Blast1.SineSize;
				GFX_Blast2.height = GFX_Blast1.BaseSize / 1.25 + GFX_Blast1.SineSize;
				GFX_Blast3.height = GFX_Blast1.BaseSize / 2 + GFX_Blast1.SineSize;
				GFX_BlastHit.height = GFX_Blast1.BaseSize * 3 / 4;
			}
			
			GFX_Blast2.alpha = GFX_Blast3.alpha = GFX_Blast1.alpha;
		}
		
		public function destroy():void
		{
		
		}
	
		/* INTERFACE scripts.ISansDamageable */
		
		public function getHitbox():Sprite
		{
			return GFX_BlastHit;
		}

		public function getColor():int
		{
			return 0;
		}

		public function getDamage():int
		{
			return Damage;
		}

		public function getKarma():int
		{
			return Karma;
		}
		
		public function setKarma(val:int):void
		{
			Karma = val;
		}
	}

}