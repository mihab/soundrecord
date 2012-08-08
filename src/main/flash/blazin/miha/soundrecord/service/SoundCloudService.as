package blazin.miha.soundrecord.service {
	import blazin.miha.soundrecord.util.UploadPostHelper;
	import blazin.miha.soundrecord.util.WaveEncoder;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;

	/**
	 * Class to use for connecting to the SoundCloud service. Dispatches events of type:
	 * UPLOAD_COMPLETE, UPLOAD_FAILED
	 */
	public class SoundCloudService extends EventDispatcher {
		/**
		 * Event type to dispatch when the request was successful
		 */
		public static const UPLOAD_COMPLETE : String = "uploadComplete";
		/**
		 * Event type to dispatch when the request failed
		 */
		public static const UPLOAD_FAILED : String = "uploadFailed";
		/**
		 * WAVE encoder used for encoding microphone data into the WAVE file format
		 * required by the server
		 */
		private var waveEncoder : WaveEncoder;
		/**
		 * URLLoader to use for sending requests
		 */
		private var urlLoader : URLLoader;
		/**
		 * Result of the last successful server response
		 */
		private var lastResult : Object;

		/**
		 * Constructor creates a new SoundCloudService instance
		 */
		public function SoundCloudService() {
			waveEncoder = new WaveEncoder();
			urlLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, completeHandler);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
		}

		/**
		 * Returns the last result of a successful response from the server, or null
		 */
		public function getLastResult() : Object {
			return lastResult;
		}

		/**
		 * Uploads the recorded song to the SoundCloud service
		 * @param token The authorization token to use
		 * @param soundBytes Sound bytes captured by the microphone (MONO)
		 */
		public function uploadSong(token : String, soundBytes : ByteArray) : void {
			var waveBytes : ByteArray = waveEncoder.encode(soundBytes, 1);
			var trackTitle : String = "test" + Math.round((new Date().time) / 1000);
			var parameters : Object = new Object();
			parameters["oauth_token"] = token;
			parameters["track[title]"] = trackTitle;
			parameters["track[sharing]"] = "private";
			parameters["format"] = "json";
			parameters["_status_code_map[400"] = "200";
			parameters["_status_code_map[401]"] = "200";
			parameters["_status_code_map[403]"] = "200";
			parameters["_status_code_map[404]"] = "200";
			parameters["_status_code_map[422]"] = "200";
			parameters["_status_code_map[500]"] = "200";
			parameters["_status_code_map[503]"] = "200";
			parameters["_status_code_map[504]"] = "200";
			var urlRequest : URLRequest = new URLRequest();
			urlRequest.url = "https://api.soundcloud.com/tracks";
			urlRequest.method = URLRequestMethod.POST;
			urlRequest.data = UploadPostHelper.getPostData(trackTitle + ".wav", waveBytes, parameters);
			urlRequest.requestHeaders.push(new URLRequestHeader('Content-Type', 'multipart/form-data; boundary=' + UploadPostHelper.getBoundary()));
			try {
				urlLoader.load(urlRequest);
			} catch (error : Error) {
				trace("Unable to load requested document.");
				dispatchEvent(new Event(UPLOAD_FAILED));
			}
		}

		/**
		 * Handler for a successful request 
		 */
		private function completeHandler(event : Event) : void {
			lastResult = JSON.parse(urlLoader.data.toString());
			dispatchEvent(new Event(UPLOAD_COMPLETE));
		}

		/**
		 * Handler for a failed request
		 */
		private function errorHandler(event : Event) : void {
			trace("securityErrorHandler: " + event);
			dispatchEvent(new Event(UPLOAD_FAILED));
		}
	}
}
