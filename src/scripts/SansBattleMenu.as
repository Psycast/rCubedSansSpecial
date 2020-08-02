package scripts 
{
	import ext.scripts.SansMenuActGraphic;
	import ext.scripts.SansMenuFightGraphic;
	import ext.scripts.SansMenuItemGraphic;
	import ext.scripts.SansMenuMercyGraphic;
	import flash.display.Sprite;
	
	public class SansBattleMenu extends Sprite 
	{
		public var btnAttack:SansBattleMenuButton;
		public var btnAct:SansBattleMenuButton;
		public var btnItem:SansBattleMenuButton;
		public var btnMercy:SansBattleMenuButton;
		
		public var activeIndex:int = 0;
		
		public function SansBattleMenu(container:SansAttackContainer) 
		{
			btnAttack = new SansBattleMenuButton(this, new SansMenuFightGraphic());
			btnAttack.x = 32;
			btnAttack.ID = 0;
			btnAttack.Action = "MenuFight";
			
			btnAct = new SansBattleMenuButton(this, new SansMenuActGraphic());
			btnAct.x = 184;
			btnAct.ID = 1;
			btnAct.Action = "MenuAct";
			
			btnItem = new SansBattleMenuButton(this, new SansMenuItemGraphic());
			btnItem.x = 344;
			btnItem.ID = 2;
			btnItem.Action = "MenuItem";
			
			btnMercy = new SansBattleMenuButton(this, new SansMenuMercyGraphic());
			btnMercy.x = 496;
			btnMercy.ID = 3;
			btnMercy.Action = "MenuMercy";
			
			btnAttack.y = btnAct.y = btnItem.y = btnMercy.y = 432;
			
			container.layer_buttons.addChild(this);
		}

		public function get UIButtons():Array{
			return [btnAttack, btnAct, btnItem, btnMercy];
		}
		
	}

}