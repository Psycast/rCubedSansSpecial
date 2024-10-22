package classes 
{
	import assets.GameBackgroundColor;
	import flash.display.Sprite;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class MouseTooltip extends Sprite 
	{
		private var msg:TextField;
		private var maxWidth:int = 250;
		public function MouseTooltip(string:String = "", maxWidth:int = 250) 
		{
			super();
			msg = new TextField();
			msg.x = 5;
			msg.selectable = false;
			msg.embedFonts = true;
			msg.antiAliasType = AntiAliasType.ADVANCED;
			msg.autoSize = "left";
			msg.defaultTextFormat = Constant.TEXT_FORMAT_12;
			addChild(msg);

			this.maxWidth = maxWidth;
			
			if (string != "")
				message = string;
		}
		
		public function set message(value:String):void {
			msg.wordWrap = false;
			msg.multiline = false;
			msg.htmlText = value;
			if (msg.width > maxWidth) {
				msg.wordWrap = true;
				msg.multiline = true;
				msg.width = maxWidth;
			}
			this.graphics.clear();
			this.graphics.lineStyle(1, 0xffffff, 0.75);
			this.graphics.beginFill(GameBackgroundColor.BG_POPUP, 1);
			this.graphics.drawRect(0, 0, msg.width + 10, msg.height + 2);
			this.graphics.endFill();
		}
		
	}

}