package game {
	import arc.ArcGlobals;
	import arc.mp.MultiplayerSingleton;
	import assets.results.ResultsBackground;
	import by.blooddy.crypto.SHA1;
	import classes.Alert;
	import classes.BoxButton;
	import classes.Language;
	import classes.Playlist;
	import classes.StarSelector;
	import classes.replay.Replay;
	import classes.replay.ReplayNote;
	import classes.Text;
	import com.flashfla.net.DynamicURLLoader;
	import com.flashfla.utils.NumberUtil;
	import com.flashfla.utils.ObjectUtil;
	import com.flashfla.utils.TimeUtil;
	import com.flashfla.utils.sprintf;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	import menu.MenuPanel;
	import popups.PopupHighscores;
	import popups.PopupMessage;
	import popups.PopupSongRating;
	import popups.PopupTokenUnlock;
	
	CONFIG::air {
		import flash.filesystem.File;
		import flash.filesystem.FileMode;
		import flash.filesystem.FileStream;
	}
	
	public class GameResults extends MenuPanel {
		
		private var _mp:MultiplayerSingleton = MultiplayerSingleton.getInstance();
		private var _gvars:GlobalVariables = GlobalVariables.instance;
		private var _avars:ArcGlobals = ArcGlobals.instance;
		private var _lang:Language = Language.instance;
		private var _loader:DynamicURLLoader;
		private var resultIndex:int = 0;
		private var TEXT_STYLE:StyleSheet;
		
		private var resultsDisplay:ResultsBackground;
		private var graphDraw:Sprite;
		private var graphToggle:BoxButton;
		
		private var navRating:Sprite;
		private var navPrev:BoxButton;
		private var navNext:BoxButton;
		private var resultsMods:Text;
		
		private var navScreenShot:BoxButton;
		private var navReplay:BoxButton;
		private var navOptions:BoxButton;
		private var navHighscores:BoxButton;
		private var navMenu:BoxButton;
		private var resultsTime:String = TimeUtil.getCurrentDate();

		private var songResults:Array;
		private var songIndex:int;
		private var graphType:int = 0;
		
		public function GameResults(myParent:MenuPanel) {
			super(myParent);
		}
		
		override public function init():Boolean {
			songResults = _gvars.songResults;
			songIndex = _gvars.CUR_GAME_INDEX;

			// More songs to play, jump to gameplay or loading.
			if (_gvars.songQueue.length > 0) {
				switchTo(GameMenu.GAME_LOADING);
				return false;
			} else {
				_gvars.songResults = [];
				_gvars.CUR_GAME_INDEX = -1;
			}
			return true;
		}
		
		override public function stageAdd():void {
			// Add keyboard navigation
			stage.addEventListener(KeyboardEvent.KEY_DOWN, eventHandler);
			
			CONFIG::air {
				stage.nativeWindow.title = Constant.AIR_WINDOW_TITLE;
			}
			
			// Get Graph Type
			graphType = LocalStore.getVariable("result_graph_type", 0);
			
			// Text Style
			TEXT_STYLE = new StyleSheet();
			TEXT_STYLE.setStyle("BODY", {fontWeight: "bold"});
			TEXT_STYLE.setStyle("A", { textDecoration: "underline"} );
			
			// Background
			resultsDisplay = new ResultsBackground();
			resultsDisplay.song_description.styleSheet = TEXT_STYLE;
			this.addChild(resultsDisplay);
			
			// Avatar
			var result:Object = songResults[songResults.length - 1];
			if (result.user) {
				var userAvatar:DisplayObject = result.user.avatar;
				if (userAvatar && userAvatar.height > 0 && userAvatar.width > 0) {
					userAvatar.x = 616 + ((99 - userAvatar.width) / 2);
					userAvatar.y = 114 + ((99 - userAvatar.height) / 2);
					this.addChild(userAvatar);
				}
			}
			
			var buttonMenu:Sprite = new Sprite();
			var buttonMenuItems:Array = [];
			buttonMenu.x = 22;
			buttonMenu.y = 428;
			this.addChild(buttonMenu);

			// Main Bavigation Buttons
			navOptions = new BoxButton(170, 40, _lang.string("game_results_menu_options"), 17);
			navOptions.addEventListener(MouseEvent.CLICK, eventHandler);
			buttonMenu.addChild(navOptions);
			buttonMenuItems.push(navOptions);
			
			navHighscores = new BoxButton(170, 40, _lang.string("game_results_menu_highscores"), 17);
			navHighscores.addEventListener(MouseEvent.CLICK, eventHandler);
			buttonMenu.addChild(navHighscores);
			buttonMenuItems.push(navHighscores);
			
			if (!_mp.gameplayPlayingStatus()) {
				navReplay = new BoxButton(170, 40, _lang.string("game_results_menu_replay_song"), 17);
				navReplay.addEventListener(MouseEvent.CLICK, eventHandler);
				buttonMenu.addChild(navReplay);
				buttonMenuItems.push(navReplay);
			}
			
			if (!_gvars.flashvars.replay && !_gvars.flashvars.preview_file) {
				navMenu = new BoxButton(170, 40, _lang.string("game_results_menu_exit_menu"), 17);
				navMenu.addEventListener(MouseEvent.CLICK, eventHandler);
				buttonMenu.addChild(navMenu);
				buttonMenuItems.push(navMenu);
			}
			
			var BUTTON_GAP:int = 11;
			var BUTTON_WIDTH:int = (735 - (Math.max(0, (buttonMenuItems.length - 1)) * BUTTON_GAP)) / buttonMenuItems.length;
			for (var bx:int = 0; bx < buttonMenuItems.length; bx++) {
				buttonMenuItems[bx].width = BUTTON_WIDTH;
				buttonMenuItems[bx].x = BUTTON_WIDTH * bx + BUTTON_GAP * bx;
			}
			
			// Star Rating Button
			navRating = new Sprite();
			navRating.buttonMode = true;
			navRating.mouseChildren = false;
			navRating.addEventListener(MouseEvent.CLICK, eventHandler);
			resultsDisplay.addChild(navRating);
			
			// Song Results Buttons
			navScreenShot = new BoxButton(84, 32, _lang.string("game_results_queue_save_screenshot"));
			navScreenShot.x = 470;
			navScreenShot.y = 6;
			navScreenShot.addEventListener(MouseEvent.CLICK, eventHandler);
			this.addChild(navScreenShot);
			
			navPrev = new BoxButton(90, 32, _lang.string("game_results_queue_previous"));
			navPrev.x = 18;
			navPrev.y = 62;
			navPrev.addEventListener(MouseEvent.CLICK, eventHandler);
			this.addChild(navPrev);
			
			navNext = new BoxButton(90, 32, _lang.string("game_results_queue_next"));
			navNext.x = 672;
			navNext.y = 62;
			navNext.addEventListener(MouseEvent.CLICK, eventHandler);
			this.addChild(navNext);
			
			resultsMods = new Text("---");
			resultsMods.x = 18;
			resultsMods.y = 276;
			this.addChild(resultsMods);
			
			graphDraw = new Sprite();
			graphDraw.x = 30;
			graphDraw.y = 298;
			this.addChild(graphDraw);
			
			graphToggle = new BoxButton(17, 19, "&gt;");
			graphToggle.x = 10;
			graphToggle.y = 297;
			graphToggle.addEventListener(MouseEvent.CLICK, eventHandler);
			this.addChild(graphToggle);
			
			// Display Game Result
			displayGameResult(songResults.length > 1 ? -1 : 0);
			
			_mp.gameplayResults(this, songResults);
			_gvars.gameMain.displayPopupQueue();
		}
		
		override public function stageRemove():void {
			// Remove keyboard navigation
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, eventHandler);
			
			super.stageRemove();
		}
		
		public function displayGameResult(gameIndex:int):void {
			// Set Index
			resultIndex = gameIndex;
			
			// Star
			navRating.visible = false;
			if (resultIndex >= 0) {
				navRating.graphics.clear();
				StarSelector.drawStar(navRating.graphics, 18, 0, 0, (_gvars.playerUser.getSongRating(songResults[resultIndex]["song"]["level"]) != 0), 0xF2D60D, 1);
			}
			
			// Buttons
			if (navScreenShot) navScreenShot.visible = false;
			if (navPrev) navPrev.visible = false;
			if (navNext) navNext.visible = false;
			
			if (songResults.length > 1) {
				if (gameIndex > -1) {
					navPrev.visible = true;
					navPrev.text = (gameIndex == 0 ? _lang.string("game_results_queue_total") : _lang.string("game_results_queue_previous"));
				}
				if (gameIndex < songResults.length - 1)
					navNext.visible = true;
			}
			
			// Variables
			var skillLevel:String = (songResults[0].user != null) ? ("[Lv." + songResults[0].user.skillLevel + "]" + " ") : "";
			var displayTime:String = "";
			var song:Object;
			var songTitle:String = "";
			var songSubTitle:String = "";
			
			var scoreTotal:int = 0;
			var scoreCredits:int = 0;
			
			// Song Results
			var result:Object = {
				"user": songResults[0].user,
				"options": songResults[0].options,
				"amazing": 0,
				"perfect": 0,
				"good": 0,
				"average": 0,
				"miss": 0,
				"boo": 0,
				"score": 0,
				"replay_hit": [],
				"arrows": 0
			};
			
			// Song Queue (Multiple Songs)
			if (gameIndex == -1) {
				for (var x:int = 0; x < songResults.length; x++) {
					var tempResult:Object = songResults[x];
					var tempTotal:int = ((tempResult.amazing + tempResult.perfect) * 500) + (tempResult.good * 250) + (tempResult.average * 50) + (tempResult.maxcombo * 1000) - (tempResult.miss * 300) - (tempResult.boo * 15) + tempResult.score;
					song = tempResult.song;
					songSubTitle += song.name + ", ";
					result.arrows += song.arrows;
					result.amazing += tempResult.amazing;
					result.perfect += tempResult.perfect;
					result.good += tempResult.good;
					result.average += tempResult.average;
					result.miss += tempResult.miss;
					result.boo += tempResult.boo;
					result.score += tempResult.score;
					
					// Replay Graph
					for (var y:int = 0; y < tempResult.replay_hit.length; y++)
						result.replay_hit.push(tempResult.replay_hit[y]);
					
					// Score Total
					scoreTotal += tempTotal;
					
					// Credits
					scoreCredits += calculateCredits(tempTotal);
				}
				
				result.maxcombo = getMaxCombo(result);
				songTitle = sprintf(_lang.string("game_results_total_songs"), { "total": NumberUtil.numberFormat(songResults.length) } );
				songSubTitle = songSubTitle.substr(0, songSubTitle.length - 2);
				displayTime = resultsTime;
				
				// Index
				songIndex = -1;
			}
			
			// Single Song
			else {
				result = songResults[resultIndex];
				song = result.song;
				
				var seconds:Number = Math.floor(song.timeSecs * (1/result.options.songRate));
				var songLength:String = (Math.floor(seconds/60)) + ":" + (seconds % 60 >= 10 ? "": "0") + (seconds % 60);
				var rateString:String = result.options.songRate != 1 ? " (" + result.options.songRate + "x Rate)" : "";
				
				// Song Title
				songTitle = song.engine ? song.name + rateString : "<a href=\"" + Constant.LEVEL_STATS_URL + song.level + "\">" + song.name + rateString + "</a>";
				songSubTitle = sprintf(_lang.string("game_results_subtitle_difficulty"), {"value": song.difficulty}) + " - " + sprintf(_lang.string("game_results_subtitle_length"), {"value": songLength});
				if (song.author != "") songSubTitle += " - " + _lang.wrapFont(sprintf(_lang.stringSimple("game_results_subtitle_author"), {"value": song.authorwithurl}));
				if (song.stepauthor != "") songSubTitle += " - " + _lang.wrapFont(sprintf(_lang.stringSimple("game_results_subtitle_stepauthor"), {"value": song.stepauthorwithurl}));
				
				displayTime = result.endtime;
				scoreTotal = ((result.amazing + result.perfect) * 500) + (result.good * 250) + (result.average * 50) + (result.maxcombo * 1000) - (result.miss * 300) - (result.boo * 15) + result.score
				scoreCredits += calculateCredits(scoreTotal);
				
				// Index
				songIndex = result.game_index + 1;
			}
			
			// Save Screenshot
			if (!_gvars.flashvars.preview_file)
				navScreenShot.visible = true;
			
			// Skill rating
			var rawgoods:Number = zRanking.getRawGoods(result);	
			var songweight:Number = zRanking.getSongWeight(song, result);
			if (songweight < 0 || result.options.songRate != 1 || result.lastNote > 0 || result.score <= 0 || song.engine != null) songweight = 0;
			
			// Display Results
			if(Text.isUnicode(songTitle))
				resultsDisplay.song_title.defaultTextFormat.font = Language.UNI_FONT_NAME;
			if(Text.isUnicode(songSubTitle))
				resultsDisplay.song_description.defaultTextFormat.font = Language.UNI_FONT_NAME;

			resultsDisplay.results_username.htmlText = "<B>" + (result.options.replay ? "Replay r" : "R") + "esults for " + skillLevel + result.user.name + ":</B>";
			resultsDisplay.results_time.htmlText = "<B>" + displayTime + "</B>";
			resultsDisplay.song_title.htmlText = "<B>" + _lang.wrapFont(songTitle) + "</B>";
			resultsDisplay.song_description.htmlText = "<B>" + songSubTitle + "</B>";
			resultsDisplay.result_amazing.htmlText = "<B>" + NumberUtil.numberFormat(result.amazing) + "</B>";
			resultsDisplay.result_perfect.htmlText = "<B>" + NumberUtil.numberFormat(result.perfect) + "</B>";
			resultsDisplay.result_good.htmlText = "<B>" + NumberUtil.numberFormat(result.good) + "</B>";
			resultsDisplay.result_average.htmlText = "<B>" + NumberUtil.numberFormat(result.average) + "</B>";
			resultsDisplay.result_miss.htmlText = "<B>" + NumberUtil.numberFormat(result.miss) + "</B>";
			resultsDisplay.result_boo.htmlText = "<B>" + NumberUtil.numberFormat(result.boo) + "</B>";
			resultsDisplay.result_maxcombo.htmlText = "<B>" + NumberUtil.numberFormat(result.maxcombo) + "</B>";
			resultsDisplay.result_rawscore.htmlText = "<B>" + NumberUtil.numberFormat(result.score) + "</B>";
			resultsDisplay.result_total.htmlText = "<B>" + NumberUtil.numberFormat(scoreTotal) + "</B>";
			resultsDisplay.result_credits.htmlText = "<B>" + scoreCredits + "</B>";
			resultsDisplay.result_rawgoods.htmlText = "<B>" + NumberUtil.numberFormat(rawgoods,1,true) + "</B>";
			resultsDisplay.result_equivalency.htmlText = "<B>" + NumberUtil.numberFormat(songweight,2,true) + "</B>";
			
			// Align Rating Star to Song Title
			navRating.x = resultsDisplay.song_title.x + (resultsDisplay.song_title.width / 2) - (resultsDisplay.song_title.textWidth / 2) - 22;
			navRating.y = resultsDisplay.song_title.y + 4;
			
			/// - Rank Text
			// Has FFR Highscore
			if (_gvars.songResultRanks[songIndex] != null) {
				resultsDisplay.result_rank.htmlText = "<B>Rank: " + _gvars.songResultRanks[songIndex].new_ranking;
				resultsDisplay.result_last_best.htmlText = "<B>Last Best: " + _gvars.songResultRanks[songIndex].old_ranking;
			}
			// Alt Engine Score
			else if (result.song && result.song.engine) {
				resultsDisplay.result_credits.htmlText = "<B>--</B>";
				var rank:Object = result.legacyLastRank;
				if (rank) {
					resultsDisplay.result_rank.htmlText = "<B>" + (rank.score < result.score ? "Last" : "Current") + " Best: " + rank.score;
					resultsDisplay.result_last_best.htmlText = rank.results;
				} else {
					resultsDisplay.result_rank.htmlText = "Saved score locally";
					resultsDisplay.result_last_best.htmlText = "";
				}
			}
			// Getting Rank / Unsendable Score
			else if (!result.options.replay && gameIndex != -1) {
				resultsDisplay.result_rank.htmlText = canSendScore(result, true, true, false, false) ? "Saving score..." : "Score not saved";
				resultsDisplay.result_last_best.htmlText = "";
			}
			// Blank
			else {
				resultsDisplay.result_rank.htmlText = "";
				resultsDisplay.result_last_best.htmlText = "";
			}
			
			// Edited Replay
			if (result.options.replay && result.options.replay.isEdited) {
				resultsDisplay.result_rank.htmlText = _lang.string("results_replay_modified");
				resultsDisplay.result_rank.textColor = 0xF06868;
			}
			
			// Song Preview
			if (_gvars.flashvars.preview_file) {
				resultsDisplay.results_username.htmlText = "<B>Song Preview:</B>";
				resultsDisplay.result_credits.htmlText = "<B>0</B>";
				navRating.visible = false;
			}
			
			// Mod Text
			resultsMods.text = "Scroll Speed: " + result.options.scrollSpeed;
			if (result.restarts > 0)
				resultsMods.text += ", Restarts: " + result.restarts;
			var mods:Array = new Array();
			for each (var mod:String in result.options.mods)
				mods.push(_lang.string("options_mod_" + mod));
			if (result.options.judgeWindow)
				mods.push("Judge");
			if (mods.length > 0)
				resultsMods.text += ", Game Mods: " + mods.join(", ");
			if (result.lastNote > 0)
				resultsMods.text += ", Last Note: " + result.lastNote;
				
			if (gameIndex != -1) {
				var arcMenu:ContextMenu = new ContextMenu();
				var arcItem:ContextMenuItem = new ContextMenuItem("Accuracy: " + (result.accuracy.toFixed(3)) + " (±" + result.accuracyDeviation.toFixed(3) + ")");
				arcMenu.customItems.push(arcItem);
				resultsMods.contextMenu = arcMenu;
			}
			
			drawResultGraph(result);
			
			_gvars.gameMain.displayPopupQueue();
		}
		
		////////////////////////////////
		//Graph Drawing
		private function drawResultGraph(result:Object = null):void 
		{
			graphDraw.graphics.clear();
			
			var graph_type:int = graphType;
			
			// Get Result
			if (result == null && songResults[resultIndex] != null)
				result = songResults[resultIndex];
			
			// Bail if no result data.
			if (result == null) 
				return;
			
			var graphWidth:int = 718;
			var graphHeight:int = 117;
			var posX:Number;
			var posY:Number;
			
			var ratioX:Number = graphWidth;
			var ratioY:Number = graphHeight;
			var songFile:Object = result.songFile;
			var songArrows:int = (result.arrows != null ? result.arrows : result.song.arrows);
			graphToggle.visible = (songFile != null);
			
			// Queue Total can only render FC graph.
			if (resultIndex == -1)
				graph_type = 0;
				
			// Check for Valid Data - Accuracy Graph
			if (graph_type == 1 && result["_binReplayNotes"] == null)
				graph_type = 0;
			
			// Full Combo / Default Graph
			if (graph_type == 1) {
				var MIN_TIME:int = 0;
				var MAX_TIME:int = 0;
				var GAP_TIME:int = 0;
				
				// Get Judge Window
				var judgeSettings:Array = Constant.JUDGE_WINDOW;
				if (result.options.judgeWindow)
					judgeSettings = result.options.judgeWindow;
					
				// Get Judge Window Size
				for (var jn:int = 0; jn < judgeSettings.length; jn++) {
					var jni:Object = judgeSettings[jn];
					if (jni.t < MIN_TIME) MIN_TIME = jni.t;
					if (jni.t > MAX_TIME) MAX_TIME = jni.t;
				}
				GAP_TIME = MAX_TIME - MIN_TIME;
				ratioX /= songArrows;
				ratioY /= GAP_TIME;
				
				// Draw Judge Regions
				graphDraw.graphics.lineStyle(0, 0, 0);
				for (jn = 0; jn < judgeSettings.length; jn++) {
					var jncj:Object = judgeSettings[jn];
					var jnnj:Object = judgeSettings[jn + 1] ? judgeSettings[jn + 1] : null;
					if (jncj == null || jnnj == null) break;
					var jn_rect_height:Number = (jnnj.t - jncj.t) * ratioY;
					var bgColor:uint = 0x000000;
					switch (jncj.s) {
						case 100: // Good
							bgColor = 0x97f658;
							break;
						case 50: // Good
							bgColor = 0x12e006;
							break;
						case 25: // Good
							bgColor = 0x01aa0f;
							break;
						case 5: // Average
							bgColor = 0xf99800
							break;
						default:
							continue;
					}
					graphDraw.graphics.beginFill(bgColor, 0.25);
					graphDraw.graphics.drawRect(0, ((jncj.t * -1) - MIN_TIME) * ratioY - jn_rect_height, graphWidth, jn_rect_height);
					graphDraw.graphics.endFill();
				}
				// Draw Judge Regions Dividers
				graphDraw.graphics.lineStyle(1, 0x000000, 0.25);
				for (jn = 1; jn < judgeSettings.length - 1; jn++) {
					jncj = judgeSettings[jn];
					graphDraw.graphics.moveTo(0, ((jncj.t * -1) - MIN_TIME) * ratioY);
					graphDraw.graphics.lineTo(graphWidth, ((jncj.t * -1) - MIN_TIME) * ratioY);
				}
				
				// Draw Hit Markers
				var playerTimings:Array = result["_binReplayNotes"];
				graphDraw.graphics.lineStyle(1, 0xFFFFFF, 1, true);
				for (jn = 0; jn < playerTimings.length; jn++) {
					var lastJudge:Object;
					posX = jn * ratioX;
					posY = (playerTimings[jn] - MIN_TIME) * ratioY;
					
					if(playerTimings[jn] != null) {
						for each (var j:Object in judgeSettings) 
							if ((playerTimings[jn] * -1) > j.t)
								lastJudge = j;
								
						switch (lastJudge.s) {
							case 100: // Amazing
								bgColor = 0xffffff;
								break;
							case 50: // Perfect
								bgColor = 0xd0ffd4;
								break;
							case 25: // Good
								bgColor = 0x76dd7e;
								break;
							case 5: // Average
								bgColor = 0xf99800;
								break;
							case 0:
							default:
								posY = GAP_TIME * ratioY;
								bgColor = 0xff0000;
								break;
						}
					}
					else {
						posY = GAP_TIME * ratioY;
						bgColor = 0xff0000;
					}
					
					graphDraw.graphics.lineStyle(1, bgColor, 1);
					graphDraw.graphics.moveTo(posX - 2, posY - 2);
					graphDraw.graphics.lineTo(posX + 2, posY + 2);
					graphDraw.graphics.moveTo(posX + 2, posY - 2);
					graphDraw.graphics.lineTo(posX - 2, posY + 2);
				}
			}
			else {
				var curCombo:int = 0;
				var lastColor:int = 0x0;
				var aaaColor:int = 0xFCC100;
				var lineColor:int = 0xFCC100;
				if (songFile == null) {
					ratioX /= songArrows;
					ratioY /= songArrows;
				} else {
					ratioX /= songFile.chart.Notes[songFile.chart.Notes.length - 1].frame + 5; // 5 Frame Buffer
					ratioY /= result.maxcombo > 0 ? result.maxcombo : songArrows;
					songArrows = songFile.totalNotes;
				}
				
				// Draw Combo Graph
				var fullcombo:Boolean = true;
				graphDraw.graphics.moveTo(0, 118);
				for (var n:int = 0; n < songArrows; n++) {
					var status:int = result.replay_hit[n];
					if (songFile == null)
						posX = n * ratioX;
					else
						posX = (songFile.getNote(n).frame * result.options.songRate + songFile.musicDelay) * ratioX;
					if (result.replay_hit.length <= n || (status == -5 && songFile != null)) {
						graphDraw.graphics.lineStyle(2, 0xFF0000, 1, true);
						graphDraw.graphics.lineTo(posX, 118);
						graphDraw.graphics.lineTo(719, 118);
						break;
					}
					if (status == -10) {
						if (songFile == null) {
							graphDraw.graphics.lineStyle(1, 0x5F5F5F, 1, true);
							graphDraw.graphics.moveTo(posX, 0);
							graphDraw.graphics.lineTo(posX, 118);
						}
						continue;
					} else if (status == -5) {
						graphDraw.graphics.lineStyle(2, 0xFF0000, 1, true);
						graphDraw.graphics.lineTo(posX, 118);
					}
					if (status <= 0) {
						curCombo = 0;
						fullcombo = false;
						lineColor = 0xFFFFFF;
					}
					else {
						curCombo++;
					}
					
					graphDraw.graphics.lineStyle(2, lineColor, 1, true);
					graphDraw.graphics.lineTo(posX, 118 - curCombo * ratioY);

					if (status >= 0 && status < 50 && fullcombo == true)
						lineColor = 0x00D42A;
					if (status >= 0 && status < 50 && fullcombo == false)
						lineColor = 0xFFFFFF;
				}
				if (songFile != null) {
					for each (var replayHit:ReplayNote in result.replay) {
						posX = (replayHit.frame * result.options.songRate + songFile.musicDelay) * ratioX;
						status = replayHit.score;
						switch (status) {
							case 25: // Good
								lineColor = 0x40aa40;
								break;
							case 5: // Average
								lineColor = 0xa0a000
								break;
							case 0: // Boo
								lineColor = 0x804010;
								break;
							case -10: // Miss
								lineColor = 0xFF0000;
								break;
							default:
								continue;
						}
						graphDraw.graphics.lineStyle(1, lineColor, 1, true);
						graphDraw.graphics.moveTo(posX - 2, -2);
						graphDraw.graphics.lineTo(posX + 2, 2);
						graphDraw.graphics.moveTo(posX + 2, -2);
						graphDraw.graphics.lineTo(posX - 2, 2);
					}
				}
			}
		}
		
		private function calculateCredits(score:int):int {
			return Math.max(0, Math.min(Math.floor(score / _gvars.SCORE_PER_CREDIT), _gvars.MAX_CREDITS));
		}
		
		private function getMaxCombo(gameResult:Object):int {
			var maxCombo:int = 0;
			var curCombo:int = 0;
			for (var x:int = 0; x < gameResult.replay_hit.length; x++) {
				var curNote:int = gameResult.replay_hit[x];
				if (curNote > 0) {
					curCombo += 1;
				} else if (curNote <= 0) {
					curCombo = 0;
				}
				if (curCombo > maxCombo)
					maxCombo = curCombo;
			}
			return maxCombo;
		}
		
		private function getScoreGrade(percent:Number, result:Object):String {
			if (percent == 100 && result.perfect == 0) {
				return "AAAA";
			} else if (percent == 100) {
				return "AAA";
			} else if (percent == 99) {
				return "AA";
			} else if (percent <= 99 && percent >= 95) {
				return "A";
			} else if (percent <= 94 && percent >= 85) {
				return "B";
			} else if (percent <= 84 && percent >= 75) {
				return "C";
			} else if (percent <= 74 && percent >= 65) {
				return "D";
			}
			return "E";
		}
		
		private function canSendScore(gameResult:Object = null, mods:Boolean = true, modsReplay:Boolean = true, score:Boolean = true, replay:Boolean = true):Boolean {
			return false;
		}
		
		// new function
		private function canUpdateScore(gameResult:Object = null, mods:Boolean = true, modsReplay:Boolean = true, score:Boolean = true, replay:Boolean = true):Boolean {
			return false;
		}

		
		private function eventHandler(e:* = null):void {
			var target:DisplayObject = e.target;
			
			// Don't do anything with popups open.
			if (_gvars.gameMain.current_popup != null)
				return;
			
			// Handle Key events and click in the same function
			if (e.type == "keyDown" && !_mp.gameplayPlayingStatusResults()) {
				target = null;
				var keyCode:int = e.keyCode;
				if ((keyCode == _gvars.playerUser.keyLeft || keyCode == Keyboard.LEFT) && navPrev.visible) {
					target = navPrev;
				} else if ((keyCode == _gvars.playerUser.keyRight || keyCode == Keyboard.RIGHT) && navNext.visible) {
					target = navNext;
				} else if (keyCode == _gvars.playerUser.keyRestart) {
					target = navReplay;
				} else if (keyCode == _gvars.playerUser.keyQuit) {
					target = navMenu;
					stage.removeEventListener(KeyboardEvent.KEY_DOWN, eventHandler);
				}
			}

			if (!target)
				return;
			
			// Based on target
			if (target == navScreenShot && navScreenShot.visible) {
				var ext:String = "";
				if (resultIndex >= 0) {
					var gRP:Object = songResults[resultIndex];
					var grS:Array = gRP.song;
					var rateString:String = gRP.options.songRate != 1 ? " (" + gRP.options.songRate + "x Rate)" : "";
					
					ext = "R^3 - " + grS.name + rateString + " - " + gRP.score + " - " + (gRP.perfect + gRP.amazing) + "-" + gRP.good + "-" + gRP.average + "-" + gRP.miss + "-" + gRP.boo;
				}
				_gvars.takeScreenShot({o: false, s: 1, text: ext});
			} else if (target == navPrev && navPrev.visible) {
				displayGameResult(resultIndex - 1);
			} else if (target == navNext && navNext.visible) {
				displayGameResult(resultIndex + 1);
			} else if (target == navReplay) {
				var skipload:Boolean = (songResults.length == 1 && songResults[0].songFile && songResults[0].songFile.isLoaded);
				if (!_gvars.options.replay || _gvars.flashvars.replay || _gvars.flashvars.preview_file)
					_gvars.options.fill();
				if (skipload) {
					_gvars.songRestarts++;
					switchTo(GameMenu.GAME_PLAY);
				} else {
					_gvars.songQueue = _gvars.totalSongQueue.concat();
					switchTo(GameMenu.GAME_LOADING);
				}
			} else if (target == navOptions) {
				addPopup(Main.POPUP_OPTIONS);
			} else if (target == navHighscores) {
				addPopup(new PopupHighscores(this, songResults[resultIndex].song));
			} else if (target == navMenu) {
				switchTo(Main.GAME_MENU_PANEL);
			} else if (target == navRating) {
				if(songResults[resultIndex]) {
					_gvars.gameMain.addPopup(new PopupSongRating(this, songResults[resultIndex]["song"]));
				}
			} else if (target == graphToggle) {
				graphType = (graphType + 1) % 2;
				LocalStore.setVariable("result_graph_type", graphType);
				drawResultGraph();
			}
		}
		
	}
}
