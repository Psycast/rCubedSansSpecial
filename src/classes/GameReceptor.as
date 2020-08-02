package classes
{
	import com.greensock.TweenLite;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	public dynamic class GameReceptor extends MovieClip
	{
		private var _note:MovieClip;
		public var DIR:String;
		
		public function GameReceptor(dir:String, bitmap:BitmapData)
		{
			this.DIR = dir;
			
			_note = new MovieClip();
			_note.graphics.beginBitmapFill(bitmap);
			_note.graphics.drawRect(0, 0, bitmap.width, bitmap.height);
			_note.graphics.endFill();
			
			_note.x = -(bitmap.width >> 1);
			_note.y = -(bitmap.height >> 1);
			this.addChild(_note);
		}
		
		public function playAnimation(color:uint):void
		{
			_note.scaleX = _note.scaleY = 1;
			TweenLite.to(_note, 3, {scaleX: 1.25, scaleY: 1.25, tint: color, useFrames: true, onUpdate: update, onComplete: function():void
			{
				TweenLite.to(_note, 2, {scaleX: 1, scaleY: 1, tint: null, useFrames: true, onUpdate: update});
			}});
		}
		
		private function update():void
		{
			_note.x = -(_note.width >> 1);
			_note.y = -(_note.height >> 1);
		}
		
		public function dispose():void
		{
			if (_note != null && this.contains(_note))
				this.removeChild(_note);
			_note = null;
		}
	
	}

}