package blazin.miha.soundrecord.components {
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.display.Sprite;

	/**
	 * Status header that display a message and animates it with three trailing dots in some cases
	 */
	public class StatusHeader extends Sprite {
		/**
		 * Text to show in the status header
		 */
		private var label : TextField;
		/**
		 * Timer used for the animation
		 */
		private var timer : Timer;

		/**
		 * Constructor creates a new instance. Other methods should be called after this instance has been added to the display list.
		 */
		public function StatusHeader() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		/**
		 * Set no microphone text
		 */
		public function setNoMicrophone() : void {
			label.text = "No Microphone";
			timer.reset();
		}

		/**
		 * Set ready text
		 */
		public function setReady() : void {
			label.text = "Ready";
			timer.reset();
		}

		/**
		 * Shows and animates recording text
		 */
		public function setRecording() : void {
			label.text = "Recording";
			timer.reset();
			timer.start();
		}

		/**
		 * Shows and animates playing text
		 */
		public function setPlaying() : void {
			label.text = "Playing";
			timer.reset();
			timer.start();
		}

		/**
		 * Shows and animates uploading text
		 */
		public function setUploading() : void {
			label.text = "Uploading";
			timer.reset();
			timer.start();
		}

		/**
		 * Set ready text
		 */
		public function setUploaded() : void {
			label.text = "Uploaded!";
			timer.reset();
		}

		/**
		 * Set upload failed text
		 */
		public function setUploadFailed() : void {
			label.text = "Upload Failed!";
			timer.reset();
		}

		/**
		 * Initializes the status header when stage is available
		 */
		private function init(event : Event = null) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			timer = new Timer(1000);
			timer.addEventListener(TimerEvent.TIMER, timerHandler, false, 0, true);
			label = new TextField();
			label.selectable = false;
			label.border = true;
			var format : TextFormat = new TextFormat();
			format.font = "Verdana";
			format.color = 0x000000;
			format.size = 25;
			format.align = "center";
			label.defaultTextFormat = format;
			label.width = 200;
			label.height = 50;
			addChild(label);
			label.text = "Ready";
		}

		/**
		 * Timer handler to animate the three trailing dots
		 */
		private function timerHandler(event : TimerEvent) : void {
			if (timer.currentCount > 3) {
				label.text = label.text.substring(0, label.text.length - 3);
				timer.reset();
				timer.start();
			} else {
				label.text += ".";
			}
		}
	}
}
