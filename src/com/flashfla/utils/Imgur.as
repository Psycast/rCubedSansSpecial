package com.flashfla.utils {
	import by.blooddy.crypto.image.PNGEncoder;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.SecurityErrorEvent;
	import flash.events.IOErrorEvent
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	
	public class Imgur extends EventDispatcher {
		private var loader:URLLoader;
		
		public static const LOAD_COMPLETE:String = "ImgurLoadComplete";
		public static const LOAD_ERROR:String = "ImgurLoadFailure";
		
		private const API_KEY:String = "1eed92321549a732c8ec059830b26be0";
		private const UPLOAD_URL:String = "http://api.imgur.com/2/upload.json";
		private const CREDITS_URL:String = "http://api.imgur.com/2/credits.json";
		
		public var RESPONSE:String = "";
		
		public var loadAttempts:int = 0;
		
		// Credits
		public var remaining:int = -1;
		public var limit:int = -1;
		public var reset:int = -1;
		public var refresh:int = -1;
		
		public function Imgur() {
			//update();
		}
		
		public function update():void {
			if (loadAttempts < 5) {
				loader = new URLLoader();
				loader.addEventListener(Event.COMPLETE, onCreditsComplete);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onCreditsError);
				loader.addEventListener(IOErrorEvent.IO_ERROR, onCreditsError);
				
				var req:URLRequest = new URLRequest(CREDITS_URL + "?date=" + new Date().getTime()); // Append Time to prevent caching.
				loader.load(req);
			} else {
				trace("3:Imgur API load failed too many times.");
				remaining = 0;
			}
		}
		
		private function onCreditsComplete(e:Event):void {
			loader.removeEventListener(Event.COMPLETE, onCreditsComplete);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onCreditsError);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onCreditsError);
			
			if (e.target.data != "") {
				try {
					var imgurCredits:Object = JSON.parse(e.target.data);
				} catch (e:Error) {
					trace("3:Imgur is having problems....");
					loadAttempts++;
					update();
					return;
				}
				
				loadAttempts = 0;
				remaining = imgurCredits["credits"]["remaining"];
				limit = imgurCredits["credits"]["limit"];
				reset = imgurCredits["credits"]["reset"];
				refresh = imgurCredits["credits"]["refresh_in_secs"];
				
				trace("4:==============================================");
				trace("4:Imgur: Credits Remaining: " + remaining);
				trace("4:Imgur: Credits Refreshing in: " + TimeUtil.convertToHHMMSS(refresh));
				trace("4:==============================================");
			} else {
				trace("3:Blank Imgur API JSON, refreshing...");
				loadAttempts++;
				update();
			}
		}
		
		private function onCreditsError(e:Event = null):void {
			loader.removeEventListener(Event.COMPLETE, onCreditsComplete);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onCreditsError);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onCreditsError);
			trace("3:Imgur API JSON never loaded, refreshing...");
			loadAttempts++;
			update();
		}
		
		public function upload(b:BitmapData, imgName:String, imgTitle:String):void {
			// Make Loader
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			
			// Encode the bitmap data
			var png:ByteArray = PNGEncoder.encode(b);
			
			// Make server request
			var vars:String = "?key=" + API_KEY + "&name=R%5E3-" + imgName + "&title=" + imgTitle;
			var request:URLRequest = new URLRequest(UPLOAD_URL + vars);
			request.contentType = "application/octet-stream";
			request.method = URLRequestMethod.POST;
			request.data = png; // set the data object of the request to your image.
			
			// Send to server
			loader.load(request);
		}
		
		// privates
		private function onComplete(e:Event):void {
			RESPONSE = e.target.data;
			
			loader.removeEventListener(Event.COMPLETE, onComplete);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			
			this.dispatchEvent(new Event(LOAD_COMPLETE));
			
			update();
		}
		
		private function onError(e:Event = null):void {
			loader.removeEventListener(Event.COMPLETE, onComplete);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			
			this.dispatchEvent(new Event(LOAD_ERROR));
		}
	
	}
}
