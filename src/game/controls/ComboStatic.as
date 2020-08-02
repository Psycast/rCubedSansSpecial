package game.controls {
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.text.AntiAliasType;
	import game.GameOptions;

	public class ComboStatic extends Sprite
	{
		private var field:TextField;

		public function ComboStatic(text:String)
		{
			field = new TextField();
			field.defaultTextFormat = new TextFormat("Segoe UI", 17, 0x0098CB, true);
			field.antiAliasType = AntiAliasType.ADVANCED;
			field.embedFonts = true;
			field.selectable = false;
			field.autoSize = TextFieldAutoSize.LEFT;
			field.x = 0;
			field.y = 0;
			field.htmlText = text;
			addChild(field);
		}
	}
}
