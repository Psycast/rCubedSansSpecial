package game.controls {
	import classes.GameNote;
	import classes.GameReceptor;
	import classes.Noteskins;
	import classes.chart.Song;
	import classes.chart.Note;
	import flash.display.DisplayObject;
	import flash.utils.getTimer;
	import game.GameOptions;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import com.flashfla.utils.ObjectPool;

	public class NoteBox extends Sprite
	{
		private var _gvars:GlobalVariables = GlobalVariables.instance;
		private var _noteskins:Noteskins = Noteskins.instance;
		private var options:GameOptions;
		private var song:Song;

		private var scrollSpeed:Number;
		private var readahead:Number;
		private var totalNotes:int;
		private var noteCount:int;
		private var notePool:Array;
		public var notes:Array;

		public var receptorHeldDown:Array = [];
		public var leftReceptor:MovieClip;
		public var downReceptor:MovieClip;
		public var upReceptor:MovieClip;
		public var rightReceptor:MovieClip;
		public var receptorArray:Array;
		public var positionOffsetMax:Object;
		private var sideScroll:Boolean;
		private var receptorAlpha:Number;
		
		public function NoteBox(song:Song, options:GameOptions)
		{
			this.song = song;
			this.options = options;
			
			notes = [];
			notePool = [];
			for each (var item:Object in _noteskins.data) {
				notePool[item.id] = {"L": [], "D": [], "U": [], "R": []};
			}
			
			if(notePool[options.noteskin] == null)
				options.noteskin = 1;
				
			leftReceptor = _noteskins.getReceptor(options.noteskin, "L");
			leftReceptor.KEY = "Left";
			downReceptor = _noteskins.getReceptor(options.noteskin, "D");
			downReceptor.KEY = "Down";
			upReceptor = _noteskins.getReceptor(options.noteskin, "U");
			upReceptor.KEY = "Up";
			rightReceptor = _noteskins.getReceptor(options.noteskin, "R");
			rightReceptor.KEY = "Right";

			addChild(leftReceptor);
			addChild(downReceptor);
			addChild(upReceptor);
			addChild(rightReceptor);

			sideScroll = options.scrollDirection == "left" || options.scrollDirection == "right";
			scrollSpeed = options.scrollSpeed * (sideScroll ? 1.5 : 1);
			readahead = (sideScroll ? Main.GAME_WIDTH : Main.GAME_HEIGHT) / 300 * 1000 / scrollSpeed;
			receptorAlpha = 1.0;
			notes = new Array();
			noteCount = 0;
			totalNotes = song.totalNotes;
		}
		
		override public function set x(x:Number):void {
			super.x = x;
		}
		
		override public function set y(y:Number):void {
			readahead = (sideScroll ? _gvars.gameMain.stage.stageWidth + x : _gvars.gameMain.stage.stageHeight + y) / 300 * 1000 / scrollSpeed;
			super.y = y;
		}
		
		public function noteRealSpawnRotation(dir:String, noteskin:int):Number {
			var rot:Number = _noteskins.data[noteskin]["rotation"];
			switch (dir) {
				case "D": return 0;
				case "L": return rot;
				case "U": return rot * 2;
				case "R": return rot * -1;
			}
			return rot;
		}
		
		public function spawnArrow(note:Note, current_position:int = 0):GameNote
		{
			var direction:String = note.direction;
			var colour:String = options.getNewNoteColor(note.colour);
			var gameNote:GameNote;
			if (options.DISABLE_NOTE_POOL)
				gameNote = new GameNote(noteCount++, direction, colour, (note.time + 0.5 / 30) * 1000, note.frame, 0, options.noteskin);
			else {
				var pool:ObjectPool = notePool[options.noteskin][direction][colour];
				if (!pool)
					pool = notePool[options.noteskin][direction][colour] = new ObjectPool();
				gameNote = pool.getObject();
				if (gameNote) {
					gameNote.ID = noteCount++;
					gameNote.DIR = direction;
					gameNote.POSITION = (note.time + 0.5 / 30) * 1000;
					gameNote.PROGRESS = note.frame;
					gameNote.alpha = 1;
				} else
					gameNote = pool.addObject(new GameNote(noteCount++, direction, colour, (note.time + 0.5 / 30) * 1000, note.frame, 0, options.noteskin));
			}
			
			gameNote.SPAWN_PROGRESS = gameNote.POSITION - 1000;// readahead;
			gameNote.rotation = getReceptor(direction).rotation;
			
			if (options.modEnabled("_spawn_noteskin_data_rotation"))
				gameNote.rotation = noteRealSpawnRotation(direction, options.noteskin);
			
			if (options.noteScale != 1.0) {
				gameNote.scaleX = gameNote.scaleY = options.noteScale;
			}
			else if (options.modEnabled("mini") && !options.modEnabled("mini_resize") && options.noteScale == 1.0) {
				gameNote.scaleX = gameNote.scaleY = 0.75;
			} else {
				gameNote.scaleX = gameNote.scaleY = 1;
			}
			
			if (options.modEnabled("note_dark")) {
				gameNote.alpha = 0.2;
			}
			
			addChild(gameNote);
			notes.push(gameNote);

			updateNotePosition(gameNote, current_position);

			return gameNote;
		}

		public function getReceptor(dir:String):MovieClip
		{
			switch (dir) {
				case "L": return leftReceptor;
				case "D": return downReceptor;
				case "U": return upReceptor;
				case "R": return rightReceptor;
			}
			return null;
		}

		public function receptorFeedback(dir:String, score:int):void
		{
			var f:int = 2;
			var c:uint = 0;
			
			switch (score) {
				case 100:
				case 50:
					f = 2;
					c = options.judgeColours[0];
					break;
				case 25:
					f = 7;
					c = options.judgeColours[2];
					break;
				case 5:
				case -5:
					f = 12;
					c = options.judgeColours[3];
					break;
				default:
					return;
			}
			var rec:MovieClip = getReceptor(dir);
			if (rec is GameReceptor)
				(rec as GameReceptor).playAnimation(c);
			else
				rec.gotoAndPlay(f);
		}
		
		public function receptorHeld(dir:String, down:Boolean = true):void
		{
			receptorHeldDown[dir] = down;
			getReceptor(dir).gotoAndStop(down ? 14 : 1);
		}

		public function get nextNote():Note
		{
			return noteCount < totalNotes ? song.getNote(noteCount) : null;
		}

		public function spawnNextNote(current_position:int = 0):GameNote
		{
			var next:Note = nextNote;
			if (next)
				return spawnArrow(next, current_position);
			return null;
		}

		public function update(position:int):void
		{
			var next:Note = nextNote;
			while (next && (next.time + 0.5 / 30) * 1000 - position < readahead) {
				spawnArrow(next, position);
				next = nextNote;
			}
			
			if (options.modEnabled("wave")) {
				var waveOffset:int = 0;
				for each (var receptor:MovieClip in receptorArray) {
					if (receptor.VERTEX == "x") {
						receptor.y = receptor.ORIG_Y + (Math.sin((getTimer() + waveOffset) / 1000) * 35);
					} else if (receptor.VERTEX == "y") {
						receptor.x = receptor.ORIG_X + (Math.sin((getTimer() + waveOffset) / 1000) * 35);
					}
					waveOffset += 165;
				}
			}
			if (options.modEnabled("drunk")) {
				var drunkOffset:int = 0;
				for each (receptor in receptorArray) {
					receptor.rotation = receptor.ORIG_ROT + (Math.sin((getTimer() + drunkOffset) / 1387) * 25);
					drunkOffset += 165;
				}
			}
			if (options.modEnabled("dizzy")) {
				for each (receptor in receptorArray) {
					receptor.rotation += 12;
				}
			}
			
			if (options.modEnabled("hide")) {
				leftReceptor.alpha = (leftReceptor.currentFrame == 1) ? 0.0 : receptorAlpha;
				downReceptor.alpha = (downReceptor.currentFrame == 1) ? 0.0 : receptorAlpha;
				upReceptor.alpha = (upReceptor.currentFrame == 1) ? 0.0 : receptorAlpha;
				rightReceptor.alpha = (rightReceptor.currentFrame == 1) ? 0.0 : receptorAlpha;
			}
			
			for (var name:String in receptorHeldDown) 
			{
				if (receptorHeldDown[name]) {
					var re:MovieClip = getReceptor(name);
					if (re.currentFrame == 1) {
						receptorHeld(name, true);
					}
				}
			}
			
			for each (var note:GameNote in notes)
				updateNotePosition(note, position);
			/*
			
			this.graphics.clear();
			
			if (notes.length > 0) {
				var lastN:GameNote;
				this.graphics.moveTo(notes[0].x, notes[0].y);
				for (var n:int = 0; n < notes.length; n++) {
					this.graphics.lineStyle(1, 0xffffff, 1);
					if (lastN && notes[n].POSITION == lastN.POSITION) {
						this.graphics.lineStyle(1, 0xFF0000, 1);
						this.graphics.lineTo(notes[n].x, notes[n].y);
						continue;
					}
					if (lastN && notes[n].POSITION != lastN.POSITION) {
						this.graphics.moveTo(lastN.x, lastN.y);
					}
					lastN = notes[n];
					this.graphics.lineTo(notes[n].x, notes[n].y);
				}
			}
			if (song.totalNotes > 0 && (noteCount == 0 || (notes.length > 0 && notes[0].ID == 0))) {
				var i:int = 0;
				if (noteCount == 0) {
					while (song.getNote(0).getFrame() == song.getNote(i).getFrame()) {
						var al:Number = (((position / 1000) / song.getNote(i).getPos()) / 0.75);
						this.graphics.lineStyle(1, 0xffffff, al);
						var tepr:MovieClip = getReceptor(song.getNote(i).getDir());
						this.graphics.moveTo(tepr.x, tepr.y);
						if (tepr.VERTEX == "x") {
							this.graphics.lineTo(tepr.x - readahead * tepr.DIRECTION, tepr.y);
						} else if (tepr.VERTEX == "y") {
							this.graphics.lineTo(tepr.x, tepr.y - readahead * tepr.DIRECTION);
						}
						i++;
					}
				} else {
					this.graphics.lineStyle(1, 0xffffff, 1);
					while(notes[0].POSITION == notes[i].POSITION) {
						var tepr2:MovieClip = getReceptor(notes[i].DIR);
						this.graphics.moveTo(tepr2.x, tepr2.y);
						this.graphics.lineTo(notes[i].x, notes[i].y);
						i++;
						if (i >= notes.length) break;
					}
				}
			}
			*/
		}

		public function updateNotePosition(note:GameNote, position:int):void
		{
			var receptor:MovieClip = getReceptor(note.DIR);
			var offset:Number = (note.POSITION - position) / 1000 * 300 * scrollSpeed;
			var base_offset:Number = (position - note.SPAWN_PROGRESS) / (note.POSITION - note.SPAWN_PROGRESS);
			//var base_offset:Number = Math.max(Math.min((note.POSITION - position) / 1000, 1), 0);
			
			if (receptor.VERTEX == "x") {
				note.x = receptor.x - offset * receptor.DIRECTION;
				note.y = receptor.y;
			} else if (receptor.VERTEX == "y") {
				note.y = receptor.y - offset * receptor.DIRECTION;
				note.x = receptor.x;
			}
			
			// Position Mods
			if(options.modEnabled("tornado")) {
				var tornadoOffset:Number = Math.sin(base_offset * Math.PI) * (options.receptorSpacing / 2);
				if (receptor.VERTEX == "x") {
					note.y += tornadoOffset;
				}
				if (receptor.VERTEX == "y") {
					note.x += tornadoOffset;
				}
			}
			
			// Rotation Mods
			if (options.modEnabled("rotating")) {
				note.rotation = (base_offset * 6 * 90) + receptor.rotation;
			}
			
			if (options.modEnabled("dizzy")) {
				note.rotation += 18;
			}
			
			// Alpha Mods
			// switched hidden and sudden, mods were reversed!
			if (options.modEnabled("hidden")) {
				note.alpha = 1 - base_offset;
			}
			
			if (options.modEnabled("sudden")) {
				note.alpha = base_offset;
			}
			
			if (options.modEnabled("blink")) {
				var blink_offset:Number = (1 - base_offset) % 0.4;
				var blink_hidden:Boolean = (blink_offset > 0.2);
				note.alpha = (blink_hidden ? 0 : (note.alpha != 1 && note.alpha != 0 ? note.alpha : 1));
			}
			
			// Scale Mods
			if (options.noteScale == 1 && options.modEnabled("mini_resize") && !options.modEnabled("mini")) {
				note.scaleX = note.scaleY = 1 - (base_offset * 0.65);
			}
			
		}

		public function removeNote(id:int):void
		{
			for (var i:int = 0; i < notes.length; i++) {
				var note:GameNote = notes[i];
				if (note.ID == id) {
					if(!options.DISABLE_NOTE_POOL)
						notePool[note.NOTESKIN][note.DIR][note.COLOR].unmarkObject(note);
					removeChild(note);
					notes.splice(i, 1);
					break;
				}
			}
		}

		public function reset():void
		{
			for each (var note:GameNote in notes) {
				if(!options.DISABLE_NOTE_POOL)
					notePool[note.NOTESKIN][note.DIR][note.COLOR].unmarkObject(note);
				removeChild(note);
			}
			notes = new Array();
			noteCount = 0;
		}

		public function resetNoteCount(value:int):void
		{
			noteCount = value;
		}

		public function position():void
		{
			var data:Object = _noteskins.getInfo(options.noteskin);
			var rotation:Number = data.rotation;
			var gap:int = options.receptorSpacing;
			var noteScale:Number = options.noteScale;
			var centerOffset:int = 160;
			
			//if (data.width > 64)
				//gap += data.width - 64;
			
			// User-defined note scale
			if (noteScale != 1) {
				if (noteScale < 0.1) noteScale = 0.1; // min
				else if (noteScale > 2.0) noteScale = 2.0; // max
				gap *= noteScale
			} else if (options.modEnabled("mini") && !options.modEnabled("mini_resize")) {
				gap *= 0.75;
			}
				
			switch (options.scrollDirection) {
				case "down":
					downReceptor.x = int(-gap / 2) + centerOffset;
					downReceptor.y = 400;
					downReceptor.rotation = 0;
					downReceptor.VERTEX = "y";
					downReceptor.DIRECTION = 1;

					leftReceptor.x = downReceptor.x - gap;
					leftReceptor.y = downReceptor.y;
					leftReceptor.rotation = rotation;
					leftReceptor.VERTEX = "y";
					leftReceptor.DIRECTION = 1;

					upReceptor.x = int(gap / 2) + centerOffset;
					upReceptor.y = downReceptor.y;
					upReceptor.rotation = rotation * 2;
					upReceptor.VERTEX = "y";
					upReceptor.DIRECTION = 1;

					rightReceptor.x = upReceptor.x + gap;
					rightReceptor.y = downReceptor.y;
					rightReceptor.rotation = rotation * -1;
					rightReceptor.VERTEX = "y";
					rightReceptor.DIRECTION = 1;
					
					receptorArray = [leftReceptor, downReceptor, upReceptor, rightReceptor];
					positionOffsetMax = { "min_x": -150, "max_x": 150, "min_y": -150, "max_y": 50 };
					break;
				case "right":
					centerOffset += 80;
					leftReceptor.x = 460;
					leftReceptor.y = int(gap / 2) + centerOffset + gap;
					leftReceptor.rotation = rotation;
					leftReceptor.VERTEX = "x";
					leftReceptor.DIRECTION = 1;

					upReceptor.x = leftReceptor.x;
					upReceptor.y = int(-gap / 2) + centerOffset;
					upReceptor.rotation = rotation * 2;
					upReceptor.VERTEX = "x";
					upReceptor.DIRECTION = 1;

					rightReceptor.x = leftReceptor.x;
					rightReceptor.y = int(-gap / 2) + centerOffset - gap
					rightReceptor.rotation = rotation * -1;
					rightReceptor.VERTEX = "x";
					rightReceptor.DIRECTION = 1;

					downReceptor.x = leftReceptor.x;
					downReceptor.y = int(gap / 2) + centerOffset;
					downReceptor.rotation = 0;
					downReceptor.VERTEX = "x";
					downReceptor.DIRECTION = 1;
					
					receptorArray = [upReceptor, rightReceptor, leftReceptor, downReceptor];
					positionOffsetMax = { "min_x": -150, "max_x": 50, "min_y": -120, "max_y": 120 };
					break;
				case "left":
					centerOffset += 80;
					leftReceptor.x = -140;
					leftReceptor.y = int(gap / 2) + centerOffset + gap;
					leftReceptor.rotation = rotation;
					leftReceptor.VERTEX = "x";
					leftReceptor.DIRECTION = -1;

					upReceptor.x = leftReceptor.x;
					upReceptor.y = int(-gap / 2) + centerOffset;
					upReceptor.rotation = rotation * 2;
					upReceptor.VERTEX = "x";
					upReceptor.DIRECTION = -1;

					rightReceptor.x = leftReceptor.x;
					rightReceptor.y = int(-gap / 2) + centerOffset - gap
					rightReceptor.rotation = rotation * -1;
					rightReceptor.VERTEX = "x";
					rightReceptor.DIRECTION = -1;

					downReceptor.x = leftReceptor.x;
					downReceptor.y = int(gap / 2) + centerOffset;
					downReceptor.rotation = 0;
					downReceptor.VERTEX = "x";
					downReceptor.DIRECTION = -1;
					
					receptorArray = [upReceptor, rightReceptor, leftReceptor, downReceptor];
					positionOffsetMax = { "min_x": -50, "max_x": 150, "min_y": -120, "max_y": 120 };
					break;
				case "split":
					downReceptor.x = int(-gap / 2) + centerOffset;
					downReceptor.y = 400;
					downReceptor.rotation = 0;
					downReceptor.VERTEX = "y";
					downReceptor.DIRECTION = 1;

					leftReceptor.x = downReceptor.x - gap;
					leftReceptor.y = 90;
					leftReceptor.rotation = rotation;
					leftReceptor.VERTEX = "y";
					leftReceptor.DIRECTION = -1;

					upReceptor.x = int(gap / 2) + centerOffset;
					upReceptor.y = 400;
					upReceptor.rotation = rotation * 2;
					upReceptor.VERTEX = "y";
					upReceptor.DIRECTION = 1;

					rightReceptor.x = upReceptor.x + gap;
					rightReceptor.y = 90;
					rightReceptor.rotation = rotation * -1;
					rightReceptor.VERTEX = "y";
					rightReceptor.DIRECTION = -1;
					
					receptorArray = [leftReceptor, downReceptor, upReceptor, rightReceptor];
					positionOffsetMax = { "min_x": -150, "max_x": 150, "min_y": -50, "max_y": 50 };
					break;
				case "split_down":
					downReceptor.x = int(-gap / 2) + centerOffset;
					downReceptor.y = 90;
					downReceptor.rotation = 0;
					downReceptor.VERTEX = "y";
					downReceptor.DIRECTION = -1;

					leftReceptor.x = downReceptor.x - gap;
					leftReceptor.y = 400;
					leftReceptor.rotation = rotation;
					leftReceptor.VERTEX = "y";
					leftReceptor.DIRECTION = 1;

					upReceptor.x = int(gap / 2) + centerOffset;
					upReceptor.y = 90;
					upReceptor.rotation = rotation * 2;
					upReceptor.VERTEX = "y";
					upReceptor.DIRECTION = -1;

					rightReceptor.x = upReceptor.x + gap;
					rightReceptor.y = 400;
					rightReceptor.rotation = rotation * -1;
					rightReceptor.VERTEX = "y";
					rightReceptor.DIRECTION = 1;
					
					receptorArray = [leftReceptor, downReceptor, upReceptor, rightReceptor];
					positionOffsetMax = { "min_x": -150, "max_x": 150, "min_y": -50, "max_y": 50 };
					break;
				case "plus":
					downReceptor.x = centerOffset;
					downReceptor.y = centerOffset + 80 + int(gap / 2);
					downReceptor.rotation = 0;
					downReceptor.VERTEX = "y";
					downReceptor.DIRECTION = -1;

					leftReceptor.x = centerOffset - int(gap / 2);
					leftReceptor.y = centerOffset + 80;
					leftReceptor.rotation = rotation;
					leftReceptor.VERTEX = "x";
					leftReceptor.DIRECTION = 1;

					upReceptor.x = centerOffset;
					upReceptor.y = centerOffset + 80 - int(gap / 2);
					upReceptor.rotation = rotation * 2;
					upReceptor.VERTEX = "y";
					upReceptor.DIRECTION = 1;

					rightReceptor.x = centerOffset + int(gap / 2);
					rightReceptor.y = centerOffset + 80;
					rightReceptor.rotation = rotation * -1;
					rightReceptor.VERTEX = "x";
					rightReceptor.DIRECTION = -1;
					
					receptorArray = [upReceptor, rightReceptor, downReceptor, leftReceptor];
					positionOffsetMax = { "min_x": -150, "max_x": 150, "min_y": -150, "max_y": 150 };
					break;
				default:
					downReceptor.x = int(-gap / 2) + centerOffset;
					downReceptor.y = 90;
					downReceptor.rotation = 0;
					downReceptor.VERTEX = "y";
					downReceptor.DIRECTION = -1;

					leftReceptor.x = downReceptor.x - gap;
					leftReceptor.y = downReceptor.y;
					leftReceptor.rotation = rotation;
					leftReceptor.VERTEX = "y";
					leftReceptor.DIRECTION = -1;

					upReceptor.x = int(gap / 2) + centerOffset;
					upReceptor.y = downReceptor.y;
					upReceptor.rotation = rotation * 2;
					upReceptor.VERTEX = "y";
					upReceptor.DIRECTION = -1;

					rightReceptor.x = upReceptor.x + gap;
					rightReceptor.y = downReceptor.y;
					rightReceptor.rotation = rotation * -1;
					rightReceptor.VERTEX = "y";
					rightReceptor.DIRECTION = -1;
					
					receptorArray = [leftReceptor, downReceptor, upReceptor, rightReceptor];
					positionOffsetMax = { "min_x": -150, "max_x": 150, "min_y": -50, "max_y": 150 };
					break;
			}
			
			for each (var item:MovieClip in receptorArray) {
				item.ORIG_X = item.x;
				item.ORIG_Y = item.y;
				item.ORIG_ROT = item.rotation;
			}
			
			if (options.modEnabled("rotate_cw")) {
				leftReceptor.rotation += 90;
				downReceptor.rotation += 90;
				upReceptor.rotation += 90;
				rightReceptor.rotation += 90;
			}
			if (options.modEnabled("rotate_ccw")) {
				leftReceptor.rotation -= 90;
				downReceptor.rotation -= 90;
				upReceptor.rotation -= 90;
				rightReceptor.rotation -= 90;
			}
			
			if (options.noteScale != 1.0)
				downReceptor.scaleX 	= downReceptor.scaleY 	= 
				leftReceptor.scaleX 	= leftReceptor.scaleY 	= 
				upReceptor.scaleX		= upReceptor.scaleY 	= 
				rightReceptor.scaleX 	= rightReceptor.scaleY 	= options.noteScale;
			
			if(options.modEnabled("mini") && !options.modEnabled("mini_resize") && options.noteScale == 1.0)
				downReceptor.scaleX 	= downReceptor.scaleY 	= 
				leftReceptor.scaleX 	= leftReceptor.scaleY 	= 
				upReceptor.scaleX		= upReceptor.scaleY 	= 
				rightReceptor.scaleX 	= rightReceptor.scaleY 	= 0.75;
				
				
			if(options.modEnabled("mini_resize") && !options.modEnabled("mini") && options.noteScale == 1.0)
				downReceptor.scaleX 	= downReceptor.scaleY 	= 
				leftReceptor.scaleX 	= leftReceptor.scaleY 	= 
				upReceptor.scaleX		= upReceptor.scaleY 	= 
				rightReceptor.scaleX 	= rightReceptor.scaleY 	= 0.5;
				
			if (options.modEnabled("dark"))
				receptorAlpha = 0.3;
			
			leftReceptor.alpha = downReceptor.alpha = upReceptor.alpha = rightReceptor.alpha = receptorAlpha;
		}
	}
}
