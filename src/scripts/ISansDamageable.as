package scripts
{
    import flash.display.Sprite;

    public interface ISansDamageable
    {
        function getHitbox():Sprite;
        function getColor():int;

        function getDamage():int;
        function getKarma():int;
        function setKarma(val:int):void;
    }
}