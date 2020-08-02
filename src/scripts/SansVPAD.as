package scripts
{
	import flash.ui.Keyboard;
	
	public class SansVPAD
	{
		public var L:int = 0;
		public var D:int = 0;
		public var U:int = 0;
		public var R:int = 0;
		public var Confirm:int = 0;
		public var Cancel:int = 0;
		public var Menu:int = 0;
		
		public var LastL:int = 0;
		public var LastD:int = 0;
		public var LastU:int = 0;
		public var LastR:int = 0;
		public var LastConfirm:int = 0;
		public var LastCancel:int = 0;
		public var LastMenu:int = 0;
		
		public function update(keyDowns:Array):void 
		{
			updateLast();
			
			// Reset
			this.L = 0;
			this.D = 0;
			this.U = 0;
			this.R = 0;
			this.Confirm = 0;
			this.Cancel = 0;
			this.Menu = 0;
			
			if (keyDowns[Keyboard.A] || keyDowns[Keyboard.LEFT]) this.L = 1;
			if (keyDowns[Keyboard.S] || keyDowns[Keyboard.DOWN]) this.D = 1;
			if (keyDowns[Keyboard.W] || keyDowns[Keyboard.UP]) this.U = 1;
			if (keyDowns[Keyboard.D] || keyDowns[Keyboard.RIGHT]) this.R = 1;
			if (keyDowns[Keyboard.Z] || keyDowns[Keyboard.ENTER]) this.Confirm = 1;
			if (keyDowns[Keyboard.X] || keyDowns[Keyboard.SHIFT]) this.Cancel = 1;
			if (keyDowns[Keyboard.C] || keyDowns[Keyboard.CONTROL]) this.Menu = 1;

			//this.Confirm = this.LastConfirm > 0 ? 0 : 1; // DEBUG / TODO
		}
		
		public function updateLast():void
		{
			LastL = L;
			LastD = D;
			LastU = U;
			LastR = R;
			LastConfirm = Confirm;
			LastCancel = Cancel;
			LastMenu = Menu;
		}
	}
}