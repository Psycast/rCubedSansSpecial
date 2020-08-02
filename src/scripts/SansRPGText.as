package scripts 
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.AntiAliasType;
	import ext.scripts.SansKeyTutorialMC;
	import ext.scripts.SansComicSansMS;
	import ext.scripts.SansDetermination;
    import ext.scripts.SansHachicro;
    import ext.scripts.SansMarsNeedsCunnilingus;
	
	public class SansRPGText extends Sprite implements ISansTickable 
	{
        SansDetermination;
        SansComicSansMS;
        SansHachicro;
        SansMarsNeedsCunnilingus;
        
        public static const SANS_TEXT:TextFormat = new TextFormat(new SansComicSansMS().fontName, 14, 0x000000, true); { SANS_TEXT.letterSpacing = 2; }
        public static const DEFAULT_TEXT:TextFormat = new TextFormat(new SansDetermination().fontName, 24, 0xFFFFFF);
        public static const DAMAGE_TEXT:TextFormat = new TextFormat(new SansHachicro().fontName, 28, 0xFFFFFF);
        public static const BATTLE_TEXT:TextFormat = new TextFormat(new SansMarsNeedsCunnilingus().fontName, 24, 0xFFFFFF);
        
        public static var ITEMS:Array = [];

        public var container:SansAttackContainer;

        public var T:Number = 0;
        public var FullText:String = "";
        public var CurrentChar:int = 0;
        public var Voice:String = "BattleText";
        public var Timeout:Number = 0;

        public var EndFunc:String = "";

        public var Interactive:Boolean = false;
        public var ShowTutorial:Boolean = false;
        public var ShowTutorialTimer:Number = 0;
        public var TutorialKeyInputs:SansKeyTutorialMC;

        public var _field:TextField;

        public function SansRPGText(container:SansAttackContainer, font:TextFormat):void
        {
            this.container = container;

            _field = new TextField();
            _field.embedFonts = true;
            _field.wordWrap = true;
			_field.multiline = true;
			_field.antiAliasType = AntiAliasType.ADVANCED;
			_field.embedFonts = true;
			_field.defaultTextFormat = font;
            _field.gridFitType = "pixel";
            _field.sharpness = 400;
            _field.thickness = 50;
            _field.selectable = false;
            addChild(_field);

            ITEMS[ITEMS.length] = this;
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
                if(Voice != "") {
                    container.PlaySound(Voice);
                }
            }

            if(Interactive)
            {
                if(script.vpad.Confirm > script.vpad.LastConfirm && CurrentChar == FullText.length)
                    script.RemoveTickable(this);

                if(script.vpad.Cancel > script.vpad.LastCancel)
                {
                    CurrentChar = FullText.length;
                    text = FullText;
                    T = 0;
                }

                if(ShowTutorial && CurrentChar == FullText.length)
                {
                    ShowTutorialTimer += eclipsed;

                    // Update Alpha on Tutorial
                    if(TutorialKeyInputs != null)
                        TutorialKeyInputs.alpha = Math.min(1, ShowTutorialTimer);

                    // Delay Showing Tutorial
                    if(ShowTutorialTimer > 3 && TutorialKeyInputs == null)
                    {
                        // Add Tutorial
                        ShowTutorialTimer = 0;
                        TutorialKeyInputs = new SansKeyTutorialMC();
                        TutorialKeyInputs.x = 122;
                        TutorialKeyInputs.y = 249;
                        TutorialKeyInputs.alpha = 0;
                        container.layer_combat_zone.addChild(TutorialKeyInputs);
                    }
                }
            }
            else
            {
                if(CurrentChar == FullText.length && Timeout > 0)
                {
                    Timeout -= Math.min(eclipsed, Timeout);
                    if(Timeout <= 0)
                        script.RemoveTickable(this);
                }
            }
        }

        public function destroy():void
        {
            if(TutorialKeyInputs != null)
                TutorialKeyInputs.parent.removeChild(TutorialKeyInputs);

            var i:int = ITEMS.indexOf(this);
            ITEMS.splice(i, 1);

            if(EndFunc != "")
                container[EndFunc]();
        }
        
        public static function clear():void
        {
            for(var i:int = ITEMS.length - 1; i >= 0; i--)
				ITEMS[i].container.RemoveTickable(ITEMS[i]);
			ITEMS = [];
        }
    }
}