package assets 
{
	import com.flashfla.utils.ColorUtil;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	public class GameBackgroundColor extends Sprite 
	{
		static public var BG_LIGHT:int = 0x1495BD;
		static public var BG_DARK:int = 0x033242;
		static public var BG_STATIC:int = 0x0C6A88;
		static public var BG_POPUP:int = 0x074B62;
		
		public function GameBackgroundColor() 
		{
			super();
			/*
			var d:Date = new Date();
			if (d.getMonth() == 9 && d.getDate() == 31) {
				BG_LIGHT = 0x9047a8;
				BG_DARK = 0x400554;
				BG_MIDDLE = ColorUtil.brightenColor(BG_DARK, 0.1);
				BG_POPUP = ColorUtil.brightenColor(BG_DARK, 0.05);
			}
			if (d.getMonth() == 11 && d.getDate() == 25) {
				BG_LIGHT = 0x951616;
				BG_DARK = 0x440101;
				BG_MIDDLE = ColorUtil.brightenColor(BG_DARK, 0.1);
				BG_POPUP = ColorUtil.brightenColor(BG_DARK, 0.05);
			}
			*/
			redraw();
		}
		
		public function redraw():void 
		{
			// Create Background
			var _matrix:Matrix = new Matrix();
			_matrix.createGradientBox( Main.GAME_WIDTH, Main.GAME_HEIGHT, 5.75);
			this.graphics.clear();
			this.graphics.beginGradientFill(GradientType.LINEAR, [BG_LIGHT, BG_DARK], [1, 1], [0x00, 0xFF], _matrix);
			this.graphics.drawRect(0, 0,  Main.GAME_WIDTH, Main.GAME_HEIGHT);
			this.graphics.endFill();
			
			var bt:BitmapData = new GameBackgroundStripes();
			this.graphics.beginBitmapFill(bt);
			this.graphics.drawRect(0, 0, Main.GAME_WIDTH, Main.GAME_HEIGHT);
			this.graphics.endFill();
		}
		
	}

}