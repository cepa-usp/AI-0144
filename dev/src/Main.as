package  
{
	import cepa.utils.ToolTip;
	import fl.transitions.easing.None;
	import fl.transitions.Tween;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.Timer;
	import pipwerks.SCORM;
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
		
		private var balao:CaixaTexto;
		private var pointsTuto:Array;
		private var tutoBaloonPos:Array;
		private var tutoPos:int;
		private var tutoSequence:Array = ["Estas placas de Petri contém três espécies distintas de bactérias.", 
										  "Classifique as bactérias arrastando os rótulos para as placas de Petri.",
										  "O tubo de ensaio contém um líquido propício à proliferação das três bactérias.",
										  "Esta escala indica a distribuição de oxigênio no tubo de ensaio.",
										  "Você pode arrastar uma ou mais bactérias para dentro do tubo de ensaio.",
										  "Pressione este botão para trocar o tubo de ensaio e começar uma nova experiência."];
		
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
			createToolTips();
			
			if (ExternalInterface.available) {
				initLMSConnection();
			}
			
			verificaFinaliza();
			iniciaTutorial();
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
			
			finaliza.buttonMode = true;
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
			finaliza.addEventListener(MouseEvent.CLICK, finalizaExec);
			
			botoes.tutorialBtn.addEventListener(MouseEvent.CLICK, iniciaTutorial);
			botoes.orientacoesBtn.addEventListener(MouseEvent.CLICK, openOrientacoes);
			botoes.resetButton.addEventListener(MouseEvent.CLICK, reset);
			botoes.creditos.addEventListener(MouseEvent.CLICK, openCreditos);
		}
		
		private function createToolTips():void 
		{
			var infoTT:ToolTip = new ToolTip(botoes.creditos, "Créditos", 12, 0.8, 100, 0.6, 0.1);
			var instTT:ToolTip = new ToolTip(botoes.orientacoesBtn, "Orientações", 12, 0.8, 100, 0.6, 0.1);
			var resetTT:ToolTip = new ToolTip(botoes.resetButton, "Reiniciar", 12, 0.8, 100, 0.6, 0.1);
			var intTT:ToolTip = new ToolTip(botoes.tutorialBtn, "Reiniciar tutorial", 12, 0.8, 150, 0.6, 0.1);
			var finalizaTT:ToolTip = new ToolTip(finaliza, "Finaliza atividade", 12, 0.8, 200, 0.6, 0.1);
			var trocaTuboTT:ToolTip = new ToolTip(trocaTubo, "Novo tubo de ensaio", 12, 0.8, 250, 0.6, 0.1);
			
			addChild(infoTT);
			addChild(instTT);
			addChild(resetTT);
			addChild(intTT);
			addChild(finalizaTT);
			addChild(trocaTuboTT);
		}
		
		private function iniciaTutorial(e:MouseEvent = null):void 
		{
			tutoPos = 0;
			if(balao == null){
				balao = new CaixaTexto(true);
				addChild(balao);
				balao.visible = false;
				
				pointsTuto = 	[new Point(bacteriasMeio.x, bacteriasMeio.y - 50),
								new Point(etiquetaMeio.x, etiquetaMeio.y + etiquetaMeio.height + 50),
								new Point(tuboEnsaio.x - (tuboEnsaio.width / 2), tuboEnsaio.y + 30),
								new Point(escalaOxigenio.x, escalaOxigenio.y + (escalaOxigenio.height / 2)),
								new Point(bacteriasMeio.x, bacteriasMeio.y - 50),
								new Point(trocaTubo.x - (trocaTubo.width / 2), trocaTubo.y)];
								
				tutoBaloonPos = [[CaixaTexto.BOTTON, CaixaTexto.CENTER],
								[CaixaTexto.TOP, CaixaTexto.CENTER],
								[CaixaTexto.RIGHT, CaixaTexto.FIRST],
								[CaixaTexto.RIGHT, CaixaTexto.CENTER],
								[CaixaTexto.BOTTON, CaixaTexto.CENTER],
								[CaixaTexto.RIGHT, CaixaTexto.LAST]];
			}
			balao.removeEventListener(Event.CLOSE, closeBalao);
			
			balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
			balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			balao.addEventListener(Event.CLOSE, closeBalao);
			balao.visible = true;
		}
		
		private function closeBalao(e:Event):void 
		{
			tutoPos++;
			if (tutoPos >= tutoSequence.length) {
				balao.removeEventListener(Event.CLOSE, closeBalao);
				balao.visible = false;
				//tutoPhase = false;
			}else {
				balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
				balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			}
		}
		
		private function openOrientacoes(e:MouseEvent):void 
		{
			orientacoesScreen.openScreen();
			setChildIndex(orientacoesScreen, numChildren - 1);
		}
		
		private function openCreditos(e:MouseEvent):void 
		{
			creditosScreen.openScreen();
			setChildIndex(creditosScreen, numChildren - 1);
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
			
			var bacteriaDrop:LaminaBacterias = laminaDestaque;
			
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
			
			if (laminaDestaque != null) {
				laminaDestaque.filters = [];
				laminaDestaque = null;
			}
			
			verificaFinaliza();
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
		
		private function reset(e:MouseEvent = null):void
		{
			etiquetaTopo.x = etiquetaTopo.inicialPos.x;
			etiquetaTopo.y = etiquetaTopo.inicialPos.y;
			etiquetaMeio.x = etiquetaMeio.inicialPos.x;
			etiquetaMeio.y = etiquetaMeio.inicialPos.y;
			etiquetaFundo.x = etiquetaFundo.inicialPos.x;
			etiquetaFundo.y = etiquetaFundo.inicialPos.y;
			
			etiquetaTopo.laminaAtual = null;
			etiquetaMeio.laminaAtual = null;
			etiquetaFundo.laminaAtual = null;
			
			bacteriasTopo.etiqueta = null;
			bacteriasMeio.etiqueta = null;
			bacteriasFundo.etiqueta = null;
			
			tuboEnsaio.reset();
			verificaFinaliza();
			
			tutoPos = 0;
			balao.visible = false;
		}
		
		private function verificaFinaliza():void 
		{
			if (etiquetaTopo.laminaAtual == null || etiquetaMeio.laminaAtual == null || etiquetaFundo.laminaAtual == null) {
				finaliza.mouseEnabled = false;
				finaliza.alpha = 0.5;
			}else {
				finaliza.mouseEnabled = true;
				finaliza.alpha = 1;
			}
		}
		
		private function finalizaExec(e:MouseEvent):void
		{
			if (etiquetaTopo.laminaAtual == etiquetaTopo.laminaCerta && 
				etiquetaMeio.laminaAtual == etiquetaMeio.laminaCerta && 
				etiquetaFundo.laminaAtual == etiquetaFundo.laminaCerta) {
					if(connected && !completed){
						score = 100;
						completed = true;
						commit();
					}
					trace("correto");
				}else {
					if(connected && !completed){
						score = 0;
						completed = true;
						commit();
					}
					trace("errado");
				}
		}
		
		
		/*------------------------------------------------------------------------------------------------*/
		//SCORM:
		
		private const PING_INTERVAL:Number = 5 * 60 * 1000; // 5 minutos
		private var completed:Boolean;
		private var scorm:SCORM;
		private var scormExercise:int;
		private var connected:Boolean;
		private var score:int;
		private var pingTimer:Timer;
		
		/**
		 * @private
		 * Inicia a conexão com o LMS.
		 */
		private function initLMSConnection () : void
		{
			completed = false;
			connected = false;
			scorm = new SCORM();
			
			pingTimer = new Timer(PING_INTERVAL);
			pingTimer.addEventListener(TimerEvent.TIMER, pingLMS);
			
			connected = scorm.connect();
			
			if (connected) {
				// Verifica se a AI já foi concluída.
				var status:String = scorm.get("cmi.completion_status");	
				var stringScore:String = scorm.get("cmi.score.raw");
			 
				switch(status)
				{
					// Primeiro acesso à AI
					case "not attempted":
					case "unknown":
					default:
						completed = false;
						break;
					
					// Continuando a AI...
					case "incomplete":
						completed = false;
						break;
					
					// A AI já foi completada.
					case "completed":
						completed = true;
						//setMessage("ATENÇÃO: esta Atividade Interativa já foi completada. Você pode refazê-la quantas vezes quiser, mas não valerá nota.");
						break;
				}
				
				//unmarshalObjects(mementoSerialized);
				scormExercise = 1;
				score = Number(stringScore.replace(",", "."));
				
				var success:Boolean = scorm.set("cmi.score.min", "0");
				if (success) success = scorm.set("cmi.score.max", "100");
				
				if (success)
				{
					scorm.save();
					pingTimer.start();
				}
				else
				{
					//trace("Falha ao enviar dados para o LMS.");
					connected = false;
				}
			}
			else
			{
				trace("Esta Atividade Interativa não está conectada a um LMS: seu aproveitamento nela NÃO será salvo.");
			}
			
			//reset();
		}
		
		/**
		 * @private
		 * Salva cmi.score.raw, cmi.location e cmi.completion_status no LMS
		 */ 
		private function commit()
		{
			if (connected)
			{
				// Salva no LMS a nota do aluno.
				var success:Boolean = scorm.set("cmi.score.raw", score.toString());

				// Notifica o LMS que esta atividade foi concluída.
				success = scorm.set("cmi.completion_status", (completed ? "completed" : "incomplete"));

				// Salva no LMS o exercício que deve ser exibido quando a AI for acessada novamente.
				success = scorm.set("cmi.location", scormExercise.toString());
				
				// Salva no LMS a string que representa a situação atual da AI para ser recuperada posteriormente.
				//mementoSerialized = marshalObjects();
				//success = scorm.set("cmi.suspend_data", mementoSerialized.toString());

				if (success)
				{
					scorm.save();
				}
				else
				{
					pingTimer.stop();
					//setMessage("Falha na conexão com o LMS.");
					connected = false;
				}
			}
		}
		
		/**
		 * @private
		 * Mantém a conexão com LMS ativa, atualizando a variável cmi.session_time
		 */
		private function pingLMS (event:TimerEvent)
		{
			//scorm.get("cmi.completion_status");
			commit();
		}
		
	}

}