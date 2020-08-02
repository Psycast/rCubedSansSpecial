package {
	import assets.GameBackgroundOld;
	import com.adobe.serialization.json.JSONManager;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.Security;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	Security.allowDomain("www.flashflashrevolution.com");
	Security.allowDomain("flashflashrevolution.com");
	Security.allowDomain("www.flashfla.sh");
	Security.allowDomain("flashfla.sh");
	
	public class MainLoader extends Sprite {
		private const LOCAL_SO_NAME:String = "ede44360-366f-42a1-b333-40e4edccaa03";
		private const ENGINE_UPDATE_URL:String = "http://www.flashflashrevolution.com/game/r3/r3-siteEngine.php";
		private var uLoader:URLLoader;
		private var mLoader:Loader;
		
		private var textFormat:TextFormat = new TextFormat(new SegoeUI().fontName, 14, 0xFFFFFF, true);
		private var _textfield:TextField;
		
		public function MainLoader() {
			//- Setup JSON manager
			JSONManager.init();
			
			//- Init on Load Complete
			this.loaderInfo.addEventListener(Event.COMPLETE, gameInit);
		}
		
		private function gameInit(e:Event = null):void {
			// Remove Listeners
			if (e != null)
				removeEventListener(Event.COMPLETE, gameInit);
				
			// Background
			addChild(new GameBackgroundOld());
			
			// Loading Message
			_textfield = new TextField();
			_textfield.selectable = false;
			_textfield.embedFonts = true;
			_textfield.antiAliasType = AntiAliasType.ADVANCED;
			_textfield.autoSize = "center";
			_textfield.defaultTextFormat = textFormat;
			_textfield.text = "..: Loading R^3 - 0% :..";
			_textfield.x = 780 / 2 - _textfield.width / 2;
			_textfield.y = 480 / 2 - _textfield.height / 2;
			addChild(_textfield);
				
			// Get R^3 Revision
			uLoader = new URLLoader();
			addLoaderListeners();
			var url:Object = (ExternalInterface.available ? ExternalInterface.call("window.location.href.toString") : loaderInfo.loaderURL);
			var req:URLRequest = new URLRequest(ENGINE_UPDATE_URL + "?d=" + new Date().getTime());
			var requestVars:URLVariables = new URLVariables();
			requestVars.url = url == null ? loaderInfo.loaderURL : url;
			requestVars.mode = Security.sandboxType;
			requestVars.ver = 9;
			req.data = requestVars;
			req.method = URLRequestMethod.POST;
			uLoader.load(req);
		}
		
		private function siteLoadComplete(e:Event):void {
			removeLoaderListeners();
			var data:Object = JSONManager.decode(e.target.data);
			if (data.result == 1) {
				// Get Date to append to URL
				var gameSave:SharedObject = SharedObject.getLocal(LOCAL_SO_NAME);
				var urlDate:Number;
				if (gameSave.data.urlDate != data.time) {
					urlDate = new Date().getTime();
					gameSave.data.urlDate = urlDate;
					gameSave.flush();
				} else {
					urlDate = gameSave.data.urlDate;
				}
				
				// Load Engine
				var req:URLRequest = new URLRequest("http://www.flashflashrevolution.com/~velocity/P/R%5E3Game.swf?d=" + urlDate);
				mLoader = new Loader();
				mLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler);
				mLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgressHandler);
				mLoader.load(req);
			}
		}
		
		private function onCompleteHandler(loadEvent:Event):void {
			removeChild(_textfield);
			addChild(loadEvent.currentTarget.content);
		}
		
		private function onProgressHandler(mProgress:ProgressEvent):void {
			var percent:Number = (mProgress.bytesLoaded / mProgress.bytesTotal) * 100;
			_textfield.text = "..: Loading R^3 - " + Math.round(percent) + "% :..";
		}
		
		private function siteLoadError(e:Event = null):void {
			removeLoaderListeners();
		}
		
		private function addLoaderListeners():void {
			uLoader.addEventListener(Event.COMPLETE, siteLoadComplete);
			uLoader.addEventListener(IOErrorEvent.IO_ERROR, siteLoadError);
			uLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, siteLoadError);
		}
		
		private function removeLoaderListeners():void {
			uLoader.removeEventListener(Event.COMPLETE, siteLoadComplete);
			uLoader.removeEventListener(IOErrorEvent.IO_ERROR, siteLoadError);
			uLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, siteLoadError);
		}
	}
}