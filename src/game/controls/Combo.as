package game.controls {
	import com.flashfla.utils.ColorUtil;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.text.AntiAliasType;
	import game.GameOptions;

	public class Combo extends Sprite
	{
		public static const ALIGN_LEFT:String = TextFieldAutoSize.LEFT;
		public static const ALIGN_RIGHT:String = TextFieldAutoSize.RIGHT;

		private var options:GameOptions;
		
		private var colors:Array = [];
		private var darkcolors:Array = [];

		private var field:TextField;
		private var fieldShadow:TextField;

		public function Combo(options:GameOptions)
		{
			this.options = options;
			
			for (var i:int = 0; i < options.comboColours.length; i++) {
				colors[i] = options.comboColours[i];
				darkcolors[i] = ColorUtil.darkenColor(options.comboColours[i], 0.5);
			}

			fieldShadow = new TextField();
			fieldShadow.defaultTextFormat = new TextFormat("Segoe UI", 50, darkcolors[2], true);
			fieldShadow.antiAliasType = AntiAliasType.ADVANCED;
			fieldShadow.embedFonts = true;
			fieldShadow.selectable = false;
			fieldShadow.autoSize = TextFieldAutoSize.LEFT;
			fieldShadow.x = 2;
			fieldShadow.y = 2;
			fieldShadow.text = "0";
			addChild(fieldShadow);

			field = new TextField();
			field.defaultTextFormat = new TextFormat("Segoe UI", 50, colors[2], true);
			field.antiAliasType = AntiAliasType.ADVANCED;
			field.embedFonts = true;
			field.selectable = false;
			field.autoSize = TextFieldAutoSize.LEFT;
			field.x = 0;
			field.y = 0;
			field.text = "0";
			addChild(field);

			if (options && options.isAutoplay && !options.isEditor && !options.multiplayer) {
				field.textColor = 0xD00000;
				fieldShadow.textColor = 0x5B0000;
			}
		}

		public function update(combo:int, amazing:int = 0, perfect:int = 0, good:int = 0, average:int = 0, miss:int = 0, boo:int = 0):void
		{
			field.text = combo.toString();
			fieldShadow.text = combo.toString();

			if (options && (!options.isAutoplay || options.isEditor || options.multiplayer)) {
				if (miss) {
					field.textColor = colors[0];
					fieldShadow.textColor = darkcolors[0];
				} else if (good + average + boo == 0) {
					field.textColor = colors[2];
					fieldShadow.textColor = darkcolors[2];
				} else {
					field.textColor = colors[1];
					fieldShadow.textColor = darkcolors[1];
				}
			}
		}

		public function set alignment(value:String):void
		{
			field.autoSize = value;
			fieldShadow.autoSize = value;
		}
	}
}
