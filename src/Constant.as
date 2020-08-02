package {
	import flash.display.Loader;
	import flash.net.URLVariables;
	import flash.system.LoaderContext;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class Constant {
		public static const ROOT_URL:String = "http://www.flashflashrevolution.com/";
		
		public static const SITE_DATA_URL:String = ROOT_URL + "game/r3/r3-siteData.v2.php";
		public static const SITE_LOGIN_URL:String = ROOT_URL + "game/r3/r3-siteLogin.php";
		public static const SITE_REPLAY_URL:String = ROOT_URL + "game/r3/r3-siteReplay.php";
		public static const USER_INFO_URL:String = ROOT_URL + "game/r3/r3-userInfo.php";
		public static const USER_SMALL_INFO_URL:String = ROOT_URL + "game/r3/r3-userSmallInfo.php";
		public static const USER_SETTINGS_URL:String = ROOT_URL + "game/r3/r3-userSettings.php";
		public static const USER_FRIENDS_URL:String = ROOT_URL + "game/r3/r3-userFriends.php";
		public static const USER_REPLAY_URL:String = ROOT_URL + "game/r3/r3-userReplay.php";
		public static const USER_RANKS_URL:String = ROOT_URL + "game/r3/r3-userRanks.php";
		public static const USER_RANKS_UPDATE_URL:String = ROOT_URL + "game/r3/r3-userRankUpdate.php";
		public static const USER_AVATAR_URL:String = ROOT_URL + "avatar_imgembedded.php";
		public static const HISCORES_URL:String = ROOT_URL + "game/r3/r3-hiscores.php";
		public static const PLAYLIST_URL:String = ROOT_URL + "game/r3/r3-playlist.php";
		public static const LANGUAGE_URL:String = ROOT_URL + "game/r3/r3-language.php";
		public static const NOTESKIN_URL:String = ROOT_URL + "game/r3/r3-noteSkins.xml";
		public static const NOTESKIN_SWF_URL:String = ROOT_URL + "game/r3/noteskins/";
		public static const SONG_DATA_URL:String = ROOT_URL + "game/r3/r3-songLoad.php";
		public static const SONG_START_URL:String = ROOT_URL + "game/r3/r3-songStart.php";
		public static const SONG_SAVE_URL:String = ROOT_URL + "game/r3/r3-songSave.php";
		static public const ALT_SONG_SAVE_URL:String = ROOT_URL + "game/r3/r3-songSaveOther.php";
		public static const SCREENSHOT_URL:String = ROOT_URL + "game/r3/r3-screenshot.php";
		public static const SONG_RATING_URL:String = ROOT_URL + "game/r3/r3-songRating.php";
		public static const ANALYTICS_URL:String = ROOT_URL + "game/r3/r3-analytics.php";
		public static const MULTIPLAYER_SUBMIT_URL:String = ROOT_URL + "game/ffr-legacy_multiplayer.php";
		public static const MULTIPLAYER_SUBMIT_URL_VELOCITY:String = ROOT_URL + "game/ffr-velocity_multiplayer.php";
		public static const LEVEL_STATS_URL:String = ROOT_URL + "levelstats.php?level=";
		public static const LEGACY_GENRE:int = 13;
		
		CONFIG::air {
			public static const MENU_MUSIC_PATH:String = "menu_music.swf";
			public static const MENU_MUSIC_MP3_PATH:String = "menu_music.mp3"
			public static const REPLAY_PATH:String = "replays/";
			public static const SONG_CACHE_PATH:String = "song_cache/";
			public static const AIR_VERSION:String = "9.9.9";
			public static const AIR_WINDOW_TITLE:String = "FFR R^3 [" + AIR_VERSION + "] - Sans Battle Edition";
		}

		// Embed Fonts
		ArialUnicodeMS;
		SegoeUI;
		SegoeUIBold;
		SegoeUISemibold;
		
		//- Other
		public static const LOCAL_SO_NAME:String = "90579262-509d-4370-9c2e-564667e511d7";
		public static const VERSION:int = 3;
		public static const TEXT_FORMAT:TextFormat = new TextFormat("Segoe UI", 14, 0xFFFFFF, true);
		public static const TEXT_FORMAT_12:TextFormat = new TextFormat("Segoe UI", 12, 0xFFFFFF, true);
		public static const TEXT_FORMAT_CENTER:TextFormat = new TextFormat("Segoe UI", 14, 0xFFFFFF, true, null, null, null, null, TextFormatAlign.CENTER);
		public static const TEXT_FORMAT_UNICODE:TextFormat = new TextFormat("Arial Unicode MS Bold", 14, 0xFFFFFF, true);
		public static const TEXT_FORMAT_UNICODE_12:TextFormat = new TextFormat("Arial Unicode MS Bold", 12, 0xFFFFFF, true);
		public static const JUDGE_WINDOW:Array = [{t:-118, s:5, f:-3}, {t:-85, s:25, f:-2}, {t:-51, s:50, f:-1}, {t:-18, s:100, f:0}, {t:17, s:50, f:1}, {t:50, s:25, f:2}, {t:84, s:25, f:3}, {t:117, s:0}];
		
		//- Functions
		public static function cleanScrollDirection(dir:String):String {
			dir = dir.toLowerCase();
			
			if(dir == "slideright") 	return "right"; 		// FFR Legacy/Velocity
			if(dir == "slideleft") 		return "left"; 			// FFR Legacy/Velocity
			if(dir == "rising") 		return "up"; 			// FFR Legacy/Velocity
			if(dir == "falling") 		return "down"; 			// FFR Legacy/Velocity
			if(dir == "diagonalley") 	return "diagonalley"; 	// FFR Legacy/Velocity
			if(dir == "right") 			return "right"; 		// R^2/3
			if(dir == "left") 			return "left"; 			// R^2/3
			if(dir == "up") 			return "up"; 			// R^2/3
			if(dir == "down") 			return "down"; 			// R^2/3
			if(dir == "split") 			return "split"; 		// R^2/3
			if(dir == "split_down") 	return "split_down"; 	// R^2/3
			if(dir == "plus") 			return "plus"; 			// R^2/3
			return dir;
		}
		
		static public function addDefaultRequestVariables(requestVars:URLVariables):void 
		{
			requestVars['ver'] = Constant.VERSION;
			requestVars['is_air'] = CONFIG::air;
			
			CONFIG::air { 
				requestVars['air_ver'] = Constant.AIR_VERSION;
			}
		}
	}
}
