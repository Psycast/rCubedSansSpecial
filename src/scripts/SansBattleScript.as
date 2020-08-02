package scripts
{
	import classes.Noteskins;
	import classes.chart.ILevelScript;
	import classes.chart.ILevelScriptRuntime;
	import com.flashfla.utils.ArrayUtil;
	import com.greensock.TimelineMax;
	import com.greensock.easing.SineInOut;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import game.GamePlay;
	import flash.utils.getDefinitionByName;
	
	public class SansBattleScript implements ILevelScript
	{
		public var _keyDowns:Array = [];
		
		public var _gvars:GlobalVariables = GlobalVariables.instance;
		public var _noteskins:Noteskins = Noteskins.instance;
		
		public var runtime:ILevelScriptRuntime;
		public var gameplay:GamePlay;
		
		public var lastTimer:int = 0;
		
		public var player_attack_container:SansAttackContainer;
		
		public var vpad:SansVPAD = new SansVPAD();

		public var liteTickables:Array = [];

		public var healSound:Class;
		public var piesEatten:int = 0;
        public var lastFrame:int = 0;

		public var itHasBegun:Boolean =  false;
		public var skipLevel:Boolean = false;
		public var keyHistory:Array = [];
		
		/* INTERFACE classes.chart.ILevelScript */
		
		public function init(runtime:ILevelScriptRuntime):void
		{
			this.runtime = runtime;
			this.gameplay = this.runtime.getGameplay();
			this.healSound = getDefinitionByName("ext.scripts::soundSansPlayerHeal") as Class;
		}
		
		public function hasFrameScript(frame:int):Boolean
		{
			return false;
		}

		public function destroy():void
		{
			removeListerners();
		}

		public function removeListerners():void
		{
			gameplay.removeEventListener(Event.ENTER_FRAME, e_onEnterFrame);
			gameplay.stage.removeEventListener(KeyboardEvent.KEY_DOWN, e_onKeyPress);
			gameplay.stage.removeEventListener(KeyboardEvent.KEY_UP, e_onKeyPress);
		}
		
		public function doFrameEvent(frame:int):void
		{
			var displayText:SansRPGTextLite;

			if(frame == 3)
			{
                lastFrame = Math.min(3450, gameplay.gameLastNoteFrame - 60);
				gameplay.stage.addEventListener(KeyboardEvent.KEY_DOWN, e_onKeyPress);
				gameplay.stage.addEventListener(KeyboardEvent.KEY_UP, e_onKeyPress);
			}

			if(frame < lastFrame && !skipLevel)
			{
				var curTimer:int = getTimer();
				var delta:Number = (curTimer - lastTimer) / (1000 / gameplay.stage.frameRate);
				var eclipsed:Number = (curTimer - lastTimer) / 1000;
				lastTimer = curTimer;

				for each(var tickable:ISansTickable in liteTickables)
					tickable.update(delta, eclipsed, this);

				// Prevent Player Death
				// They have enough EXP and items from murdering everything.
				var gameLife:int = gameplay.getScriptVariable("gameLife");
				if(gameLife < 25) {
					gameLife = 100;
					gameplay.setScriptVariable("gameLife", gameLife);

					displayText = new SansRPGTextLite();
					displayText.x = ((Main.GAME_WIDTH - SansAttackContainer.CONTAINER_WIDTH) / 2) + 48;
					displayText.y = ((Main.GAME_HEIGHT - SansAttackContainer.CONTAINER_HEIGHT) / 2) + 272;
					displayText.setSize(544, 96);
					displayText.Timeout = 1.5;
					displayText.FullText = "* You eat the Butterscotch Pie.\n* You recovered 99 HP!";
					var snd:SansSoundObject = new SansSoundObject(this.healSound, "PlayerHeal", 1);
					liteTickables[liteTickables.length] = displayText;
					gameplay.addChildAt(displayText, 2);
					piesEatten++;
				}

				// Mod Toggle Warning
				if(frame == 440 || frame == 930 || frame == 1670)
				{
					displayText = new SansRPGTextLite();
					displayText.x = ((Main.GAME_WIDTH - SansAttackContainer.CONTAINER_WIDTH) / 2) + 48;
					displayText.y = ((Main.GAME_HEIGHT - SansAttackContainer.CONTAINER_HEIGHT) / 2) + 272;
					displayText.setSize(544, 96);
					displayText.Timeout = 1.5;
					displayText.FullText = "* Sans wants this to be harder.";
					liteTickables[liteTickables.length] = displayText;
					gameplay.addChildAt(displayText, 2);
				}

				// Enable Wave
				if(frame == 530) {
					runtime.addMod("wave");
					displayText = new SansRPGTextLite();
					displayText.x = ((Main.GAME_WIDTH - SansAttackContainer.CONTAINER_WIDTH) / 2) + 48;
					displayText.y = ((Main.GAME_HEIGHT - SansAttackContainer.CONTAINER_HEIGHT) / 2) + 272;
					displayText.setSize(544, 96);
					displayText.Timeout = 1.5;
					displayText.FullText = "* Sans made it harder.";
					liteTickables[liteTickables.length] = displayText;
					gameplay.addChildAt(displayText, 2);
				}

				// Enable Drunk
				if(frame == 1019)
				{
					runtime.addMod("drunk");
					displayText = new SansRPGTextLite();
					displayText.x = ((Main.GAME_WIDTH - SansAttackContainer.CONTAINER_WIDTH) / 2) + 48;
					displayText.y = ((Main.GAME_HEIGHT - SansAttackContainer.CONTAINER_HEIGHT) / 2) + 272;
					displayText.setSize(544, 96);
					displayText.Timeout = 1.5;
					displayText.FullText = "* Sans made it harder.";
					liteTickables[liteTickables.length] = displayText;
					gameplay.addChildAt(displayText, 2);
				}

				// Enable Flashlight
				if(frame == 1745)
				{
					runtime.addMod("flashlight");
					runtime.addMod("apr_1_2020");
					gameplay.getScriptVariable("buildFlashlight")();
					displayText = new SansRPGTextLite();
					displayText.x = ((Main.GAME_WIDTH - SansAttackContainer.CONTAINER_WIDTH) / 2) + 48;
					displayText.y = ((Main.GAME_HEIGHT - SansAttackContainer.CONTAINER_HEIGHT) / 2) + 272;
					displayText.setSize(544, 96);
					displayText.Timeout = 1.5;
					displayText.FullText = "* Sans made it harder.";
					liteTickables[liteTickables.length] = displayText;
					gameplay.addChildAt(displayText, 2);
				}
			}
			

			// 1009
			// 1258
			// 1745
			// 3450
			if ((frame == lastFrame || skipLevel) && !itHasBegun) // 1745
			{
				gameplay.addEventListener(Event.ENTER_FRAME, e_onEnterFrame);
				
				gameplay.stage.frameRate = 60;
				gameplay.togglePause();
				lastTimer = getTimer();
				
				doCaseEvent(0);
			}
		}
		
		public function RemoveLiteTickable(object:Object):void
		{
			if(object.parent != null)
				object.parent.removeChild(object);
				
			(object as ISansTickable).destroy();
			
			var index:int = liteTickables.indexOf(object);
			if (index > -1) {
				liteTickables.splice(index, 1);
			}
		}

		public function RemoveTickable(object:Sprite):void 
		{
			player_attack_container.RemoveTickable(object);
		}
		
		private function e_onKeyPress(e:KeyboardEvent):void
		{
			_keyDowns[e.keyCode] = (e.type == KeyboardEvent.KEY_DOWN ? true : false);
			if(!skipLevel && e.type == KeyboardEvent.KEY_DOWN)
			{
				keyHistory[keyHistory.length] = e.keyCode;

				if(keyHistory.length > 10)
					keyHistory.shift();

				var historyString:String = keyHistory.join(",");

				if(historyString.indexOf("38,38,40,40,37,39,37,39,13") >= 0)
					skipLevel = true;
			}
		}
		
		private function e_onEnterFrame(e:Event):void
		{
			// Understand Delta
			var curTimer:int = getTimer();
			var delta:Number = (curTimer - lastTimer) / (1000 / 60);
			var eclipsed:Number = (curTimer - lastTimer) / 1000;
			lastTimer = curTimer;
			
			vpad.update(_keyDowns);
			
			player_attack_container.update(delta, eclipsed);
		}
		
		public function doCaseEvent(event:int):void
		{
			switch (event)
			{
			
			// Init Battle
			case 0: 
				gameplay.setScriptVariable("inputDisabled", true);

			 	for(var t:int = liteTickables.length - 1; t > 0; t--)
					RemoveLiteTickable(liteTickables[t]);

				var chd:Array = [];
				for (var i:int = 1; i < gameplay.numChildren; i++)
					chd.push(gameplay.getChildAt(i));
				var chr:Array = ArrayUtil.randomize(chd);
				
				var tl:TimelineMax = new TimelineMax({paused: true, onComplete: staggerComplete});
				tl.staggerTo(chr, 1.5, {"autoAlpha": 0}, 0.65);
				
				// Fake Receptor
				var point:Point = gameplay.getScriptVariable("noteBox")["upReceptor"].localToGlobal(new Point());
				
				var fake_recp:MovieClip = _noteskins.getReceptor(gameplay.getScriptVariable("options")["noteskin"], "U");
				fake_recp.x = point.x;
				fake_recp.y = point.y;
				fake_recp.rotation = gameplay.getScriptVariable("noteBox")["upReceptor"]["rotation"];
				fake_recp.scaleX = fake_recp.scaleY = gameplay.getScriptVariable("noteBox")["upReceptor"]["scaleX"];
				gameplay.addChild(fake_recp);
				
				// Draw Box
				player_attack_container = new SansAttackContainer(this);
				player_attack_container.PiesEatten = piesEatten;
				player_attack_container.LevelSkipped = skipLevel;
				gameplay.addChild(player_attack_container);
				
				player_attack_container.combat_zone.CombatZoneResizeInstant(239, 226, 404, 391); // Default Size
				player_attack_container.combat_zone.CombatZoneHide();
				player_attack_container.SansHead("Tired1");
				
				tl.to(fake_recp, 3, {
						"rotation": 0, 
						"x": 320 + player_attack_container.x, 
						"y": 304 + player_attack_container.y, 
						"ease":SineInOut.ease
					}, "+=2");
				tl.to(fake_recp, 2.5, {"scaleX": 0.35, "scaleY": 0.35, "ease":SineInOut.ease}, "-=1.5");
				
				var fade_delay:Number = 1.05;
				for (i = 16; i > 0; i--) {
					tl.to(fake_recp, 0.01, {"alpha": (i & 1)}, "+=" + fade_delay.toString());
					fade_delay /= 1.3;
				}
				tl.to(fake_recp, 0.01, {"alpha": 0}, "+=" + fade_delay.toString());
				tl.to(player_attack_container.menu_group, 1.5, {"alpha": 1}, "-=1.5");
				tl.to(player_attack_container.HPAreaAll, 1.5, {"alpha": 1}, "-=1.5");
				tl.to(player_attack_container.SansSpriteAll, 1.5, {"alpha": 1}, "-=0.5");
				tl.to(player_attack_container.combat_zone.CombatZone, 2, {"alpha": 1, "ease":SineInOut.ease}, "-=1.5");
				
				tl.timeScale(1);
				tl.play();
					
				break;
			
			// Start Attack
			case 1:
				player_attack_container.StartAttack();
				break;

			// Player Win
			case 2:
				gameplay.setScriptVariable("gameScore", 401);
				gameplay.setScriptVariable("hitAmazing", 1);
				gameplay.setScriptVariable("hitPerfect", 3);
				gameplay.setScriptVariable("hitGood", 3);
				gameplay.setScriptVariable("hitAverage", 7);
				gameplay.setScriptVariable("hitMiss", 2020);
				gameplay.setScriptVariable("hitBoo", 1337);
				gameplay.setScriptVariable("hitCombo", 0);
				gameplay.setScriptVariable("hitMaxCombo", 0);
				
			// Exit Stage
			case 3:
				removeListerners();
				gameplay.setScriptVariable("GAME_STATE", GamePlay.GAME_END);
			}
		}
		
		private function staggerComplete():void
		{
            trace("complete");
			doCaseEvent(1);
		}
	}
}
