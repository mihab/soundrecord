package blazin.miha.soundrecord.components {
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.display.Sprite;

	/**
	 * Simple waveform to display the waveform of the recorded sound. Also displays
	 * a playhead which position should be set using the setPlayHeadPercentage method.
	 */
	public class Waveform extends Sprite {
		/**
		 * Playhead sprite that displays a simple red line
		 */
		private var playHead : Sprite;
		/**
		 * Container Sprite to draw waveform on
		 */
		private var canvas : Sprite;
		/**
		 * The current playhead percentage
		 */
		private var currentPercentage : int;

		/**
		 * Creates a new instance. Other methods should be called after this
		 * instance has been added to the display list.
		 */
		public function Waveform() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		/**
		 * Draws the waveform given the recorded sound. Stretches the waveform to stage.stageWidth.
		 * If stretchSignal is set to true, the signal height is stretched to a maximum of the
		 * waveform height. The precision parameter defines the number of lines to draw per 
		 * pixel. The higher the value, the more precise the waveform but the slower the performance
		 * as more lines get drawn per pixel.
		 * @param bytes Bytes recorded by the microphone
		 * @param stretchSignal Whether to stretch the signal height or not
		 * @param precision Number of lines to draw per pixel.
		 */
		public function draw(bytes : ByteArray, stretchSignal : Boolean = true, precision : int = 10) : void {
			if (canvas != null) {
				removeChild(canvas);
			}
			canvas = new Sprite();
			addChildAt(canvas, 0);
			canvas.graphics.clear();
			canvas.graphics.lineStyle(0, 0x000000);
			canvas.graphics.moveTo(0, 0);
			canvas.graphics.lineTo(stage.stageWidth, 0);
			canvas.graphics.lineTo(stage.stageWidth, 100);
			canvas.graphics.lineTo(0, 100);
			canvas.graphics.lineTo(0, 0);
			canvas.graphics.moveTo(0, 50);
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
					canvas.graphics.lineTo(currentX, 50 + sample);
				}
			}
		}

		/**
		 * Moves the playhead to match the percentage
		 * @param percentage Percentage of recording the current playback is at
		 */
		public function setPlayHeadPercentage(percentage : Number) : void {
			playHead.x = (percentage * stage.stageWidth) / 100;
			currentPercentage = percentage;
		}

		/**
		 * Initializes the waveform when the stage is available
		 */
		private function init(event : Event = null) : void {
			playHead = new Sprite();
			playHead.graphics.beginFill(0xFF0000);
			playHead.graphics.drawRect(0, 0, 1, 100);
			playHead.graphics.endFill();
			addChild(playHead);
			stage.addEventListener(Event.RESIZE, resize);
		}

		/**
		 * Stage resize handler, scales the waveform and repositions the playhead 
		 */
		private function resize(event : Event) : void {
			if (canvas != null) {
				canvas.width = stage.stageWidth;
			}
			setPlayHeadPercentage(currentPercentage);
		}
	}
}
