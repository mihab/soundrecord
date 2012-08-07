package blazin.miha.soundrecord {
	import blazin.miha.soundrecord.components.RecordButton;
	import blazin.miha.soundrecord.components.SimpleButton;
	import blazin.miha.soundrecord.components.StatusHeader;
	import blazin.miha.soundrecord.components.Waveform;
	import blazin.miha.soundrecord.service.SoundCloudService;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.SampleDataEvent;
	import flash.external.ExternalInterface;
	import flash.media.Microphone;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.ByteArray;

	/**
	 * Main class of the Sound Record application. Sets up the stage and all other components. 
	 */
	public class SoundRecord extends Sprite {
		/**
		 * Status header to display messages
		 */
		private var statusHeader : StatusHeader;
		/**
		 * Button to start/stop recording
		 */
		private var recordButton : RecordButton;
		/**
		 * Button to start/stop playback
		 */
		private var playStopButton : SimpleButton;
		/**
		 * Button to discard recording
		 */
		private var clearButton : SimpleButton;
		/**
		 * Button to start upload to Sound Cloud
		 */
		private var uploadButton : SimpleButton;
		/**
		 * Container to hold play/clear/upload buttons
		 */
		private var controlsContainer : Sprite;
		/**
		 * Status if currently recording
		 */
		private var isRecording : Boolean;
		/**
		 * Status if currently playing recording
		 */
		private var isPlaying : Boolean;
		/**
		 * Status if currently uploading
		 */
		private var isUploading : Boolean;
		/**
		 * Byte array of recording
		 */
		private var soundBytes : ByteArray = new ByteArray();
		/**
		 * Microphone instance
		 */
		private var microphone : Microphone;
		/**
		 * Sound instance to playback recording
		 */
		private var sound : Sound = new Sound();
		/**
		 * Sound channel of playback
		 */
		private var channel : SoundChannel;
		/**
		 * Waveform instance to display wave form of recording
		 */
		private var waveform : Waveform;
		/**
		 * SoundCloud service instance to connect to SoundCloud
		 */
		private var soundCloudService : SoundCloudService;
		/**
		 * Authorization token for SoundCloud service
		 */
		private var token : String = null;

		/**
		 * Constructor creates new instance
		 */
		public function SoundRecord() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		/**
		 * Initializes the application and sets up the stage once it's available
		 */
		private function init(event : Event = null) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			statusHeader = new StatusHeader();
			addChild(statusHeader);
			statusHeader.x = stage.stageWidth / 2 - statusHeader.width / 2;
			recordButton = new RecordButton();
			addChild(recordButton);
			recordButton.y = 50;
			recordButton.x = stage.stageWidth / 2 - recordButton.width / 2;
			controlsContainer = new Sprite();
			controlsContainer.y = recordButton.height + recordButton.y + 5;
			playStopButton = new SimpleButton();
			controlsContainer.addChild(playStopButton);
			clearButton = new SimpleButton();
			controlsContainer.addChild(clearButton);
			uploadButton = new SimpleButton();
			controlsContainer.addChild(uploadButton);
			addChild(controlsContainer);
			playStopButton.setLabel("PLAY");
			clearButton.setLabel("CLEAR");
			uploadButton.setLabel("UPLOAD");
			clearButton.x = playStopButton.width + 5;
			uploadButton.x = playStopButton.width + 5 + clearButton.width + 5;
			controlsContainer.x = stage.stageWidth / 2 - controlsContainer.width / 2;
			waveform = new Waveform();
			waveform.y = controlsContainer.y + controlsContainer.height + 5;
			addChild(waveform);
			controlsContainer.visible = false;
			waveform.visible = false;
			recordButton.addEventListener(MouseEvent.CLICK, toggleRecording, false, 0, true);
			clearButton.addEventListener(MouseEvent.CLICK, clear, false, 0, true);
			playStopButton.addEventListener(MouseEvent.CLICK, togglePlayback, false, 0, true);
			if (ExternalInterface.available) {
				ExternalInterface.addCallback("upload", upload);
				uploadButton.addEventListener(MouseEvent.CLICK, startUpload, false, 0, true);
			}
			soundCloudService = new SoundCloudService();
			soundCloudService.addEventListener(SoundCloudService.UPLOAD_COMPLETE, uploadComplete);
			soundCloudService.addEventListener(SoundCloudService.UPLOAD_FAILED, uploadFailed);
		}

		/**
		 * Called from JavaScript when the user approves access
		 * @param token Authorization token to use when uploading the recording to SoundCloud
		 */
		private function upload(token : String) : void {
			this.token = token;
			isUploading = true;
			controlsContainer.visible = false;
			waveform.visible = false;
			recordButton.setEnabled(false);
			statusHeader.setUploading();
			soundCloudService.uploadSong(token, soundBytes);
		}

		/**
		 * Start upload button click handler, calls JavaScript to authorize the application
		 */
		private function startUpload(event : Event) : void {
			if (token == null) {
				ExternalInterface.call("authorize");
			} else {
				upload(token);
			}
		}

		/**
		 * Upload completed successfully handler
		 */
		private function uploadComplete(event : Event) : void {
			isUploading = false;
			recordButton.setEnabled(true);
			statusHeader.setUploaded();
			var object : Object = soundCloudService.getLastResult();
			if (ExternalInterface.available) {
				ExternalInterface.call("addLink", object.title, object.permalink_url);
			}
		}

		/**
		 * Upload failed handler
		 */
		private function uploadFailed(event : Event) : void {
			isUploading = false;
			recordButton.setEnabled(true);
			statusHeader.setUploadFailed();
		}

		/**
		 * Record button click handler. Starts or stop the recording of audio from the microphone. The user needs to first allow access to the camera
		 */
		private function toggleRecording(event : Event) : void {
			if (isRecording) {
				isRecording = false;
				statusHeader.setReady();
				recordButton.changeLabel(false);
				microphone.removeEventListener(SampleDataEvent.SAMPLE_DATA, micSampleDataHandler);
				soundBytes.position = 0;
				if (soundBytes.length > 0) {
					controlsContainer.visible = true;
					waveform.draw(soundBytes);
					waveform.visible = true;
				}
			} else {
				microphone = Microphone.getMicrophone();
				if (microphone == null) {
					statusHeader.setNoMicrophone();
					return;
				}
				microphone.setSilenceLevel(0);
				microphone.gain = 50;
				microphone.rate = 44;
				microphone.removeEventListener(SampleDataEvent.SAMPLE_DATA, micSampleDataHandler);
				microphone.addEventListener(SampleDataEvent.SAMPLE_DATA, micSampleDataHandler);
			}
		}

		/**
		 * Called when sound data gets captured by the microphone. Also shows the recording UI because this is the most reliable way to determine if recording is happening
		 */
		private function micSampleDataHandler(event : SampleDataEvent) : void {
			if (!isRecording) {
				isRecording = true;
				statusHeader.setRecording();
				recordButton.changeLabel(true);
				controlsContainer.visible = false;
				soundBytes.clear();
				waveform.visible = false;
			}
			while (event.data.bytesAvailable) {
				var sample : Number = event.data.readFloat();
				soundBytes.writeFloat(sample);
			}
		}

		/**
		 * Clear button click handler. Discards the recording
		 */
		private function clear(event : Event) : void {
			controlsContainer.visible = false;
			soundBytes.clear();
			waveform.visible = false;
		}

		/**
		 * Play/Stop button click handler. Starts or stops the playback of the recording
		 */
		private function togglePlayback(event : Event = null) : void {
			if (isPlaying) {
				isPlaying = false;
				recordButton.setEnabled(true);
				clearButton.setEnabled(true);
				uploadButton.setEnabled(true);
				statusHeader.setReady();
				playStopButton.setLabel("PLAY");
				sound.removeEventListener(SampleDataEvent.SAMPLE_DATA, playbackSampleHandler);
				channel.removeEventListener(Event.SOUND_COMPLETE, playbackComplete);
				removeEventListener(Event.ENTER_FRAME, onFrame);
			} else {
				isPlaying = true;
				recordButton.setEnabled(false);
				clearButton.setEnabled(false);
				uploadButton.setEnabled(false);
				statusHeader.setPlaying();
				playStopButton.setLabel("STOP");
				soundBytes.position = 0;
				sound.addEventListener(SampleDataEvent.SAMPLE_DATA, playbackSampleHandler);
				channel = sound.play();
				channel.addEventListener(Event.SOUND_COMPLETE, playbackComplete);
				addEventListener(Event.ENTER_FRAME, onFrame);
			}
		}

		/**
		 * Called when the player needs more sample data
		 */
		private function playbackSampleHandler(event : SampleDataEvent) : void {
			for (var i : int = 0; i < 8192 && soundBytes.bytesAvailable >= 4; i++) {
				var sample : Number = soundBytes.readFloat();
				event.data.writeFloat(sample);
				event.data.writeFloat(sample);
			}
		}

		/**
		 * Called when the playback is complete
		 */
		private function playbackComplete(event : Event) : void {
			waveform.setPlayHeadPercentage(100);
			if (isPlaying) {
				togglePlayback();
			}
		}

		/**
		 * On Enter Frame handler called to update the playhead on the waveform
		 */
		private function onFrame(event : Event) : void {
			var soundLength : Number = ((soundBytes.length / 4) / 44100);
			var currentPosition : Number = channel.position / 1000;
			var percentage : Number = (currentPosition * 100) / soundLength;
			waveform.setPlayHeadPercentage(percentage);
		}
	}
}
