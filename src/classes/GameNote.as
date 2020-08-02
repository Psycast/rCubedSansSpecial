package classes {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	public class GameNote extends Sprite {
		private static var _noteskins:Noteskins = Noteskins.instance;
		
		private var _note:MovieClip;
		public var NOTESKIN:int = 0;
		public var ID:int = 0;
		public var DIR:String;
		public var COLOR:String;
		public var POSITION:int = 0;
		public var PROGRESS:int = 0;
		public var PLAYER:int = 0;
		public var SPAWN_PROGRESS:int = 0;
		
		public function GameNote(id:int, dir:String, color:String, position:int = 0, progress:int = 0, player:int = 0, activeNoteSkin:int = 1) {
			this.NOTESKIN = activeNoteSkin;
			this.ID = id;
			this.DIR = dir;
			this.COLOR = color;
			this.POSITION = position;
			this.PROGRESS = progress;
			this.PLAYER = player;
			
			var _noteInfo:Object = _noteskins.getInfo(activeNoteSkin);
			_note = _noteskins.getNote(activeNoteSkin, this.COLOR, this.DIR);
			_note.x = -(_noteInfo.width >> 1);
			_note.y = -(_noteInfo.height >> 1);
			this.addChild(_note);
		}
		
		public function dispose():void {
			if (_note != null && this.contains(_note))
				this.removeChild(_note);
			_note = null;
		}
	
	}

}