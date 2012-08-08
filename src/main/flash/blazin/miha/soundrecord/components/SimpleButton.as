package blazin.miha.soundrecord.components {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.display.Sprite;

	/**
	 * Simple button with a label
	 */
	public class SimpleButton extends Sprite {
		/**
		 * Label to show in the middle of the button
		 */
		private var label : TextField;

		/**
		 * Constructor creates a new instace. Other methods should be called after this
		 * instance has been added to the display list.
		 */
		public function SimpleButton() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		/**
		 * Sets the button label text
		 * @param text Text to show
		 */
		public function setLabel(text : String) : void {
			label.text = text;
		}

		/**
		 * Enables or disables the button. Disabled state sets the alpha to 0.5 and
		 * disables mouse events
		 * @param enabled Whether to enable or disable the button
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
		 * Initializes simple button when the stage is available
		 */
		private function init(event : Event = null) : void {
			label = new TextField();
			label.background = true;
			label.selectable = false;
			label.backgroundColor = 0x87cefa;
			var format : TextFormat = new TextFormat();
			format.font = "Verdana";
			format.color = 0x000000;
			format.size = 20;
			format.align = "center";
			label.defaultTextFormat = format;
			label.width = 100;
			label.height = 30;
			addChild(label);
			addEventListener(MouseEvent.MOUSE_DOWN, function(event : Event) : void {
				label.backgroundColor = 0x1e90ff;
			});
			addEventListener(MouseEvent.MOUSE_OVER, function(event : Event) : void {
				label.backgroundColor = 0x00bfff;
			});
			addEventListener(MouseEvent.MOUSE_OUT, function(event : Event) : void {
				label.backgroundColor = 0x87cefa;
			});
			addEventListener(MouseEvent.MOUSE_UP, function(event : Event) : void {
				label.backgroundColor = 0x00bfff;
			});
			mouseChildren = false;
		}
	}
}
