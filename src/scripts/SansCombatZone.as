package scripts 
{
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	public class SansCombatZone extends Sprite implements ISansTickable
	{
		private var container:SansAttackContainer;
		
		public static var ResizeSpeed:Number = 540;
		public static var EndResize:String = null;
		
		public var TargetLeft:int = 0;
		public var TargetTop:int = 0;
		public var TargetRight:int = 0;
		public var TargetBottom:int = 0;
		
		private var Border_X:Number = 0;
		private var Border_Y:Number = 0;
		private var Border_Width:Number = 0;
		private var Border_Height:Number = 0;
		public var Border_Stroke:Number = 5;
		
		public var CombatZone:Sprite = new Sprite();
		public var CombatZoneClipper:Sprite = new Sprite();

		public var InfoText:String = "";
		
		public function SansCombatZone(container:SansAttackContainer)
		{
			this.container = container;
			super();
			
			// Visible Border
			container.layer_combat_zone.addChild(CombatZone);
			
			this.container.layer_combat_zone_clipped.mask = CombatZoneClipper;
		}
		
		public function CombatZoneSpeed(spd:int):void
		{
			ResizeSpeed = spd;
		}
		
		public function CombatZoneResize(left:Number, top:Number, right:Number, bottom:Number, callback:String = null):void
		{
			TargetLeft = left;
			TargetBottom = bottom;
			TargetRight = right;
			TargetTop = top;
			
			EndResize = callback;
			
			CombatZone.alpha = 1;
		}
		
		public function CombatZoneResizeInstant(left:Number, top:Number, right:Number, bottom:Number):void
		{
			TargetLeft = left;
			TargetBottom = bottom;
			TargetRight = right;
			TargetTop = top;
			
			Border_X = TargetLeft;
			Border_Y = TargetTop;
			Border_Width = TargetRight - TargetLeft;
			Border_Height = TargetBottom - TargetTop;
			
			UpdateBorder();
			
			CombatZoneTick(0);
			
			CombatZone.alpha = 1;
		}
		
		public function CombatZoneHide():void
		{
			CombatZone.alpha = 0;
		}
		
		public function UpdateBorder():void 
		{
			Border_X = Math.round(Border_X);
			Border_Y = Math.round(Border_Y);
			Border_Width = Math.round(Border_Width);
			Border_Height = Math.round(Border_Height);
			
			CombatZone.x = Border_X;
			CombatZone.y = Border_Y;
			CombatZone.graphics.clear();
			CombatZone.graphics.lineStyle(0, 0, 0);
			CombatZone.graphics.beginFill(0xFFFFFF, 1);
			CombatZone.graphics.drawRect(0, 0, Border_Width, Border_Stroke); // Top
			CombatZone.graphics.drawRect(0, Border_Stroke, Border_Stroke, Border_Height - Border_Stroke * 2); // Left
			CombatZone.graphics.drawRect(Border_Width - Border_Stroke, Border_Stroke, Border_Stroke, Border_Height - Border_Stroke * 2); // Right
			CombatZone.graphics.drawRect(0, Border_Height - Border_Stroke, Border_Width, Border_Stroke); // Bottom
			CombatZone.graphics.endFill();
			
			UpdateMask();
		}
		
		public function UpdateMask():void 
		{
			CombatZoneClipper.graphics.clear();
			CombatZoneClipper.graphics.lineStyle(0, 0, 0);
			CombatZoneClipper.graphics.beginFill(0xFF0000, 1);
			CombatZoneClipper.graphics.drawRect(Border_X + container.CenterX, Border_Y + container.CenterY, Border_Width, Border_Height);
			CombatZoneClipper.graphics.endFill();
		}
		
		public function CombatZoneTick(eclipsed:Number):void
		{
			
			var BBox:Rectangle = CombatZone.getBounds(CombatZone.parent);
			
			var ReDraw:Boolean = false;
			var X1:Number = Math.min(ResizeSpeed * eclipsed, (Math.abs(BBox.left - TargetLeft)));
			var Y1:Number = Math.min(ResizeSpeed * eclipsed, (Math.abs(BBox.top - TargetTop)));
			var X2:Number = Math.min(ResizeSpeed * eclipsed, (Math.abs(BBox.right - TargetRight)));
			var Y2:Number = Math.min(ResizeSpeed * eclipsed, (Math.abs(BBox.bottom - TargetBottom)));
			
			// Left
			if (BBox.left > TargetLeft) {
				Border_X -= X1;
				Border_Width += X1;
				ReDraw = true;
			} else if (BBox.left < TargetLeft) {
				Border_X += X1;
				Border_Width -= X1;
				ReDraw = true;
			}
			
			// Top
			if (BBox.top > TargetTop) {
				Border_Y -= Y1;
				Border_Height += Y1;
				ReDraw = true;
			} else if (BBox.top < TargetTop) {
				Border_Y += Y1;
				Border_Height -= Y1;
				ReDraw = true;
			}
			
			// Right
			if (BBox.right > TargetRight) {
				Border_Width -= X2;
				ReDraw = true;
			} else if (BBox.right < TargetRight) {
				Border_Width += X2;
				ReDraw = true;
			}
			
			// Bottom
			if (BBox.bottom > TargetBottom) {
				Border_Height -= Y2;
				ReDraw = true;
			} else if (BBox.bottom < TargetBottom) {
				Border_Height += Y2;
				ReDraw = true;
			}
			/*
			if (Math.abs(BBox.left - TargetLeft) <= 2) Border_X = TargetLeft;
			if (Math.abs(BBox.top - TargetTop) <= 2) Border_Y = TargetTop;
			if (Math.abs(BBox.bottom - TargetBottom) <= 2) Border_Height = TargetBottom - TargetTop;
			if (Math.abs(BBox.right - TargetRight) <= 2) Border_Width = TargetRight - TargetLeft;
			*/
			// End Resize
			//trace(Math.abs(BBox.top - TargetTop), Math.abs(BBox.left - TargetLeft), Math.abs(BBox.right - TargetRight), Math.abs(BBox.bottom - TargetBottom));
			if (EndResize != null && 
				Math.abs(BBox.left - TargetLeft) <= 2 && 
				Math.abs(BBox.top - TargetTop) <= 2 && 
				Math.abs(BBox.bottom - TargetBottom) <= 2 && 
				Math.abs(BBox.right - TargetRight) <= 2)
			{
				Border_X = TargetLeft;
				Border_Y = TargetTop;
				Border_Height = TargetBottom - TargetTop;
				Border_Width = TargetRight - TargetLeft;
				
				UpdateBorder();
				
				container[EndResize]();
				EndResize = null;
			}
			
			if(ReDraw) {
				UpdateBorder();
				ReDraw = false;
			}
			
			// Adjust Heart Position
			var heart:SansPlayerHeart = container.player_heart;
			var heartBounds:Rectangle = heart.getBounds(heart.parent);
			if (BBox.left + Border_Stroke > heartBounds.left) 
				heart.x = BBox.left + Border_Stroke + 8;
			if (BBox.top + Border_Stroke > heartBounds.top) 
				heart.y = BBox.top + Border_Stroke + 8;
			if (BBox.right - Border_Stroke < heartBounds.right) 
				heart.x = BBox.right - Border_Stroke - 8;
			if (BBox.bottom - Border_Stroke < heartBounds.bottom) 
				heart.y = BBox.bottom - Border_Stroke - 8;
		}
		
		// Sans Battle Methods
		
		public function update(delta:Number, eclipsed:Number, script:SansBattleScript):void 
		{
			CombatZoneTick(eclipsed);
		}
		
		public function destroy():void { }
		
		public function hitTest(heart:Sprite):Boolean 
		{
			// Bounds Check
			if (heart.x < Border_X + Border_Stroke + 8) return true;
			if (heart.y < Border_Y + Border_Stroke + 8) return true;
			if (heart.x > Border_X + Border_Width - Border_Stroke - 8) return true;
			if (heart.y > Border_Y + Border_Height - Border_Stroke - 8) return true;
			
			return false;
		}
		
		public function getBoundsBox():Rectangle 
		{
			return CombatZone.getBounds(CombatZone.parent);
		}

		public function get width_center():Number
		{
			return Border_Width / 2;
		}
		
		public function get height_center():Number
		{
			return Border_Height / 2;
		}
		
	}

}