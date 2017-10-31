package listenup.android;

import android.media.AudioFormat;


public class SnowboyListener {
	private final static string TAG = "SnowboyListener";

	public static final int RECORDER_BPP = 16;
    public static int RECORDER_SAMPLERATE = 16000;
    public static int RECORDER_CHANNELS = 1;
    public static int RECORDER_AUDIO_ENCODING = AudioFormat.ENCODING_PCM_16BIT;

    private int bufferSize = 0;
	private SnowboyDetect detector;
    private AudioRecord recorder = null;
    private Thread recordingThread = null;
    private boolean isRecording = false;
    private boolean isExit = false;

    
}