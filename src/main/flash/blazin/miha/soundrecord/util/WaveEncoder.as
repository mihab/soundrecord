package blazin.miha.soundrecord.util {
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	/**
	 * Helper class used for converting microphone data to the wave file format.
	 * Original work from Thibault Imbert
	 * @see http://www.bytearray.org/?p=1858
	 */
	public class WaveEncoder {
		private static const RIFF : String = "RIFF";
		private static const WAVE : String = "WAVE";
		private static const FMT : String = "fmt ";
		private static const DATA : String = "data";
		private var _bytes : ByteArray = new ByteArray();
		private var _buffer : ByteArray = new ByteArray();

		/**
		 * Encodes data received from the Microphone into the WAVE file format
		 * @param samples Microphone sample data
		 * @param channels Number of channels
		 * @param bits Size of sample in bits
		 * @param rate Sample rate per second
		 * @return ByteArray in WAVE file format
		 */
		public function encode(samples : ByteArray, channels : int = 2, bits : int = 16, rate : int = 44100) : ByteArray {
			var data : ByteArray = create(samples);

			_bytes.length = 0;
			_bytes.endian = Endian.LITTLE_ENDIAN;

			_bytes.writeUTFBytes(WaveEncoder.RIFF);
			_bytes.writeInt(uint(data.length + 44));
			_bytes.writeUTFBytes(WaveEncoder.WAVE);
			_bytes.writeUTFBytes(WaveEncoder.FMT);
			_bytes.writeInt(uint(16));
			_bytes.writeShort(uint(1));
			_bytes.writeShort(channels);
			_bytes.writeInt(rate);
			_bytes.writeInt(uint(rate * channels * ( bits >> 3 )));
			_bytes.writeShort(uint(channels * ( bits >> 3 )));
			_bytes.writeShort(bits);
			_bytes.writeUTFBytes(WaveEncoder.DATA);
			_bytes.writeInt(data.length);
			_bytes.writeBytes(data);
			_bytes.position = 0;

			return _bytes;
		}

		/**
		 * Converts the byte array
		 */
		private function create(bytes : ByteArray) : ByteArray {
			_buffer.endian = Endian.LITTLE_ENDIAN;
			_buffer.length = 0;
			bytes.position = 0;

			while ( bytes.bytesAvailable )
				_buffer.writeShort(bytes.readFloat() * (0x7fff * 1));
			return _buffer;
		}
	}
}