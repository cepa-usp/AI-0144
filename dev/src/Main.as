package  
{
	import fl.transitions.easing.None;
	import fl.transitions.Tween;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends Sprite
	{
		private var tuboEnsaio:TuboEnsaio;
		private var bacteriaDragging:MovieClip;
		private var etiquetaDragging:Etiqueta;
		private var laminaDestaque:LaminaBacterias;
		private var glowFilter:GlowFilter = new GlowFilter(0x800000);
		
		private var tweenX:Tween;
		private var tweenY:Tween;
		private var tweenX2:Tween;
		private var tweenY2:Tween;
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			makeLinks();
			addListeners();
		}
		
		private function makeLinks():void 
		{
			tuboEnsaio = tubo;
			
			etiquetaTopo.inicialPos = new Point(etiquetaTopo.x, etiquetaTopo.y);
			etiquetaMeio.inicialPos = new Point(etiquetaMeio.x, etiquetaMeio.y);
			etiquetaFundo.inicialPos = new Point(etiquetaFundo.x, etiquetaFundo.y);
			
			etiquetaTopo.laminaCerta = bacteriasTopo;
			etiquetaMeio.laminaCerta = bacteriasMeio;
			etiquetaFundo.laminaCerta = bacteriasFundo;
		}
		
		private function addListeners():void 
		{
			bacteriasTopo.addEventListener(MouseEvent.MOUSE_DOWN, getTopoBacteria);
			bacteriasMeio.addEventListener(MouseEvent.MOUSE_DOWN, getMeioBacteria);
			bacteriasFundo.addEventListener(MouseEvent.MOUSE_DOWN, getFundoBacteria);
			
			etiquetaTopo.addEventListener(MouseEvent.MOUSE_DOWN, getEtiqueta);
			etiquetaMeio.addEventListener(MouseEvent.MOUSE_DOWN, getEtiqueta);
			etiquetaFundo.addEventListener(MouseEvent.MOUSE_DOWN, getEtiqueta);
			
			trocaTubo.addEventListener(MouseEvent.CLICK, limpaTuboEnsaio);
		}
		
		private function limpaTuboEnsaio(e:MouseEvent):void 
		{
			tuboEnsaio.reset();
		}
		
		private function getEtiqueta(e:MouseEvent):void 
		{
			etiquetaDragging = Etiqueta(e.target);
			etiquetaDragging.startDrag();
			stage.addEventListener(MouseEvent.MOUSE_UP, dropEtiqueta);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, destacaLamina);
		}
		
		private function destacaLamina(e:MouseEvent):void 
		{
			var bacteriaDrop:LaminaBacterias;
			
			if (bacteriasTopo.hitTestObject(etiquetaDragging)) {
				bacteriaDrop = bacteriasTopo;
			}else if (bacteriasMeio.hitTestObject(etiquetaDragging)) {
				bacteriaDrop = bacteriasMeio;
			}else if (bacteriasFundo.hitTestObject(etiquetaDragging)) {
				bacteriaDrop = bacteriasFundo;
			}
			
			if (bacteriaDrop != null) {
				if(laminaDestaque != null){
					if (laminaDestaque != bacteriaDrop) {
						laminaDestaque.filters = [];
						laminaDestaque = bacteriaDrop;
					}
					laminaDestaque.filters = [glowFilter];
				}else {
					laminaDestaque = bacteriaDrop;
					laminaDestaque.filters = [glowFilter];
				}
			}else {
				if (laminaDestaque != null) {
					laminaDestaque.filters = [];
					laminaDestaque = null;
				}
			}
		}
		
		private function dropEtiqueta(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, dropEtiqueta);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, destacaLamina);
			etiquetaDragging.stopDrag();
			
			if (laminaDestaque != null) {
				laminaDestaque.filters = [];
				laminaDestaque = null;
			}
			
			var bacteriaDrop:LaminaBacterias;
			
			if (bacteriasTopo.hitTestObject(etiquetaDragging)) {
				bacteriaDrop = bacteriasTopo;
			}else if (bacteriasMeio.hitTestObject(etiquetaDragging)) {
				bacteriaDrop = bacteriasMeio;
			}else if (bacteriasFundo.hitTestObject(etiquetaDragging)) {
				bacteriaDrop = bacteriasFundo;
			}
			
			if(bacteriaDrop != null){
				if (bacteriaDrop.etiqueta == null) { //Drop target sem etiqueta
					if (etiquetaDragging.laminaAtual != null) etiquetaDragging.laminaAtual.etiqueta = null; //lamina que continha a etiqueta arrastada = null
					etiquetaDragging.laminaAtual = bacteriaDrop;
					etiquetaDragging.x = bacteriaDrop.x;
					etiquetaDragging.y = bacteriaDrop.y;
					bacteriaDrop.etiqueta = etiquetaDragging;
				}else {//Drop targte com etiqueta
					if (etiquetaDragging.laminaAtual != null) {//Vindo de uma lamina para uma lamina com etiqueta
						var etiquetaDrop:Etiqueta = bacteriaDrop.etiqueta;
						var laminaDrag:LaminaBacterias = etiquetaDragging.laminaAtual;
						
						tweenX = new Tween(etiquetaDrop, "x", None.easeNone, etiquetaDrop.x, laminaDrag.x, 0.3, true);
						tweenY = new Tween(etiquetaDrop, "y", None.easeNone, etiquetaDrop.y, laminaDrag.y, 0.3, true);
						
						etiquetaDragging.x = bacteriaDrop.x;
						etiquetaDragging.y = bacteriaDrop.y;
						
						etiquetaDragging.laminaAtual = bacteriaDrop;
						bacteriaDrop.etiqueta = etiquetaDragging;
						
						etiquetaDrop.laminaAtual = laminaDrag;
						laminaDrag.etiqueta = etiquetaDrop;
					}else {//Vindo "do nada" para uma lamina com etiqueta
						etiquetaDrop = bacteriaDrop.etiqueta;
						
						tweenX = new Tween(etiquetaDrop, "x", None.easeNone, etiquetaDrop.x, etiquetaDrop.inicialPos.x, 0.3, true);
						tweenY = new Tween(etiquetaDrop, "y", None.easeNone, etiquetaDrop.y, etiquetaDrop.inicialPos.y, 0.3, true);
						
						etiquetaDragging.x = bacteriaDrop.x;
						etiquetaDragging.y = bacteriaDrop.y;
						
						etiquetaDragging.laminaAtual = bacteriaDrop;
						bacteriaDrop.etiqueta = etiquetaDragging;
						
						etiquetaDrop.laminaAtual = null;
					}
				}
			}else {
				if (etiquetaDragging.laminaAtual != null) etiquetaDragging.laminaAtual.etiqueta = null;
				etiquetaDragging.laminaAtual = null;
				
				tweenX = new Tween(etiquetaDragging, "x", None.easeNone, etiquetaDragging.x, etiquetaDragging.inicialPos.x, 0.3, true);
				tweenY = new Tween(etiquetaDragging, "y", None.easeNone, etiquetaDragging.y, etiquetaDragging.inicialPos.y, 0.3, true);
			}
		}
		
		private function getTopoBacteria(e:MouseEvent):void 
		{
			bacteriaDragging = new BactTopo();
			bacteriaDragging.name = Bacterias.BACTERIA_TOPO;
			bacteriaDragging.x = mouseX;
			bacteriaDragging.y = mouseY;
			addChild(bacteriaDragging);
			bacteriaDragging.startDrag();
			stage.addEventListener(MouseEvent.MOUSE_UP, dropBacteria);
		}
		
		private function getMeioBacteria(e:MouseEvent):void 
		{
			bacteriaDragging = new BactMeio();
			bacteriaDragging.name = Bacterias.BACTERIA_MEIO;
			bacteriaDragging.x = mouseX;
			bacteriaDragging.y = mouseY;
			addChild(bacteriaDragging);
			bacteriaDragging.startDrag();
			stage.addEventListener(MouseEvent.MOUSE_UP, dropBacteria);
		}
		
		private function getFundoBacteria(e:MouseEvent):void 
		{
			bacteriaDragging = new BactFundo();
			bacteriaDragging.name = Bacterias.BACTERIA_FUNDO;
			bacteriaDragging.x = mouseX;
			bacteriaDragging.y = mouseY;
			addChild(bacteriaDragging);
			bacteriaDragging.startDrag();
			stage.addEventListener(MouseEvent.MOUSE_UP, dropBacteria);
		}
		
		private function dropBacteria(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, dropBacteria);
			bacteriaDragging.stopDrag();
			
			if (tuboEnsaio.hitTestObject(bacteriaDragging)) {
				tuboEnsaio.colocaBacteria(bacteriaDragging.name);
			}
			
			removeChild(bacteriaDragging);
			bacteriaDragging = null;
		}
		
	}

}