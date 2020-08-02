package scripts
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.getDefinitionByName;
	import ext.scripts.SansStrike;
	import ext.scripts.SansSpeechBubble;
	import ext.scripts.soundSansFlash;
	import ext.scripts.soundSansBoneStab;
	import ext.scripts.soundSansDing;
	import ext.scripts.soundSansGasterBlast;
	import ext.scripts.soundSansGasterBlast2;
	import ext.scripts.soundSansGasterBlaster;
	import ext.scripts.soundSansMenuSelect;
	import ext.scripts.soundSansMenuCursor;
	import ext.scripts.soundSansPlayerDamaged;
	import ext.scripts.soundSansPlayerFight;
	import ext.scripts.soundSansSansSpeak;
	import ext.scripts.soundSansSlam;
	import ext.scripts.soundSansWarning;
	import com.flashfla.utils.ArrayUtil;
	import classes.chart.Song;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import ext.scripts.soundSansPlayerHeal;
	import flash.events.Event;
	import ext.scripts.soundSansBattleText;
	import ext.scripts.SansPlayerNameBD;
	import flash.display.Bitmap;
	import flash.text.TextField;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.utils.getTimer;
	import flash.geom.Point;
	import flash.display.Shape;
	import game.GamePlay;
	import ext.scripts.soundSansHeartSplit;
	import ext.scripts.soundSansHeartShatter;
	
	public class SansAttackContainer extends Sprite
	{
		private static var SCRATCH:Point = new Point(0, 0);
		private var myself:SansAttackContainer;
		private var script:SansBattleScript;
		private var soundCache:Object = {};
		private var soundTags:Object = {};
		private var TL_FUNCTIONS:Object = {};
		
		public var ItemDB:Array = [
			[0, 99, "Butterscotch Pie", "Pie"],
			[0, 90, "Instant Noodles", "I.Noodles"],
			[0, 60, "Face Steak", "Steak"],
			[0, 40, "Legandary Hero", "L. Hero"]
		];

		public var PlayerItems:Array = [0, 1, 2, 3, 3, 3, 3, 3];

		public var platforms:Array = [];
		public var hitboxes:Array = [];
		public var tickables:Array = [];

		public var player_heart:SansPlayerHeart;
		public var combat_zone:SansCombatZone;
		public var menu_group:SansBattleMenu;
		
		public var bg_music:Sound;
		public var bg_music_channel:SoundChannel;
		public var bg_music_time:Number = 0;
		
		public var layer_background:Sprite;
		public var layer_enemies:Sprite;
		public var layer_buttons:Sprite;
		public var layer_combat_zone:Sprite;
		public var layer_combat_zone_clipped:Sprite;
		public var layer_overlay:Sprite;
	
		public static const HITTEST_BORDER:int = 0;
		public static const HITTEST_PLATFORMS:int = 1;
		public static const HITTEST_HITBOXES:int = 2;
		
		public static const CONTAINER_WIDTH:int = 640;
		public static const CONTAINER_HEIGHT:int = 480;
		
		public var PiesEatten:int = 0;
		public var LevelSkipped:Boolean = false;

		// Attacks
		public var HitAttempts:int = 0;
		public var NextAttack:int = 0;
		
		// Sans Sprite
		public var SansBubble:SansSpeechBubble = new SansSpeechBubble();
		public var SansNPCSweat:SansSpriteSweat = new SansSpriteSweat();
		public var SansNPCHead:SansSpriteHead = new SansSpriteHead();
		public var SansNPCTorso:SansSpriteTorso = new SansSpriteTorso();
		public var SansNPCLegs:SansSpriteLegs = new SansSpriteLegs();
		public var SansNPCBody:SansSpriteBody = new SansSpriteBody();
		public var SansSpriteAll:Array;
		
		public function SansAttackContainer(script:SansBattleScript):void {
			this.script = script;
			this.myself = this;
			
			this.x = CenterX = (Main.GAME_WIDTH - CONTAINER_WIDTH) / 2;
			this.y = CenterY = (Main.GAME_HEIGHT - CONTAINER_HEIGHT) / 2;
			
			// Clipping Mask
			var _mask:Sprite = new Sprite();
			_mask.graphics.lineStyle(0, 0, 0);
			_mask.graphics.beginFill(0xffffff, 1);
			_mask.graphics.drawRect(0, 0, CONTAINER_WIDTH, CONTAINER_HEIGHT);
			_mask.graphics.endFill();
			_mask.x = this.x;
			_mask.y = this.y;
			this.mask = _mask;
			
			// Layer
			layer_background = new Sprite();
			addChild(layer_background);
			layer_enemies = new Sprite();
			addChild(layer_enemies);
			layer_buttons = new Sprite();
			addChild(layer_buttons);
			layer_combat_zone = new Sprite();
			addChild(layer_combat_zone);
			layer_combat_zone_clipped = new Sprite();
			addChild(layer_combat_zone_clipped);

			layer_overlay = new Sprite();
			layer_overlay.alpha = 0;
			layer_overlay.graphics.beginFill(0x000000, 1);
			layer_overlay.graphics.drawRect(0, 0, CONTAINER_WIDTH, CONTAINER_HEIGHT);
			layer_overlay.graphics.endFill();
			addChild(layer_overlay);
			
			combat_zone = new SansCombatZone(this);
			combat_zone.alpha = 0;
			
			player_heart = new SansPlayerHeart(this);
			player_heart.alpha = 0;
			
			menu_group = new SansBattleMenu(this);
			menu_group.alpha = 0;

			HPBarCreate();

			// Sans
			SansNPCSweat.visible = SansNPCBody.visible = false;
			SansNPCHead.x = SansNPCTorso.x = SansNPCBody.x = SansNPCLegs.x = SansNPCSweat.x = 320;
			SansNPCHead.y = 128;
			SansNPCTorso.y = 176;
			SansNPCLegs.y = 224;
			SansNPCBody.y = -16;
			SansNPCSweat.y = -176;

			layer_enemies.addChild(SansNPCLegs);
			layer_enemies.addChild(SansNPCTorso);
			layer_enemies.addChild(SansNPCBody);
			layer_enemies.addChild(SansNPCHead);
			layer_enemies.addChild(SansNPCSweat);

			// Init Params
			SansSpriteAll = [SansNPCSweat, SansNPCHead, SansNPCTorso, SansNPCLegs, SansNPCBody];
			SansNPCLegs.alpha = SansNPCTorso.alpha = SansNPCBody.alpha = SansNPCHead.alpha = SansNPCSweat.alpha = 0;
			player_heart.KR = 0;
			player_heart.KR_T = 0;
			SansAnimation();
			SansHead("ClosedEyes");
		}
		
		public function update(delta:Number, eclipsed:Number):void {
			TLTick(delta, eclipsed);
			
			for each(var tickable:ISansTickable in tickables)
				tickable.update(delta, eclipsed, script);
			
			combat_zone.update(delta, eclipsed, script);
			player_heart.update(delta, eclipsed, script);

			BattleMenuUpdate(delta, eclipsed);
			MenuBoneUpdate(delta, eclipsed);
			SansShakeUpdate(delta, eclipsed);
			SansNPCUpdate(delta, eclipsed);
			PlayerDamageUpdate(delta, eclipsed);
			HPBarUpdate(delta, eclipsed);
		}
		
		public function RemoveTickable(object:Sprite):void  {
			if(object.parent != null)
				object.parent.removeChild(object);
				
			(object as ISansTickable).destroy();
			
			var index:int = tickables.indexOf(object);
			if (index > -1) {
				tickables.splice(index, 1);
			}
		}
		
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/* #region Sound */
		// Import Sounds - They only get included if you reference them.
		soundSansBattleText;
		soundSansBoneStab;
		soundSansDing;
		soundSansFlash;
		soundSansGasterBlast;
		soundSansGasterBlast2;
		soundSansGasterBlaster;
		soundSansPlayerDamaged;
		soundSansPlayerFight;
		soundSansPlayerHeal;
		soundSansSlam;
		soundSansWarning;
		soundSansSansSpeak;
		soundSansMenuSelect;
		soundSansMenuCursor;
		soundSansHeartSplit;
		soundSansHeartShatter;

		public function PlaySound(sound:String, rate:Number = 1, tag:String = ""):void { // Real Method: Sound
			// Music Handler
			if(sound == "Music")
			{
				if(!bg_music)
					bg_music = (script.gameplay.getScriptVariable("song") as Song).getSoundObject();

				bg_music_channel = bg_music.play(0, 1);
				bg_music_channel.addEventListener(Event.SOUND_COMPLETE, musicCompleteHandler);
				return;
			}

			// Cache Class Lookup
			var findClass:Class;
			if (!soundCache[sound])
			{
				try {
					
					findClass = getDefinitionByName("ext.scripts::soundSans" + sound) as Class;
					soundCache[sound] = findClass;
				} catch (e:Error) {
					trace("3:Missing Sound File: " + sound);
					return;
				}
			}
			else
			{
				findClass = soundCache[sound];
			}

			var snd:SansSoundObject = new SansSoundObject(findClass, sound, rate);
			
			if (tag != "")
				soundTags[tag] = snd;
		}

		private function musicCompleteHandler(e:Event):void {
			bg_music_time = 0;
			bg_music_channel.stop();
			bg_music_channel.removeEventListener(Event.SOUND_COMPLETE, musicCompleteHandler);
			bg_music_channel = bg_music.play(0, 1);
			bg_music_channel.addEventListener(Event.SOUND_COMPLETE, musicCompleteHandler);
		}

		public function IsAudioPlaying(tag:String):Boolean {
			if(tag == "Music") return bg_music_channel != null;
			return soundTags[tag] != null && (soundTags[tag] as SansSoundObject).isPlaying;
		}
		
		public function StopAudio(tag:String):void {
			if(tag == "Music")
			{
				bg_music_time = 0;
				bg_music_channel.stop();
				bg_music_channel.removeEventListener(Event.SOUND_COMPLETE, musicCompleteHandler);
				bg_music_channel = null;
			}
			else if (soundTags[tag] != null)
			{
				(soundTags[tag] as SansSoundObject).stop();
				delete soundTags[tag];
			}
		}

		public function PauseAudio(tag:String):void {
			if(tag == "Music")
			{
				if(bg_music_channel != null)
				{
					bg_music_time = bg_music_channel.position;
					bg_music_channel.stop();
					bg_music_channel.removeEventListener(Event.SOUND_COMPLETE, musicCompleteHandler);
					bg_music_channel = null;
				}
			}
			else if (soundTags[tag] != null)
				(soundTags[tag] as SansSoundObject).pause();
		}

		public function ResumeAudio(tag:String):void {
			if(tag == "Music")
				if(bg_music_channel == null && bg_music != null)
				{
					bg_music_channel = bg_music.play(bg_music_time, 1);
					bg_music_channel.addEventListener(Event.SOUND_COMPLETE, musicCompleteHandler);
				}

			else if (soundTags[tag] != null)
				(soundTags[tag] as SansSoundObject).resume();
		}

		public function StopAudioAll():void {
			if(bg_music_channel != null)
			{
				bg_music_time = 0;
				bg_music_channel.stop();
				bg_music_channel.removeEventListener(Event.SOUND_COMPLETE, musicCompleteHandler);
				bg_music_channel = null;
			}
			for each (var tag:SansSoundObject in soundTags)
				tag.stop();
			
			soundTags = {};
		}
		/* #endregion */


		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		//Polyfill Passthoughs
		public function SansSlamDamage(enabled:int):void { player_heart.SansSlamDamage(enabled); }
		public function SansSlam(dir:int):void  { player_heart.SansSlam(dir); }
		public function HeartMode(mode:int):void  { player_heart.HeartMode(mode); }
		public function HeartTeleport(x:Number, y:Number):void  { player_heart.HeartTeleport(x, y); }
		public function HeartMaxFallSpeed(speed:int):void  { player_heart.HeartMaxFallSpeed(speed); }
		public function HeartCheckSolid(tx:Number, ty:Number):Boolean  { return player_heart.HeartCheckSolid(tx, ty); }
		public function HeartJump():void  { player_heart.HeartJump(); }
		
		public function SansText(text:String, EndFunc:String = "EndSansText"):void {
			SansBubble.x = SansNPCLegs.x + 64;
			SansBubble.y = SansNPCLegs.y - 128;
			layer_enemies.addChild(SansBubble);

			var SansTextfield:SansRPGText = new SansRPGText(this, SansRPGText.SANS_TEXT);
			SansTextfield.x = SansBubble.x + 32;
			SansTextfield.y = SansBubble.y + 16;
			SansTextfield.setSize(256, 64);
			SansTextfield.text = "";
			SansTextfield.Voice = "SansSpeak";
			SansTextfield.FullText = text;
			SansTextfield.Interactive = true;
			SansTextfield.EndFunc = EndFunc;

			if(EndFunc == "GameStart2")
				SansTextfield.ShowTutorial = true;
				
			layer_enemies.addChild(SansTextfield);
			TLPause();
			tickables[tickables.length] = SansTextfield;
		}

		public function EndSansText():void
		{
			SansBubble.parent.removeChild(SansBubble);
			TLResume();
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/* #region Attacks */
		public function RunAttack(attack_name:String):void {
			TLPlay(SansAttacksJSON[attack_name]);
		}
		
		public function StartAttack():void {
			player_heart.CustomMovement.Disabled = false;
			player_heart.CustomMovement.speed = 0;
			ResetVars();
			MenuBonesOff();
			
			if(HitAttempts < 13) {
				if(NextAttack == 0) { RunAttack("sans_intro"); NextAttack++; }
				else if(NextAttack == 1) { RunAttack("sans_bonegap1"); NextAttack++; }
				else if(NextAttack == 2) { RunAttack("sans_bluebone"); NextAttack++; }
				else if(NextAttack == 3) { RunAttack("sans_bonegap2"); NextAttack++; }
				else if(NextAttack == 4) { RunAttack("sans_platforms1"); NextAttack++; }
				else if(NextAttack == 5) { RunAttack("sans_platforms2"); NextAttack++; }
				else if(NextAttack == 6) { RunAttack("sans_platforms3"); NextAttack++; }
				else if(NextAttack == 7) { RunAttack("sans_platforms4"); NextAttack++; }
				else if(NextAttack == 8) { RunAttack("sans_platformblaster"); NextAttack++; }
				else if(NextAttack == 9) { RunAttack("sans_platforms4hard"); NextAttack++; }
				else if(NextAttack == 10) { RunAttack("sans_bonegap1fast"); NextAttack++; }
				else if(NextAttack == 11) { RunAttack("sans_boneslideh"); NextAttack++; }
				else if(NextAttack == 12) { RunAttack("sans_bonegap2"); NextAttack++; }
				else if(NextAttack == 13) { RunAttack("sans_platformblasterfast"); NextAttack++; }
				else if(NextAttack == 14) { RunAttack(ArrayUtil.randomize(["sans_bonegap1fast","sans_bonegap2", "sans_boneslideh", "sans_platformblasterfast"])[0]); }
			}
			else if(HitAttempts == 13) {
				RunAttack("sans_spare");
				SansSweat(2);
				NextAttack = 0;
				PauseAudio("Music");
			}
			else if(HitAttempts > 13 && HitAttempts <= 22) {
				if(NextAttack == 0) { RunAttack("sans_multi1"); NextAttack++; }
				else if(NextAttack == 1) { RunAttack("sans_randomblaster1"); NextAttack++; }
				else if(NextAttack == 2) { RunAttack("sans_multi2"); NextAttack++; }
				else if(NextAttack == 3) { RunAttack("sans_bonestab1"); NextAttack++; }
				else if(NextAttack == 4) { RunAttack("sans_bonestab2"); NextAttack++; }
				else if(NextAttack == 5) { RunAttack("sans_randomblaster2"); NextAttack++; }
				else if(NextAttack == 6) { RunAttack("sans_boneslidev"); NextAttack++; }
				else if(NextAttack == 7) { RunAttack("sans_multi3"); NextAttack++; }
				else if(NextAttack == 8) { RunAttack("sans_bonestab3"); NextAttack++; }
				else if(NextAttack == 9) { RunAttack(ArrayUtil.randomize(["sans_bonestab3", "sans_multi3", "sans_randomblaster2"])[0]); }
			}
			else if(HitAttempts > 22) {
				RunAttack("sans_final");
			}
		}
		
		public function EndAttack():void {
			while (tickables.length > 0)
				RemoveTickable(tickables[0]);
			
			BattleMenuEnabled(1);

			player_heart.visible = true;
			player_heart.CustomMovement.Disabled = true;
			
			ResetVars();

			SansAnimation("Idle");
			SansNPCHead.Animation("Default");
			SansNPCTorso.Animation("Default");

			if(player_heart.KR >= 0)
				combat_zone.InfoText = "* You felt your sins crawling \n  on your back.";

			if(HitAttempts < 13 && NextAttack == 1) {
				combat_zone.InfoText = "* You feel like you're going to \n  have a bad time.";
				if(!IsAudioPlaying("Music"))
					PlaySound("Music");
			}
			if(HitAttempts != 13) {
				ResumeAudio("Music");
			}

			if(HitAttempts == 13)	combat_zone.InfoText = "* Sans is taking a break.";
			if(HitAttempts == 15)	combat_zone.InfoText = "* The REAL battle finally begins.";
			if(HitAttempts == 19)	combat_zone.InfoText = "* Reading this doesn't seem \n  like the best use of time.";
			if(HitAttempts == 20)	combat_zone.InfoText = "* Sans is starting to look\n  really tired.";
			if(HitAttempts == 21)	combat_zone.InfoText = "* Sans is preparing something.";
			if(HitAttempts == 22)	combat_zone.InfoText = "* Sans is pregetting ready to\n  use his special attack.";

			if(HitAttempts > 22) {
				BattleMenuEnabled(0);
				CombatZoneResize(combat_zone.TargetLeft, combat_zone.TargetTop, combat_zone.TargetRight, combat_zone.TargetBottom);
				SansAnimation("Tired");
				SansNPCHead.Animation("Tired2");
				StopAudioAll();
				SansText("huff... puff...", "Win1");
			}

			if(HitAttempts > 13 && HitAttempts != 16 && HitAttempts != 17 && HitAttempts <= 22)
				MenuBoneLeft();

			if(HitAttempts > 15 && HitAttempts <= 22)
				MenuBoneBottom();

		}
		
		public function BlackScreen(is_black:int):void {
			if (is_black != 0)
			{
				layer_overlay.alpha = 1;
				
				PauseAudio("Music");
				
				while (tickables.length > 0)
					RemoveTickable(tickables[0]);
			}
			else {
				layer_overlay.alpha = 0;
				ResumeAudio("Music");
			}
		}
		
		public function ResetVars():void {
			CombatZoneSpeed(480);
			HeartMode(player_heart.Mode);
			HeartMaxFallSpeed(750);
			SansSlamDamage(0);
			
			SansNPCLegs.XSpeed = 0;
			SansNPCLegs.x = 320;
		}

		public function GameStart2():void {
			if(LevelSkipped) {
				SansText("ready..?", "GameStart9Skipped");
			}
			else {
				SansText("kinda strange this\nis happening", "GameStart3");
				SansNPCHead.Animation("Default");
			}
		}

		public function GameStart3():void {
			SansText("wasn't expecting\nyou here", "GameStart4");
		}

		public function GameStart4():void {
			if(PiesEatten <= 0)
				EndSansText(); //SansText("you didn't even use\nany of those pies"); // Advance Timeline
			else if(PiesEatten == 1)
				SansText("good thing you had a\nButterscotch Pie.", "GameStart5");
			else 
				SansText("good thing you had\n" + PiesEatten + " pies handy", "GameStart5");
		}

		public function GameStart5():void {
			SansText("or my job would\nhave already been\ndone"); // Advance Timeline
		}

		public function GameStart6():void {
			SansText("since you're here, \nwhy don't we play a\ndifferent game", "GameStart7");
		}

		public function GameStart7():void {
			SansText("you might even\nget something", "GameStart8");
		}

		public function GameStart8():void {
			SansNPCHead.Animation("NoEyes");
			SansText("if you survive", "GameStart9");
		}

		public function GameStart9():void {
			SansText("ready..?");
		}

		public function GameStart9Skipped():void {
			JMPREL(5);
			EndSansText();
		}

		public function Win1():void {
			SansText("alright, i guess\nyou win", "Win2");
		}

		public function Win2():void {
			SansText("i suppose you'll\nwant something", "Win3");
		}

		public function Win3():void {
			SansText("have this badge\nor something...", "Win4");
		}

		public function Win4():void {
			script.doCaseEvent(2);
		}
		/* #endregion */

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/* #region BattleMenu */
		public var MenuStack:Array = [[0, ""]];

		public var MenuState:int = 0;
		public var MenuTarget:SansMenuTarget;
		public var MenuTargetChoice:SansMenuTargetChoice;

		public function MenuBackAction(action:String):void {
			MenuStack[MenuStack.length - 1][1] = action;
		}

		public function MenuSelect(direction:int):void {
			trace("MenuSelect(", direction, ")");
			var item:SansMenuItem;
			var CurItem:SansMenuItem;

			var TargetID:int = -1;
			var TargetDist:int = 2147483647;

			var menuitems:Array = SansMenuItem.ITEMS;
			for each(item in SansMenuItem.ITEMS)
			{
				if(item.ID == MenuStack[MenuStack.length - 1][0])
				{
					CurItem = item;
					break;
				}
			}

			if(!CurItem)
			{
				trace("MenuSelect: Unable to find MenuItem");
				return;
			}

			var A:Number, B:Number;
			var Ang:Number = 0;
			var Dist:Number = 0;
			
			// Find Nearest
			for each(item in SansMenuItem.ITEMS)
			{
				if(CurItem.ID == item.ID)
					continue;

				Ang = (((Math.atan2(item.y - CurItem.y, item.x - CurItem.x)) * 180 / Math.PI) + 360) % 360;
				if(Math.abs(Ang - (direction * 90)) < 0.5)
				{
					A = item.x - CurItem.x;
					B = item.y - CurItem.y;
					Dist = Math.sqrt(A * A + B * B);

					if(Dist < TargetDist)
					{
						TargetDist = Dist;
						TargetID = item.ID;
					}
				}
			}

			// Wrap Direction, find farest.
			if(TargetID == -1)
			{
				TargetDist = -2147483647;

				// Look Up / Down Direction
				for each(item in SansMenuItem.ITEMS)
				{
					if(CurItem.ID == item.ID)
						continue;

					Ang = (((Math.atan2(item.y - CurItem.y, item.x - CurItem.x)) * 180 / Math.PI) + 360) % 360;

					if((Math.abs(Ang - (direction * 90 - 180)) % 360) < 0.5)
					{
						A = item.x - CurItem.x;
						B = item.y - CurItem.y;
						Dist = Math.sqrt(A * A + B * B);

						if(Dist > TargetDist)
						{
							TargetDist = Dist;
							TargetID = item.ID;
						}
					}
				}
			}

			if(TargetID != -1)
			{
				MenuStack[MenuStack.length - 1][0] = TargetID;
				PlaySound("MenuCursor");
			}
		}

		public function RunMenu():void {
			// Inputs
			if(script.vpad.Confirm > script.vpad.LastConfirm)
			{
				for each(var item:SansMenuItem in SansMenuItem.ITEMS)
				{
					if(item.ID == MenuStack[MenuStack.length - 1][0] && item.Action != "")
					{
						MenuStack.push([0, ""]);
						this[item.Action]();
						PlaySound("MenuSelect");
						break;
					}
				}
			}
			else if(script.vpad.Cancel > script.vpad.LastCancel && MenuStack[MenuStack.length - 1][1] != "")
			{
				var FuncName:String = MenuStack[MenuStack.length - 1][1];
				MenuStack.pop();
				this[FuncName]();
				PlaySound("MenuSelect");
			}
			else if(script.vpad.R > script.vpad.LastR)
				MenuSelect(0);
			else if(script.vpad.D > script.vpad.LastD)
				MenuSelect(1);
			else if(script.vpad.L > script.vpad.LastL)
				MenuSelect(2);
			else if(script.vpad.U > script.vpad.LastU)
				MenuSelect(3);
		}

		public function CreateMenuItem(layer:String, X:Number, Y:Number, ID:int, Text:String, Action:String):int {
			var MI:SansMenuItem = new SansMenuItem();
			MI.x = X;
			MI.y = Y;
			MI.ID = ID;
			MI.Text = Text;
			MI.Action = Action;
			MI.name = "Menu" + MI.ID;

			if(Action == "")
				MI.transform.colorTransform = new ColorTransform(0.5, 0.5, 0.5);

			if(layer == "CombatZone")
				layer_combat_zone.addChild(MI);
			else
				layer_buttons.addChild(MI);

			return MI.UID;
		}

		public function BattleMenuUpdate(delta:Number, eclipsed:Number):void {
			// Target
			if(MenuTarget != null)
			{
				if(MenuTarget.State == 0)
				{
					MenuTargetChoice.x = MenuTargetChoice.x + Math.cos(deg2rad(MenuTargetChoice.Direction * 90)) * eclipsed * 360;

					if((MenuTargetChoice.Direction == 0 && MenuTargetChoice.x > combat_zone.TargetRight) ||
					(MenuTargetChoice.Direction == 2 && MenuTargetChoice.x < combat_zone.TargetLeft)) {
						MenuTargetChoice.destroy();
						MenuTarget.State = 2;
						var MissText:SansRPGText = new SansRPGText(myself, SansRPGText.DAMAGE_TEXT);
						MissText.x = 272;
						MissText.y = 50;
						MissText.text = "MISS";
						MissText.Timeout = 1.5;
						MissText.setSize(300, 50);
						MissText.transform.colorTransform = new ColorTransform(0.75, 0.75, 0.75);
						layer_enemies.addChild(MissText);
						tickables[tickables.length] = MissText;
						StartAttack();
					}
					else if(script.vpad.Confirm > script.vpad.LastConfirm)
					{
						MenuTarget.State = 1;
						MenuTargetChoice.Animation("Flash");

						var AttackSprite:SansStrike = new SansStrike();
						AttackSprite.scaleX = AttackSprite.scaleY = 1.5;
						AttackSprite.x = SansNPCLegs.x;
						AttackSprite.y = SansNPCLegs.y - 96;
						layer_enemies.addChild(AttackSprite);

						PlaySound("PlayerFight");
						DodgeState = 1;
					}
				}
				if(MenuTarget.State == 2)
				{
					MenuTarget.width -= eclipsed * 960;
					MenuTarget.alpha -= eclipsed * 2.4;

					if(MenuTarget.alpha < 0)
						MenuTarget.destroy();
				}
			}
			// Menu States
			var menuItem:SansMenuItem;
			var uiButton:SansBattleMenuButton;

			if(MenuState >= 2)
				RunMenu();

			if(MenuState == 3 && MenuStack[0][0] == menu_group.btnItem.ID)
			{
				var moveX:int = 0;
				for each(menuItem in SansMenuItem.ITEMS)
				{
					if(MenuStack[MenuStack.length - 1][0] == menuItem.ID)
					{
						if(menuItem.x > 640)
							moveX = -640;
						if(menuItem.x < 0)
							moveX = 640;
						
						break;
					}
				}

				for each(menuItem in SansMenuItem.ITEMS)
				{
					menuItem.x += moveX;
				}

				for each(var rpgtext:SansRPGText in SansRPGText.ITEMS)
				{
					if(rpgtext.name == "Page")
					{
						rpgtext.text = "PAGE " + (Math.floor(MenuStack[MenuStack.length - 1][0] / 4) + 1);
						break;
					}
				}
			}

			if(MenuState == 0)
				for each(uiButton in menu_group.UIButtons)
					uiButton.gfx.gotoAndStop(1);

			if(MenuState == 1)
				for each(uiButton in menu_group.UIButtons)
				{
					if(MenuStack[MenuStack.length - 1][0] == uiButton.ID)
					{
						player_heart.x = uiButton.HeartPointX();
						player_heart.y = uiButton.HeartPointY();
						break;
					}
				}

			if(MenuState == 2)
				for each(uiButton in menu_group.UIButtons)
				{
					uiButton.gfx.gotoAndStop(1);
					if(MenuStack[MenuStack.length - 1][0] == uiButton.ID)
					{
						player_heart.x = uiButton.HeartPointX();
						player_heart.y = uiButton.HeartPointY();
						uiButton.gfx.gotoAndStop(2);
					}
				}

			if(MenuState == 3)
				for each(menuItem in SansMenuItem.ITEMS)
				{
					if(MenuStack[MenuStack.length - 1][0] == menuItem.ID)
					{
						player_heart.x = menuItem.x + 8;
						player_heart.y = menuItem.y + 12;
						break;
					}
				}
		}

		public function BattleMenuEnabled(enabled:int):void {
			trace("BattleMenuEnabled");
			if (enabled != 0)
			{
				MenuStack = [[0, ""]];
				MenuState = 1;
				CombatZoneResize(33, 251, 608, 391, "MenuBattle");
			}
			else {
				MenuState = 0;
			}
		}
		
		public function MenuBattle():void {
			trace("MenuBattle");
			SansMenuItem.clear();
			SansRPGText.clear();
			
			MenuBackAction("");
			MenuState = 2;

			var InfoText:SansRPGText = new SansRPGText(this, SansRPGText.DEFAULT_TEXT);
			InfoText.x = 48;
			InfoText.y = 272;
			InfoText.setSize(544, 96);
			InfoText.text = "";
			InfoText.FullText = combat_zone.InfoText;
			InfoText.name = "InfoText";
			tickables[tickables.length] = InfoText;
			layer_combat_zone.addChild(InfoText);

			for each(var menubutton:SansBattleMenuButton in menu_group.UIButtons)
			{
				var MI:SansMenuItem = new SansMenuItem();
				MI.x = menubutton.x;
				MI.y = menubutton.y;
				MI.ID = menubutton.ID;
				MI.Action = menubutton.Action;
				MI.Created = true;
				layer_buttons.addChild(MI);
			}
		}

		public function MenuEnemyList():void {
			trace("MenuEnemyList");
			var Action:String = "";
			if(MenuStack[0][0] == menu_group.btnAttack.ID)
				Action = "MenuFightEnemy";
			if(MenuStack[0][0] == menu_group.btnAct.ID)
				Action = "MenuActEnemy";
			
			CreateMenuItem("CombatZone", 64, 272, 0, "* Sans", Action);
		}

		public function MenuFight():void {
			trace("MenuFight");
			SansMenuItem.clear();
			SansRPGText.clear();
			MenuBackAction("MenuBattle");
			MenuState = 3;
			MenuEnemyList();
		}

		public function MenuFightEnemy():void {
			trace("MenuFightEnemy");
			SansMenuItem.clear();
			SansRPGText.clear();
			MenuState = 0;
			player_heart.visible = false;

			// Target
			MenuTarget = new SansMenuTarget();
			MenuTarget.x = 320;
			MenuTarget.y = 320;
			layer_combat_zone.addChild(MenuTarget);
			

			// Target Choice
			MenuTargetChoice = new SansMenuTargetChoice();
			MenuTargetChoice.y = 320;
			if(Math.random() >= 0.5)
			{
				MenuTargetChoice.x = combat_zone.TargetLeft;
				MenuTargetChoice.Direction = 0;
			}
			else
			{
				MenuTargetChoice.x = combat_zone.TargetRight;
				MenuTargetChoice.Direction = 2;
			}
			layer_combat_zone.addChild(MenuTargetChoice);

			// Move Menu Bone Left to top layer.
			if(menuBoneL != null)
				addChild(menuBoneL);
		}

		public function MenuAct():void {
			trace("MenuAct");
			SansMenuItem.clear();
			SansRPGText.clear();
			MenuBackAction("MenuBattle");
			MenuState = 3;
			MenuEnemyList();
		}

		public function MenuActEnemy():void {
			trace("MenuActEnemy");
			SansMenuItem.clear();
			SansRPGText.clear();
			MenuBackAction("MenuAct");
			MenuState = 3;
			CreateMenuItem("CombatZone", 64, 272, 0, "* Check", "MenuCheckSans");
		}

		public function MenuCheckSans():void {
			trace("MenuCheckSans");
			SansMenuItem.clear();
			SansRPGText.clear();
			MenuState = 0;

			var CheckText:SansRPGText = new SansRPGText(this, SansRPGText.DEFAULT_TEXT);
			CheckText.x = 48;
			CheckText.y = 272;
			CheckText.setSize(544, 96);
			CheckText.text = "";
			CheckText.FullText = "* SANS 1 ATK 1 DEF\n* The easiest enemy.\n* Can only deal 1 damage.";
			CheckText.EndFunc = "StartAttack";
			CheckText.Interactive = true;
			player_heart.visible = false;
			tickables[tickables.length] = CheckText;
			layer_combat_zone.addChild(CheckText);

			if(HitAttempts > 0)
				CheckText.EndFunc = "MenuCheckSans2";
		}

		public function MenuCheckSans2():void {
			trace("MenuCheckSans2");
			var CheckText:SansRPGText = new SansRPGText(this, SansRPGText.DEFAULT_TEXT);
			CheckText.x = 48;
			CheckText.y = 272;
			CheckText.setSize(544, 96);
			CheckText.text = "";
			CheckText.FullText = "* Can't keep dodging forever.\n* Keep attacking.";
			CheckText.EndFunc = "StartAttack";
			CheckText.Interactive = true;
			tickables[tickables.length] = CheckText;
			layer_combat_zone.addChild(CheckText);
		}

		public function MenuItem():void {
			trace("MenuItem");
			var nX:int = 0;
			var nY:int = 0;
			var nText:String = "";

			SansMenuItem.clear();
			SansRPGText.clear();
			MenuBackAction("MenuBattle");
			MenuState = 3;

			var page:int = 0;
			if(PlayerItems.length > 0)
			{
				for(var i:int = 0; i < PlayerItems.length; i++)
				{
					page = Math.floor(i / 4);
					nX = 64 + (640 * page) + ((i % 2) * 256);
					nY = 272 + Math.floor((i % 4) / 2) * 32;
					nText = "* " + ItemDB[PlayerItems[i]][3];
					CreateMenuItem("CombatZone", nX, nY, i, nText, "MenuUseItem");
				}
			}
			else {
				CreateMenuItem("CombatZone", 64, 272, 0, "* You have no items remaining.", "MenuBattle");
			}

			var PageText:SansRPGText = new SansRPGText(this, SansRPGText.DEFAULT_TEXT);
			PageText.name = "Page";
			PageText.Voice = "";
			PageText.text = "PAGE 1";
			PageText.x = 384;
			PageText.y = 336;
			layer_combat_zone.addChild(PageText);
		}

		public function MenuUseItem():void {
			trace("MenuUseItem");
			SansMenuItem.clear();
			SansRPGText.clear();
			player_heart.visible = false;

			var ItemSlot:int = 0;
			var ItemID:int = 0;
			
			MenuState = 0;
			ItemSlot = MenuStack[MenuStack.length - 2][0];
			ItemID = PlayerItems[ItemSlot];

			if(ItemDB[ItemID][0] == 0)
			{
				player_heart.HP += ItemDB[ItemID][1];
				PlaySound("PlayerHeal");

				var ItemText:SansRPGText = new SansRPGText(this, SansRPGText.DEFAULT_TEXT);
				ItemText.x = 48;
				ItemText.y = 272;
				ItemText.setSize(544, 96);
				ItemText.text = "";
				ItemText.FullText = "* You eat the " + ItemDB[ItemID][2] + ".\n* You recovered " + ItemDB[ItemID][1] + " HP!";
				ItemText.EndFunc = "StartAttack";
				ItemText.Interactive = true;
				player_heart.visible = false;
				tickables[tickables.length] = ItemText;
				layer_combat_zone.addChild(ItemText);

				PlayerItems.splice(ItemSlot, 1);
			}
		}

		public function MenuMercy():void {
			trace("MenuMercy");
			SansMenuItem.clear();
			SansRPGText.clear();
			MenuBackAction("MenuBattle");
			MenuState = 3;
			CreateMenuItem("CombatZone", 64, 272, 0, "* Spare", "MenuSpare");
		}

		public function MenuSpare():void {
			trace("MenuSpare");
			SansMenuItem.clear();
			SansRPGText.clear();
			player_heart.visible = false;
			MenuState = 0;
			StartAttack();
		}
		
		/* #endregion */
		
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/* #region Platforms */
		public function Platform(X:Number, Y:Number, Width:Number, Direction:int, Speed:int, Reverse:int = 0):void {
			tickables[tickables.length] = new SansPlatform(this, X, Y, Width, Direction, Speed, (Reverse > 0));
		}
		
		public function PlatformRepeat(StartX:Number, StartY:Number, Width:Number, Direction:Number, Speed:Number, Count:int, Spacing:int):void {
			for(var i:int = 0; i < Count; i++) {
				var X:Number = StartX - Math.cos(deg2rad(Direction * 90)) * Spacing * i;
				var Y:Number = StartY - Math.sin(deg2rad(Direction * 90)) * Spacing * i;
				tickables[tickables.length] = new SansPlatform(this, X, Y, Width, Direction, Speed);
			}
		}

		/* #endregion */

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/* #region Bones */
		public function BoneH(X:Number, Y:Number, Width:Number, Direction:int, Speed:Number, Color:int = 0):void {
			tickables[tickables.length] = new SansBoneH(this, X, Y, Width, Direction, Speed, Color);
		}
		
		public function BoneHRepeat(StartX:Number, StartY:Number, Width:Number, Direction:int, Speed:Number, Count:Number, Spacing:Number):void {
			var LX:Number = 0;
			var LY:Number = 0;
			var _rad:Number = deg2rad(Direction * 90);
			for (var i:int = 0; i < Count; i++)
			{
				LX = StartX - Math.cos(_rad) * Spacing * i;
				LY = StartY - Math.sin(_rad) * Spacing * i;
				
				BoneH(LX, LY, Width, Direction, Speed);
			}
		}
		
		public function BoneV(X:Number, Y:Number, Height:Number, Direction:int, Speed:Number, Color:int = 0):void {
			tickables[tickables.length] = new SansBoneV(this, X, Y, Height, Direction, Speed, Color);
		}
		
		public function BoneVRepeat(StartX:Number, StartY:Number, Height:Number, Direction:int, Speed:Number, Count:Number, Spacing:Number):void {
			var LX:Number = 0;
			var LY:Number = 0;
			var _rad:Number = deg2rad(Direction * 90);
			for (var i:int = 0; i < Count; i++)
			{
				LX = StartX - Math.cos(_rad) * Spacing * i;
				LY = StartY - Math.sin(_rad) * Spacing * i;
				
				BoneV(LX, LY, Height, Direction, Speed);
			}
		}
		
		public function SineBones(Count:int, Spacing:int, Speed:int, Height:int):void {
			var BBox:Rectangle = combat_zone.CombatZone.getBounds(combat_zone.CombatZone.parent);
			
			var LX:Number = BBox.left;
			var LY:Number = 0;
			var LDirection:int = 0;
			var LSine:Number = 0;
			
			if (Spacing > 0) {
				LX = BBox.right;
				LDirection = 2;
			}
			
			for (var i:int = 0; i < Count; i++)
			{
				LSine = Math.floor(Math.sin(i / 3) * 28);
				
				LY = BBox.top + 6;
				BoneV((LX + Spacing * i), LY, Height + LSine, LDirection, Speed);
				
				LY = BBox.top + 6 + Height + LSine + 39;
				BoneV((LX + Spacing * i), LY, BBox.bottom - 5 - LY, LDirection, Speed);
			}
		}

		/* #endregion */

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/* #region BoneStab */
		public function BoneStab(Direction:Number, Distance:int, WarnTime:Number, StayTime:Number):void {
			tickables[tickables.length] = new SansBoneStabWarn(this, Direction, Distance, WarnTime, StayTime);
		}
		/* #endregion */
		
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/* #region GasterBlasters */
		public function GasterBlaster(Size:int, X:Number, Y:Number, EndX:Number, EndY:Number, EndAng:int, Timer:Number, BlastTime:Number):void {
			tickables[tickables.length] = new SansGasterBlaster(this, Size, X, Y, EndX, EndY, EndAng, Timer, BlastTime);
		}

		/* #endregion */

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////```
		/* #region MenuBones */
		public var BottomBones:Number = 0;
		public var BottomBoneTimer:Number = 0;
		public var BottomBoneAlternate:Number = 0;
		public var menuBoneL:SansMenuBoneLeft;
		public var menuBoneB:Array = [];

		public function MenuBoneUpdate(delta:Number, eclipsed:Number):void {
			var boneBottom:SansMenuBoneBottom;
			var uiButtons:Array = menu_group.UIButtons;

			if(menuBoneL != null)
			{
				menuBoneL.Timer += eclipsed;
				menuBoneL.x = -30 + Math.abs(Math.sin(deg2rad(600 * menuBoneL.Timer / Math.PI))) * 105;

				if(menuBoneL.x > 64)
					menuBoneL.Timer -= eclipsed * 0.72;

				if(menuBoneL.DoDestroy && menuBoneL.x <= -8)
				{
					menuBoneL.parent.removeChild(menuBoneL);
					menuBoneL = null;
				}
			}
			
			if(BottomBones == 1)
			{
				BottomBoneTimer += eclipsed;
				if(BottomBoneTimer >= 0.6)
				{
					BottomBoneTimer -= 0.6;

					for(var i:int = 0; i < 3; i += 2)
					{
						boneBottom = new SansMenuBoneBottom();
						boneBottom.Damage = 1;
						boneBottom.Button = i + BottomBoneAlternate;
						boneBottom.x = uiButtons[boneBottom.Button].x + 110;
						boneBottom.y = CONTAINER_HEIGHT;
						layer_combat_zone.addChild(boneBottom);
						menuBoneB[menuBoneB.length] = boneBottom;
					}

					BottomBoneAlternate = BottomBoneAlternate > 0 ? 0 : 1;
				}
			}

			if(menuBoneB.length > 0)
			{
				for each(boneBottom in menuBoneB)
				{
					if(boneBottom.State == 0)
					{
						boneBottom.y -= 300 * eclipsed;
						if(boneBottom.y <= 440)
						{
							boneBottom.y = 440;
							boneBottom.State = 1;
						}
					}
					if(boneBottom.State == 1)
					{
						boneBottom.x -= 150 * eclipsed;
						if(boneBottom.x <= (uiButtons[boneBottom.Button].x - 14))
						{
							boneBottom.x = (uiButtons[boneBottom.Button].x - 14);
							boneBottom.State = 2;
						}
					}
					if(boneBottom.State == 2)
					{
						boneBottom.y += 300 * eclipsed;
						if(boneBottom.y > CONTAINER_HEIGHT)
						{
							boneBottom.parent.removeChild(boneBottom);
							var idx:int = menuBoneB.indexOf(boneBottom);
							menuBoneB.splice(idx, 1);
						}
					}
				}
			}
		}

		public function MenuBonesOff():void {
			if(menuBoneL != null)
				menuBoneL.DoDestroy = true;
			
			BottomBones = 0;
		}

		public function MenuBoneLeft():void {
			if(menuBoneL == null)
			{
				menuBoneL = new SansMenuBoneLeft();
				menuBoneL.x = -10;
				menuBoneL.y = 270;
				menuBoneL.Damage = 1;
				layer_combat_zone.addChild(menuBoneL);
			}
		}

		public function MenuBoneBottom():void {
			BottomBones = 1;
			BottomBoneTimer = 0;
			BottomBoneAlternate = 0;
		}

		/* #endregion */
		
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/* #region CombatZone */
		public function CombatZoneSpeed(spd:int):void  {
			combat_zone.CombatZoneSpeed(spd);
		}

		public function CombatZoneResize(left:Number, top:Number, right:Number, bottom:Number, callback:String = null):void {
			combat_zone.CombatZoneResize(left, top, right, bottom, callback);
		}

		public function CombatZoneResizeInstant(left:Number, top:Number, right:Number, bottom:Number):void {
			combat_zone.CombatZoneResizeInstant(left, top, right, bottom);
		}

		public function CombatZoneTick(delta:Number):void {
			combat_zone.CombatZoneTick(delta);
		}

		/* #endregion */

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/* #region SansAnimation */
		public var SansAnimationKey:String = "";
		public var DodgeState:int = 0;
		public var DodgeTimer:Number = 0;
		public var JustDodged:Boolean = false;

		public function SansAnimation(Animation:String = ""):void {
			SansNPCBody.visible = false;
			SansNPCLegs.visible = true;
			SansNPCTorso.visible = true;
			SansAnimationKey = Animation;
		}

		public function SansBody(Animation:String):void {
			SansNPCBody.visible = true;
			SansNPCLegs.visible = false;
			SansNPCTorso.visible = false;
			SansNPCBody.Animation(Animation);
		}

		public function SansTorso(Animation:String):void {
			SansNPCBody.visible = false;
			SansNPCLegs.visible = true;
			SansNPCTorso.visible = true;
			SansNPCTorso.Animation(Animation);
		}

		public function SansHead(Animation:String):void {
			SansNPCHead.Animation(Animation);
		}

		public function SansSweat(enabled:int):void {
			SansNPCSweat.visible = enabled > 0 ? true : false;
			if(enabled > 0)
				SansNPCSweat.Animation("Sweat" + enabled);
		}

		public function SansX(X:int):void {
			SansNPCLegs.x = X;
		}

		public function SansRepeat():void {
			SansNPCLegs.XSpeed = -900;
		}

		public function SansEndRepeat():void {
			SansNPCLegs.XSpeed = 0;
		}

		public function SansNPCUpdate(delta:Number, eclipsed:Number):void {
			// Movement and Wrapping
			if(SansNPCLegs.XSpeed != 0)
			{
				SansNPCLegs.y = combat_zone.getBoundsBox().y - 16;
				SansNPCLegs.x += SansNPCLegs.XSpeed * eclipsed;
				SansNPCLegs.XSpeed -= 45 * eclipsed;
				
				if(SansNPCLegs.x < -100)
				{
					SansNPCLegs.x = 740;
					SansNPCHead.Animation(ArrayUtil.randomize(["Default", "LookLeft", "Wink", "ClosedEyes", "NoEyes"])[0]);
					SansNPCTorso.Animation(ArrayUtil.randomize(["Default", "Default", "Default", "Shrug"])[0]);
				}
			}
			else {
				SansNPCLegs.y = combat_zone.TargetTop - 16;
			}

			// Dodge States
			if(DodgeState != 0)
				DodgeTimer += eclipsed;

			if(DodgeState == 1)
			{
				SansNPCLegs.x = 320 - Math.sin(deg2rad(DodgeTimer * 225)) * 100;

				if(DodgeTimer >= 0.4)
				{
					SansNPCLegs.x = 220;
					DodgeState = 2;
					DodgeTimer = 0;

					var DelayTimer:Timer = new Timer(600, 1);
					DelayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, DelayTimerComplete);
					DelayTimer.start();

					function DelayTimerComplete(e:TimerEvent):void
					{
						var MissText:SansRPGText = new SansRPGText(myself, SansRPGText.DAMAGE_TEXT);
						MissText.x = 272;
						MissText.y = 50;
						MissText.text = "MISS";
						MissText.Timeout = 1.5;
						MissText.setSize(300, 50);
						MissText.transform.colorTransform = new ColorTransform(0.75, 0.75, 0.75);
						layer_enemies.addChild(MissText);
						tickables[tickables.length] = MissText;
					}
				}
			}
			if(DodgeState == 2)
			{
				if(DodgeTimer >= 1.1)
				{
					DodgeState = 3;
					DodgeTimer = 0;
				}
			}
			if(DodgeState == 3) {
				SansNPCLegs.x = 320 - Math.cos(deg2rad(DodgeTimer * 225)) * 100;

				if(DodgeTimer >= 0.4)
				{
					SansNPCLegs.x = 320;
					DodgeState = 0;
					DodgeTimer = 0;
					HitAttempts++;
					JustDodged = true;

					MenuTargetChoice.destroy();
					MenuTarget.State = 2;
					StartAttack();
				}
			}

			// Animations
			if(SansAnimationKey != "")
			{
				SansNPCTorso.T += eclipsed;
				SansNPCHead.T += eclipsed;
			}

			if(SansAnimationKey == "Idle")
			{
				if(SansNPCTorso.T > 1.2)
					SansNPCTorso.T -= 1.2;

				if(SansNPCHead.T > 1.2)
					SansNPCHead.T -= 1.2;

				SansNPCTorso.OffsetX = Math.sin(deg2rad(360 * SansNPCTorso.T / 1.2));
				SansNPCTorso.OffsetY = Math.sin(deg2rad(720 * SansNPCTorso.T / 1.2));
				SansNPCHead.OffsetY = -Math.sin(deg2rad(720 * SansNPCHead.T / 1.2)) * 0.4;
			}

			if(SansAnimationKey == "HeadBob")
			{
				if(SansNPCHead.T > 1.1)
					SansNPCHead.T -= 1.1;

				SansNPCHead.OffsetX = Math.sin(deg2rad(360 * SansNPCHead.T / 1.1));
				SansNPCHead.OffsetY = Math.sin(deg2rad(720 * SansNPCHead.T / 1.1));
			}

			if(SansAnimationKey == "Tired")
			{
				if(SansNPCTorso.T > 3.8)
					SansNPCTorso.T -= 3.8;

				if(SansNPCHead.T > 3.8)
					SansNPCHead.T -= 3.8;

				SansNPCTorso.OffsetY = Math.sin(deg2rad(360 * SansNPCTorso.T / 3.8));
				SansNPCHead.OffsetY = Math.sin(deg2rad(360 * SansNPCHead.T / 3.8));
			}

			if(SansAnimationKey == "")
			{
				SansNPCTorso.T = 0;
				SansNPCTorso.OffsetX = 0;
				SansNPCTorso.OffsetY = 0;
				SansNPCHead.T = 0;
				SansNPCHead.OffsetX = 0;
				SansNPCHead.OffsetY = 0;
			}

			SansNPCTorso.x = SansNPCLegs.ImagePointX("Torso") + SansNPCTorso.OffsetX;
			SansNPCTorso.y = SansNPCLegs.ImagePointY("Torso") + SansNPCTorso.OffsetY;
			SansNPCBody.x = SansNPCLegs.x;
			SansNPCBody.y = SansNPCLegs.y;
			
			if(SansNPCBody.visible)
			{
				SansNPCHead.x = SansNPCBody.ImagePointX("Head");
				SansNPCHead.y = SansNPCBody.ImagePointY("Head");
			}

			if(SansNPCTorso.visible)
			{
				SansNPCHead.x = SansNPCTorso.ImagePointX("Head") + SansNPCHead.OffsetX;
				SansNPCHead.y = SansNPCTorso.ImagePointY("Head") + SansNPCHead.OffsetY;
			}

			SansNPCSweat.x = SansNPCHead.ImagePointX("Sweat");
			SansNPCSweat.y = SansNPCHead.ImagePointY("Sweat");
		}

		/* #endregion */
		
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/* #region PlayerDamage */
		public var LastDamageTime:Number = 0;

		public function pointInPolygon(nvert:int, vertx:Array, verty:Array, testx:Number, testy:Number):Boolean {
			var i:int, j:int, c:Boolean = false;
			for (i = 0, j = nvert-1; i < nvert; j = i++) {
				if ( ((verty[i]>testy) != (verty[j]>testy)) && (testx < (vertx[j]-vertx[i]) * (testy-verty[i]) / (verty[j]-verty[i]) + vertx[i]) )
					c = !c;
			}
			return c;
		}

		public function debugDrawDamagableCalc(iDamage:ISansDamageable, HGP:Point):void {
			var hb:Sprite = iDamage.getHitbox();
			var hbb:Rectangle = hb.getBounds(hb);
			var HB1:Array = [hbb.x, hbb.x + hb.width];
			var HB2:Array = [hbb.y, hbb.y + hb.height];
			var RES:Array = [];

			for(var ny:int = 0; ny < 2; ny++) {
				for(var nx:int = 0; nx < 2; nx++) {
					SCRATCH.x = HB1[nx] / hb.scaleX;
					SCRATCH.y = HB2[ny] / hb.scaleY;
					RES[RES.length] = hb.localToGlobal(SCRATCH);
				}
			}

			debugDrawDamagable(RES, HGP);
		}

		public function debugDrawDamagable(RES:Array, HGP:Point):void {
			var drawBox:Shape = new Shape();
			drawBox.graphics.lineStyle(1, (Math.random() * 0xffffff), 1);
			drawBox.graphics.moveTo(RES[0].x, RES[0].y);
			drawBox.graphics.lineTo(RES[1].x, RES[1].y);
			drawBox.graphics.lineTo(RES[3].x, RES[3].y);
			drawBox.graphics.lineTo(RES[2].x, RES[2].y);
			drawBox.graphics.lineTo(RES[0].x, RES[0].y);

			drawBox.graphics.lineStyle(1, (Math.random() * 0xffffff), 0.1);
			drawBox.graphics.drawRect(HGP.x - 2, HGP.y - 2, 4, 4);
			stage.addChild(drawBox);
		}

		public function DamagePlayerTickable(enemy:ISansDamageable):void {
			DamagePlayer(enemy.getDamage(), enemy.getKarma());			
			if(enemy.getKarma() >= 3)
				enemy.setKarma(2);
		}

		public function DamagePlayer(sHP:int, sKR:int):void {
			LastDamageTime = getTimer();
			player_heart.HP -= sHP;
			player_heart.KR += sKR;
			PlaySound("PlayerDamaged");
		}

		public function PlayerDamageUpdate(delta:Number, eclipsed:Number):void {
			SCRATCH.x = 0;
			SCRATCH.y = 0;
			var HGP:Point = player_heart.hitbox.localToGlobal(SCRATCH);
			var iDamage:ISansDamageable;

			if(LastDamageTime < getTimer() - 33)
			{
				// Check Tickables for Damage Items
				tickLoop: for each(var tickable:ISansTickable in tickables)
				{
					if(tickable is ISansDamageable)
					{
						iDamage = tickable as ISansDamageable; 

						if(iDamage.getDamage() <= 0)
							continue;

						if(tickable is SansGasterBlaster && (tickable as SansGasterBlaster).Angled)
						{
							var hb:Sprite = iDamage.getHitbox();
							var HB1:Array = [0, hb.width];
							var HB2:Array = [-(hb.height / 2), -(hb.height / 2) + hb.height];
							var RES:Array = [];

							for(var ny:int = 0; ny < 2; ny++) {
								for(var nx:int = 0; nx < 2; nx++) {
									SCRATCH.x = HB1[nx] / hb.scaleX;
									SCRATCH.y = HB2[ny] / hb.scaleY;
									RES[RES.length] = hb.localToGlobal(SCRATCH);
								}
							}

							var XPOINTS:Array = [RES[0].x, RES[1].x, RES[3].x, RES[2].x];
							var YPOINTS:Array = [RES[0].y, RES[1].y, RES[3].y, RES[2].y];

							if(pointInPolygon(4, XPOINTS, YPOINTS, HGP.x - 2, HGP.y - 2))
							{
								//drawDamagable(RES, HGP);
								DamagePlayerTickable(iDamage);
								break tickLoop;
							}
						}
						else if(iDamage.getHitbox().hitTestObject(player_heart.hitbox))
						{
							if(iDamage.getColor() == 1) // Blue, damage if moving.
							{
								if(player_heart.CustomMovement.dx != 0 || player_heart.CustomMovement.dy != 0)
								{
									//drawDamagableCalc(iDamage, HGP);
									DamagePlayerTickable(iDamage);
									break tickLoop;
								}
							}
							else
							{
								//drawDamagableCalc(iDamage, HGP);
								DamagePlayerTickable(iDamage);
								break tickLoop;
							}
						}
					}
				}

				// Menu Bones - Left
				if(menuBoneL != null && player_heart.visible)
				{
					if(menuBoneL.getDamage() > 0 && menuBoneL.getHitbox().hitTestObject(player_heart.hitbox))
					{
						DamagePlayerTickable(menuBoneL);

						if(player_heart.HP <= 0)
							player_heart.HP = 1;
					}
				}

				// Menu Bones - Bottom
				if(menuBoneB.length > 0 && player_heart.visible)
				{
					for each(var boneBottom:SansMenuBoneBottom in menuBoneB)
					{
						if(boneBottom.getDamage() > 0 && boneBottom.getHitbox().hitTestObject(player_heart.hitbox))
						{
							DamagePlayerTickable(boneBottom);

							if(player_heart.HP <= 0)
								player_heart.HP = 1;
						}
					}
				}

				// Decay Health + Karma
				if(player_heart.KR > 40) player_heart.KR = 40;
				if(player_heart.KR >= player_heart.HP) player_heart.KR = player_heart.HP - 1;

				if(player_heart.KR > 0 && player_heart.HP > 1)
				{
					player_heart.KR_T += eclipsed;

					if(player_heart.KR >= 40 && player_heart.KR_T >= 0.033)
					{
						player_heart.KR -= 1;
						player_heart.HP -= 1;
						player_heart.KR_T = 0;
					}
					if(player_heart.KR >= 30 && player_heart.KR_T >= 0.066)
					{
						player_heart.KR -= 1;
						player_heart.HP -= 1;
						player_heart.KR_T = 0;
					}
					if(player_heart.KR >= 20 && player_heart.KR_T >= 0.166)
					{
						player_heart.KR -= 1;
						player_heart.HP -= 1;
						player_heart.KR_T = 0;
					}
					if(player_heart.KR >= 10 && player_heart.KR_T >= 0.5)
					{
						player_heart.KR -= 1;
						player_heart.HP -= 1;
						player_heart.KR_T = 0;
					}
					if(player_heart.KR_T >= 1)
					{
						player_heart.KR -= 1;
						player_heart.HP -= 1;
						player_heart.KR_T = 0;
					}
				}

				// Cap Health
				if(player_heart.HP > player_heart.MaxHP)
					player_heart.HP = player_heart.MaxHP;

				//if(player_heart.HP < 5)
				//	player_heart.HP = 90;

				// Kill Player
				if(player_heart.HP <= 0 && player_heart.Mode >= 0)
				{
					player_heart.HeartMode(0);
					player_heart.Mode = -1;
					player_heart.CustomMovement.Disabled = true;
					player_heart.parent.removeChild(player_heart);
					layer_overlay.addChild(player_heart);

					TLStop();
					BlackScreen(1);
					StopAudioAll();

					var DelayTimer:Timer = new Timer(600, 1);
					DelayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, DelayTimerCompleteA);
					DelayTimer.start();

					function DelayTimerCompleteA(e:TimerEvent):void
					{
						PlaySound("HeartSplit");
						player_heart.Animation("Split");
						var DelayTimer:Timer = new Timer(1300, 1);
						DelayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, DelayTimerCompleteB);
						DelayTimer.start();
					}

					function DelayTimerCompleteB(e:TimerEvent):void
					{
						player_heart.visible = false;
						PlaySound("HeartShatter");

						for(var i:int = 0; i < 6; i++)
							tickables[tickables.length] = new SansHeartShard(myself, player_heart);

						SansRPGText.DEFAULT_TEXT.size = 20;
						var HintText:SansRPGText = new SansRPGText(myself, SansRPGText.DEFAULT_TEXT);
						HintText.x = 0;
						HintText.y = CONTAINER_HEIGHT - 120;
						HintText.setSize(CONTAINER_WIDTH, 196);
						HintText.text = "";
						HintText.FullText = "* You can use this during the level to skip it:\nUP, UP, DOWN, DOWN, LEFT, RIGHT, LEFT, RIGHT, ENTER";
						HintText.EndFunc = "PlayerDeathExit";
						HintText.Interactive = true;
						tickables[tickables.length] = HintText;
						layer_overlay.addChild(HintText);
						SansRPGText.DEFAULT_TEXT.size = 24;
					}
				}
			}
		}

		public function PlayerDeathExit():void {
			script.doCaseEvent(3);
		}

		/* #endregion */
		
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/* #region HPBar */
		public var HPBackground:Sprite;
		public var HPBar:Sprite;
		public var KRBar:Sprite;
		public var HPText:TextField;
		public var PlayerNameBD:Bitmap;

		public function HPBarCreate():void {
			HPBackground = new Sprite();
			HPBackground.x = 256;
			HPBackground.y = 400;
			HPBackground.graphics.lineStyle(0, 0, 0);
			HPBackground.graphics.beginFill(0xbf0000);
			HPBackground.graphics.drawRect(0, 0, 110, 21);
			HPBackground.graphics.endFill();
			HPBackground.alpha = 0;
			layer_background.addChild(HPBackground);

			HPBar = new Sprite();
			HPBar.graphics.lineStyle(0, 0, 0);
			HPBar.graphics.beginFill(0xffff00);
			HPBar.graphics.drawRect(0, 0, 16, 21);
			HPBar.graphics.endFill();
			HPBar.alpha = 0;
			layer_background.addChild(HPBar);

			KRBar = new Sprite();
			KRBar.graphics.lineStyle(0, 0, 0);
			KRBar.graphics.beginFill(0xff00ff);
			KRBar.graphics.drawRect(0, 0, 16, 21);
			KRBar.graphics.endFill();
			KRBar.alpha = 0;
			layer_background.addChild(KRBar);

			HPBar.x = KRBar.x = HPBackground.x;
			HPBar.y = KRBar.y = HPBackground.y;

			PlayerNameBD = new Bitmap(new SansPlayerNameBD());
			PlayerNameBD.x = 32;
			PlayerNameBD.y = 406;
			PlayerNameBD.alpha = 0;
			layer_background.addChild(PlayerNameBD);

			HPText = new TextField();
			HPText.x = 414;
			HPText.y = 401;
			HPText.alpha = 0;
            HPText.embedFonts = true;
            HPText.wordWrap = true;
			HPText.multiline = true;
			HPText.antiAliasType = AntiAliasType.ADVANCED;
			HPText.gridFitType = GridFitType.PIXEL;
			HPText.embedFonts = true;
			HPText.sharpness = 400;
			HPText.defaultTextFormat = SansRPGText.BATTLE_TEXT;
            HPText.selectable = false;
			HPText.text = "92 / 92";
            layer_background.addChild(HPText);
		}

		public function HPBarUpdate(delta:Number, eclipsed:Number):void {
			HPBackground.width = Math.floor(player_heart.MaxHP * 1.2);
			HPBar.width = HPBackground.width * player_heart.HP / player_heart.MaxHP;
			KRBar.width = Math.ceil(HPBackground.width * player_heart.KR / player_heart.MaxHP);
			KRBar.x = HPBackground.x + HPBackground.width * (player_heart.HP - player_heart.KR) / player_heart.MaxHP;

			HPText.text = (player_heart.HP < 10 ? "0" : "") + player_heart.HP + " / " + player_heart.MaxHP;
			if(player_heart.KR == 0) HPText.transform.colorTransform.greenMultiplier = 1;
			if(player_heart.KR > 0) HPText.transform.colorTransform.greenMultiplier = 0;
		}

		public function get HPAreaAll():Array {
			return [HPBackground, HPBar, KRBar, PlayerNameBD, HPText];
		}

		/* #endregion */
		
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/* #region SansShake */
		public var CenterX:Number = 0;
		public var CenterY:Number = 0;
		public var ShakeIntensity:Number = 0;
		public var ShakeTimer:Number = 0;

		public function SansShake(intenstity:int):void {
			ShakeIntensity = intenstity;
			ShakeTimer = 0;
		}

		public function SansShakeUpdate(delta:Number, eclipsed:Number):void {
			// Shake
			if (ShakeIntensity > 0)
				ShakeTimer += eclipsed;
			else
			{
				x = CenterX;
				y = CenterY;
			}
			
			if (ShakeTimer > 0.03334)
			{
				ShakeTimer -= 0.03334;
				ShakeIntensity -= 0.5;
				this.x = CenterX + ShakeIntensity * (Math.random() > 0.5 ? 1 : -1);
				this.y = CenterY + ShakeIntensity * (Math.random() > 0.5 ? 1 : -1);
			}
		}

		/* #endregion */

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/* #region Timeline */
		public var TL_Running:Boolean = false;
		public var TL_Line:Number = 0;
		public var TL_T:Number = 0;
		public var TL_PanicFunc:String = "";
		public var TL_RunCount:Number = 0;
		
		public var TLActionList:Array = [];
		public var TLLabels:Object = {};
		public var TLVars:Object = {"pi": Math.PI};
		public var TLCurrentLine:Array = [];
		
		public function TLTick(delta:Number, eclipsed:Number):void {
			TL_RunCount = 0;
			while (true)
			{
				if (!TL_Running || TL_Line < 0 || TL_Line > TLActionList.length || TL_T < TLCurrentLine[0])
					break;
					
				if(TLCurrentLine[1].toString().substr(0, 1) != ":") // Label Check
				{
					try
					{
						var CallFunction:Function;
						
						if (TL_FUNCTIONS[TLCurrentLine[1]] == null)
							TL_FUNCTIONS[TLCurrentLine[1]] = (this[TLCurrentLine[1]] as Function);
							
						CallFunction = TL_FUNCTIONS[TLCurrentLine[1]];
						CallFunction.apply(null, TLCurrentLine[2]);
						
						//trace(TLCurrentLine[1] + "(" + ((TLCurrentLine[2] as Array).join(", ")) + ") [" + TL_Line + "," + TL_RunCount + "]");
					}
					catch (e:Error)
					{
						trace("---", TLCurrentLine[1] + "(" + ((TLCurrentLine[2] as Array).join(", ")) + ") [" + TL_Line + "," + TL_RunCount + "]");
						//trace(e);
					}
				}
				
				TL_T -= TLCurrentLine[0];
				TL_Line++;
				
				if (!TLLoadLine())
					break;
					
				TL_RunCount++;
					
				if (TL_RunCount >= 1000)
				{
					TL_Running = false;
					trace("TLTick: Infinite Loop Detected, Line ", TL_Line);
					break;
				}
			}
			if(TL_Running)
				TL_T += eclipsed;
		}
		
		public function TLPlay(seqData:Array):void {
			// Reset
			TLActionList = [];
			TLLabels = {};
			TLVars = {"pi": Math.PI};
			
			var Count:Number = seqData.length;
			var LineText:Array;
			
			for (var i:int = 0; i < Count; i++)
			{
				LineText = seqData[i];
				TLActionList.push(LineText);
				
				var TokenString:String = LineText[1].toString();
				
				// Jump Labels
				if (TokenString.substr(0, 1) == ":")
					TLLabels[TokenString.substr(1)] = (i + 1);
			}
			
			TL_T = 0;
			TL_Line = 1;
			
			TLLoadLine();
			
			TL_Running = true;
		}
		
		public function TLLoadLine():Boolean {
			TLCurrentLine = [];
			
			if (TL_Line < 0 || TL_Line > TLActionList.length)
				return false;
			
			var Text:Array = TLActionList[TL_Line - 1];
			var ParamCount:Number = Text.length;
			var FunctionArgs:Array = [];
			
			TLCurrentLine.push(TLTokenValue(Text[0], true)); // 0 = Time Delay
			TLCurrentLine.push(TLFunctionRedirect(Text[1])); // 1 = Function Name or Label
			TLCurrentLine.push(FunctionArgs);
			
			for (var i:int = 2; i < ParamCount; i++)
				FunctionArgs.push(TLTokenValue(Text[i]));
			
			return true;
		}
		
		private function TLFunctionRedirect(func_name:String):String {
			if (func_name == "Sound")
				return "PlaySound";
				
			return func_name;
		}
		
		private function TLTokenValue(Token:*, doPause:Boolean = false):* {
			var TokenString:String = Token.toString();
			
			if (TokenString.substr(0, 1) == "$")
				return TLVars[Token.substr(1)];
			
			return Token;
		}
		
		public function TLPanic(callback:String):void {
			TL_PanicFunc = callback;
		}
		
		public function TLPause():void {
			TL_Running = false;
		}
		
		public function TLResume():void {
			TL_Running = true;
		}
		
		public function TLIsRunning():Boolean {
			return TL_Running;
		}
		
		public function TLStop():void {
			TLActionList = [];
			TLCurrentLine = [];
			TL_Running = false;
		}
		
		// Timeline CPU
		public function SET(key:String, value1:*):void {
			TLVars[key] = value1;
		}
		
		public function ADD(key:String, value1:Number, value2:Number):void {
			TLVars[key] = value1 + value2;
		}
		
		public function SUB(key:String, value1:Number, value2:Number):void {
			TLVars[key] = value1 - value2;
		}
		
		public function MUL(key:String, value1:Number, value2:Number):void {
			TLVars[key] = value1 * value2;
		}
		
		public function DIV(key:String, value1:Number, value2:Number):void {
			TLVars[key] = value1 / value2;
		}
		
		public function MOD(key:String, value1:Number, value2:Number):void {
			TLVars[key] = value1 % value2;
		}
		
		public function FLOOR(key:String, value1:Number):void {
			TLVars[key] = Math.floor(value1);
		}
		
		public function DEG(key:String, value1:Number):void {
			TLVars[key] = value1 * 180 / Math.PI;
		}
		
		public function RAD(key:String, value1:Number):void {
			TLVars[key] = value1 * Math.PI / 180;
		}
		
		public function SIN(key:String, value1:Number):void {
			TLVars[key] = Math.sin(deg2rad(value1));
		}
		
		public function COS(key:String, value1:Number):void {
			TLVars[key] = Math.cos(deg2rad(value1));
		}
		
		public function ANGLE(key:String, to_x:Number, to_y:Number, from_x:Number, from_y:Number):void {
			TLVars[key] = ((((Math.atan2(to_y - from_y, to_x - from_x)) * 180 / Math.PI) + 180) % 360);
		}
		
		public function RND(key:String, value1:Number):void {
			TLVars[key] = Math.floor(Math.random() * value1);
		}
		
		public function JMPABS(jumpTarget:*):void {
			//if (jumpTarget.toString().match(/^[0-9]+$/gi))
			if (jumpTarget is Number)
			{
				TL_Line = jumpTarget - 1;
			}
			else
			{
				if (TLLabels[jumpTarget] != null)
					TL_Line = TLLabels[jumpTarget] - 1;
				else
					trace("Invalid JMPABS target -> \"" + jumpTarget + "\" at line " + TL_Line);
			}
		}
		
		public function JMPREL(target:int):void {
			TL_Line += (target - 1);
		}
		
		public function JMPZ(jumpTarget:*, value1:Number):void {
			if (value1 == 0) JMPABS(jumpTarget);
		}
		
		public function JMPNZ(jumpTarget:*, value1:Number):void {
			if (value1 != 0) JMPABS(jumpTarget);
		}
		
		public function JMPE(jumpTarget:*, value1:Number, value2:Number):void {
			if (value1 == value2) JMPABS(jumpTarget);
		}
		
		public function JMPNE(jumpTarget:*, value1:Number, value2:Number):void {
			if (value1 != value2) JMPABS(jumpTarget);
		}
		
		public function JMPL(jumpTarget:*, value1:*, value2:*):void {
			if (value1 < value2) JMPABS(jumpTarget);
		}
		
		public function JMPNL(jumpTarget:*, value1:Number, value2:Number):void {
			if (value1 >= value2) JMPABS(jumpTarget);
		}
		
		public function JMPG(jumpTarget:*, value1:Number, value2:Number):void {
			if (value1 > value2) JMPABS(jumpTarget);
		}
		
		public function JMPNG(jumpTarget:*, value1:Number, value2:Number):void {
			if (value1 <= value2) JMPABS(jumpTarget);
		}
		
		public function GetHeartPos(key1:String, key2:String):void {
			TLVars[key1] = player_heart.x;
			TLVars[key2] = player_heart.y;
		}

		/* #endregion */
	}
}