package blazin.miha.soundrecord.components {
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.display.Sprite;

	/**
	 * Simple waveform to display the wave form of the recorded sound. Also display a playhead if the setPlayHeadPercentage is called while play the recording
	 */
	public class Waveform extends Sprite {
		/**
		 * Playhead sprite that displays a simple red line
		 */
		private var playHead : Sprite;

		/**
		 * Creates a new instance. Other methods should be called after this instance has been added to the display list.
		 */
		public function Waveform() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		/**
		 * Draws the waveform given the recording sounds. Stretches the wave form to stage.stageWidth.
		 * @param bytes Bytes recorded by the microphone
		 * @param stretchSignal Whether to stretch the signal or not. A stretched signal looks for the max value and multiplies it and other values to 1
		 * @param precision Number of lines to draw per pixel. The higher the value, the more precise the wave form but slows down performance as it takes longer to draw
		 */
		public function draw(bytes : ByteArray, stretchSignal : Boolean = true, precision : int = 10) : void {
			graphics.clear();
			graphics.lineStyle(0, 0x000000);
			graphics.moveTo(0, 0);
			graphics.lineTo(stage.stageWidth, 0);
			graphics.lineTo(stage.stageWidth, 100);
			graphics.lineTo(0, 100);
			graphics.lineTo(0, 0);
			graphics.moveTo(0, 50);
			var delta : Number = stage.stageWidth / (bytes.bytesAvailable / 4);
			var currentX : Number = 0;
			var currentDrawPoint : int = 0;
			var lastDrawnPoint : int = 0;
			var max : Number = 0;
			var min : Number = 0;
			var sample : Number;
			var multiplier : Number = 0;
			if (stretchSignal) {
				while (bytes.bytesAvailable >= 4) {
					sample = bytes.readFloat();
					currentX += delta;
					currentDrawPoint = currentX * precision;
					if (currentDrawPoint != lastDrawnPoint) {
						lastDrawnPoint = currentDrawPoint;
						if (sample > max) {
							max = sample;
						}
						if (sample < min) {
							min = sample;
						}
					}
				}
				if (Math.abs(min) > max) {
					multiplier = Math.abs(min);
				} else {
					multiplier = max;
				}
				multiplier = 1 / multiplier;
				bytes.position = 0;
				currentX = 0;
				lastDrawnPoint = 0;
			}
			while (bytes.bytesAvailable >= 4) {
				sample = bytes.readFloat();
				currentX += delta;
				currentDrawPoint = currentX * precision;
				if (currentDrawPoint != lastDrawnPoint) {
					lastDrawnPoint = currentDrawPoint;
					if (stretchSignal) {
						sample = sample * multiplier * 50;
					} else {
						sample = sample * 50;
					}
					graphics.lineTo(currentX, 50 + sample);
				}
			}
		}

		/**
		 * Moves the playhead line to match the percentage
		 * @param percentage Percentage of recording the current playhead is at
		 */
		public function setPlayHeadPercentage(percentage : Number) : void {
			playHead.x = (percentage * width) / 100;
		}

		/**
		 * Initializes the wave form when stage is available
		 */
		private function init(event : Event = null) : void {
			playHead = new Sprite();
			playHead.graphics.beginFill(0xFF0000);
			playHead.graphics.drawRect(0, 0, 1, 100);
			playHead.graphics.endFill();
			addChild(playHead);
		}
	}
}
