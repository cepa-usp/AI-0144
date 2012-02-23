package 
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Bacterias extends Sprite
	{
		public static const BACTERIA_TOPO:String = "bacteria_topo";
		public static const BACTERIA_MEIO:String = "bacteria_meio";
		public static const BACTERIA_FUNDO:String = "bacteria_fundo";
		
		private var color:uint;
		
		public function Bacterias(type:String) 
		{
			if (type == BACTERIA_TOPO) color = 0x0000FF;
			else if (type == BACTERIA_MEIO) color = 0xFFFF00;
			else color = 0xFF0000;
			
			drawBacteria();
		}
		
		private function drawBacteria():void 
		{
			graphics.beginFill(color);
			//graphics.drawCircle(0, 0, 2);
			graphics.drawRect(-1, -1, 2, 2);
		}
		
	}

}