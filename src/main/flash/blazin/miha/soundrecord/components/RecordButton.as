package blazin.miha.soundrecord.components {
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.display.Sprite;

	/**
	 * Simple record button that display a big record circle
	 */
	public class RecordButton extends Sprite {
		/**
		 * Label to show in the middle of the button
		 */
		private var label : TextField;
		/**
		 * Sprite to show when mouse over
		 */
		private var overSprite : Sprite;
		/**
		 * Sprite to show when mouse down
		 */
		private var downSprite : Sprite;

		/**
		 * Constructor creates a new instace. Other methods should be called after this
		 * instance has been added to the display list.
		 */
		public function RecordButton() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		/**
		 * Change label from recording to stop or reverse
		 * @param recording Whether recording or not
		 */
		public function changeLabel(recording : Boolean) : void {
			if (recording) label.text = "STOP";
			else label.text = "REC";
		}

		/**
		 * Enables or disables the button. Disabled state sets the alpha to 0.5 and
		 * disables mouse events
		 * @param enabled Whether to enable or disable the record button
		 */
		public function setEnabled(enabled : Boolean) : void {
			if (enabled) {
				alpha = 1;
				mouseEnabled = true;
			} else {
				alpha = 0.5;
				mouseEnabled = false;
			}
		}

		/**
		 * Initializes record button when the stage is available
		 */
		private function init(event : Event = null) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			graphics.beginFill(0xEE4000);
			graphics.drawCircle(100, 100, 100);
			graphics.endFill();
			overSprite = new Sprite();
			overSprite.graphics.beginFill(0xCD3700);
			overSprite.graphics.drawCircle(100, 100, 100);
			overSprite.graphics.endFill();
			addChild(overSprite);
			overSprite.visible = false;
			downSprite = new Sprite();
			downSprite.graphics.beginFill(0x8B2500);
			downSprite.graphics.drawCircle(100, 100, 100);
			downSprite.graphics.endFill();
			addChild(downSprite);
			downSprite.visible = false;
			label = new TextField();
			label.selectable = false;
			var format : TextFormat = new TextFormat();
			format.font = "Verdana";
			format.color = 0xFFFFFF;
			format.size = 35;
			format.align = "center";
			label.defaultTextFormat = format;
			label.y = 100 - 25;
			label.width = 200;
			label.height = 50;
			label.text = "REC";
			addChild(label);
			addEventListener(MouseEvent.MOUSE_OVER, function(event : Event) : void {
				overSprite.visible = true;
			});
			addEventListener(MouseEvent.MOUSE_OUT, function(event : Event) : void {
				overSprite.visible = false;
				downSprite.visible = false;
			});
			addEventListener(MouseEvent.MOUSE_DOWN, function(event : Event) : void {
				downSprite.visible = true;
			});
			addEventListener(MouseEvent.MOUSE_UP, function(event : Event) : void {
				downSprite.visible = false;
			});
			mouseChildren = false;
		}
	}
}
