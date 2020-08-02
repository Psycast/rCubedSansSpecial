package scripts
{
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.AntiAliasType;

    public class SansMenuItem extends Sprite
    {
        public static var GUID:int = 0;

        public static var ITEMS:Array = [];

        private var _field:TextField;
        
        public var UID:int = 0;
        public var ID:int = 0;
        public var Action:String = "";
        public var BackAction:String = "";
        public var Created:Boolean = false;

        public function SansMenuItem():void
        {
            UID = GUID++;
			ITEMS.push(this);
            
            _field = new TextField();
            _field.x = 32;
            _field.y = -6;
            _field.embedFonts = true;
            _field.wordWrap = true;
			_field.multiline = true;
			_field.antiAliasType = AntiAliasType.ADVANCED;
			_field.embedFonts = true;
			_field.defaultTextFormat = SansRPGText.DEFAULT_TEXT;
            _field.gridFitType = "pixel";
            _field.sharpness = 400;
            _field.selectable = false;
            _field.width = 512;
            _field.height = 96;
            addChild(_field);

            super();
        }

        public function get Text():String {
            return _field.text;
        }

        public function set Text(str:String):void {
            _field.text = str;
        }

        public function destroy():void
        {
            var i:int = ITEMS.indexOf(this);
            ITEMS.splice(i, 1);

            this.parent.removeChild(this);
        }

        public static function clear():void
        {
            for(var i:int = ITEMS.length - 1; i >= 0; i--)
				ITEMS[i].destroy();
			ITEMS = [];
        }
    }
}