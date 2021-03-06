package 
{
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class TuboEnsaio extends Sprite
	{
		private var alturaTubo:Number = 174;
		private var larguraTubo:Number = 40;
		
		private var timer_topo:Timer;
		private var timer_meio:Timer;
		private var timer_fundo:Timer;
		
		private var bacterias_topo:Array = [];
		private var bacterias_meio:Array = [];
		private var bacterias_fundo:Array = [];
		
		private var minTime:Number = 300;
		
		public function TuboEnsaio() 
		{
			//alturaTubo = this.height;
			//larguraTubo = this.width;
		}
		
		public function colocaBacteria(type:String):void 
		{
			switch (type) {
				case Bacterias.BACTERIA_TOPO:
					if (timer_topo == null) {
						createBacteriaTopo();
					}
					break;
				case Bacterias.BACTERIA_MEIO:
					if (timer_meio == null) {
						createBacteriaMeio();
					}
					break;
				case Bacterias.BACTERIA_FUNDO:
					if (timer_fundo == null) {
						createBacteriaFundo();
					}
					break;
				
			}
		}
		
		private function createBacteriaTopo(e:TimerEvent = null):void
		{
			if (timer_topo != null) timer_topo.removeEventListener(TimerEvent.TIMER_COMPLETE, createBacteriaTopo);
			
			var bacteria:Bacterias = new Bacterias(Bacterias.BACTERIA_TOPO);
			bacterias_topo.push(bacteria);
			
			var pos:Point = new Point(Math.random() * larguraTubo, calculatePos(Math.random(), 0, 10));
			if (pos.y < 0) {
				pos.y = Math.abs(pos.y);
			}
			
			this.tubo.addChild(bacteria);
			bacteria.x = pos.x - larguraTubo / 2;
			bacteria.y = pos.y;
			
			timer_topo = new Timer(Math.random() * 1000 + minTime, 1);
			timer_topo.addEventListener(TimerEvent.TIMER_COMPLETE, createBacteriaTopo);
			timer_topo.start();
		}
		
		private function createBacteriaMeio(e:TimerEvent = null):void
		{
			if (timer_meio != null) timer_meio.removeEventListener(TimerEvent.TIMER_COMPLETE, createBacteriaMeio);
			
			var bacteria:Bacterias = new Bacterias(Bacterias.BACTERIA_MEIO);
			bacterias_meio.push(bacteria);
			
			var pos:Point = new Point(Math.random() * larguraTubo , calculatePos(Math.random(), alturaTubo / 2, 70));
			
			this.tubo.addChild(bacteria);
			bacteria.x = pos.x - larguraTubo / 2;
			bacteria.y = pos.y;
			
			timer_meio = new Timer(Math.random() * 1000 + minTime, 1);
			timer_meio.addEventListener(TimerEvent.TIMER_COMPLETE, createBacteriaMeio);
			timer_meio.start();
		}
		
		private function createBacteriaFundo(e:TimerEvent = null):void
		{
			if (timer_fundo != null) timer_fundo.removeEventListener(TimerEvent.TIMER_COMPLETE, createBacteriaMeio);
			
			var bacteria:Bacterias = new Bacterias(Bacterias.BACTERIA_FUNDO);
			bacterias_fundo.push(bacteria);
			
			//var pos:Point = new Point(calculatePos(Math.random(), 0, 20), calculatePos(Math.random(), alturaTubo, 10));
			var pos:Point = new Point(Math.random() * larguraTubo, calculatePos(Math.random(), alturaTubo, 10));
			if (pos.y > alturaTubo) {
				pos.y = alturaTubo - (pos.y - alturaTubo);
			}
			
			this.tubo.addChild(bacteria);
			bacteria.x = pos.x - larguraTubo / 2;
			bacteria.y = pos.y;
			
			timer_fundo = new Timer(Math.random() * 700 + minTime, 1);
			timer_fundo.addEventListener(TimerEvent.TIMER_COMPLETE, createBacteriaFundo);
			timer_fundo.start();
		}
		
		private function calculatePos (rnd:Number, media:Number, dispersao:Number) : Number {
			var ans:Number = 0;
			
			if (rnd <= 1/2) ans = media + Math.log(2*rnd) * dispersao;
			else ans = media - Math.log(2*(1 - rnd)) * dispersao;
			
			if (isNaN(ans)) ans = media;
			
			return ans;
		}
		
		public function reset():void
		{
			if (timer_topo != null) {
				timer_topo.stop();
				timer_topo.removeEventListener(TimerEvent.TIMER_COMPLETE, createBacteriaTopo);
				timer_topo = null;
			}
			
			if (timer_meio != null) {
				timer_meio.stop();
				timer_meio.removeEventListener(TimerEvent.TIMER_COMPLETE, createBacteriaMeio);
				timer_meio = null;
			}
			
			if (timer_fundo != null) {
				timer_fundo.stop();
				timer_fundo.removeEventListener(TimerEvent.TIMER_COMPLETE, createBacteriaFundo);
				timer_fundo = null;
			}
			
			for each (var item:Bacterias in bacterias_topo) 
			{
				this.tubo.removeChild(item);
			}
			
			for each (var item2:Bacterias in bacterias_meio) 
			{
				this.tubo.removeChild(item2);
			}
			
			for each (var item3:Bacterias in bacterias_fundo) 
			{
				this.tubo.removeChild(item3);
			}
			
			bacterias_topo.splice(0);
			bacterias_meio.splice(0);
			bacterias_fundo.splice(0);
		}
	}

}