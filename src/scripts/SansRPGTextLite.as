package scripts
{
    import flash.text.TextField;
    import flash.display.Sprite;
    import flash.text.AntiAliasType;

    public class SansRPGTextLite extends Sprite implements ISansTickable  {
        public var T:Number = 0;
        public var FullText:String = "";
        public var CurrentChar:int = 0;
        public var Timeout:Number = 0;

        public var _field:TextField;

        public function SansRPGTextLite():void
        {
            _field = new TextField();
            _field.embedFonts = true;
            _field.wordWrap = true;
			_field.multiline = true;
			_field.antiAliasType = AntiAliasType.ADVANCED;
			_field.embedFonts = true;
			_field.defaultTextFormat = SansRPGText.DEFAULT_TEXT;
            _field.gridFitType = "pixel";
            _field.sharpness = 400;
            _field.thickness = 50;
            _field.selectable = false;
            addChild(_field);
        }

        public function get text():String
        {
            return _field.text;
        }

        public function set text(str:String):void
        {
            _field.text = str;
        }

        public function setSize(w:int, h:int):void
        {
            _field.width = w;
            _field.height = h;
        }

        public function update(delta:Number, eclipsed:Number, script:SansBattleScript):void
        {
            T += eclipsed;

            // Update Per Character
            if(CurrentChar < FullText.length && T > (1/30))
            {
                T -= (1 / 30);
                CurrentChar++;
                text = FullText.substr(0, CurrentChar);
            }

            if(CurrentChar == FullText.length && Timeout > 0)
            {
                Timeout -= Math.min(eclipsed, Timeout);
                if(Timeout <= 1)
                    this.alpha = Timeout;
                if(Timeout <= 0)
                    script.RemoveLiteTickable(this);
            }
        }

        public function destroy():void
        {
        	if(this.parent)
                this.parent.removeChild(this);
        }
    }
}