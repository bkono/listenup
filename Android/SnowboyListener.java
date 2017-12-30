package listenup.android;

import android.media.AudioFormat;
import ai.kitt.snowboy.SnowboyDetect;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import android.util.Log;

public class SnowboyListener {
	private final static String TAG = "SnowboyListener";

	public static final int RECORDER_BPP = 16;
    public static int RECORDER_SAMPLERATE = 16000;
    public static int RECORDER_CHANNELS = 1;
    public static int RECORDER_AUDIO_ENCODING = AudioFormat.ENCODING_PCM_16BIT;

    private int bufferSize = 0;
	private SnowboyDetect detector;
    private KeywordSpottingCallback callback;
    private AudioRecord recorder = null;
    private Thread recordingThread = null;
    private boolean isRecording = false;
    private boolean isExit = false;

    public SnowboyListener(String commonRes, String umdl, KeywordSpottingCallback cb) {
        callback = cb;
        detector = new SnowboyDetect(commonRes, umdl);
        detector.SetSensitivity("0.6");
        detector.ApplyFrontend(true);
        bufferSize = detector.NumChannels() * detector.SampleRate() * 5;
        recorder = new AudioRecord(MediaRecorder.AudioSource.MIC,
                RECORDER_SAMPLERATE,
                RECORDER_CHANNELS,
                RECORDER_AUDIO_ENCODING,
                bufferSize);
    }

    public void startKeywordSpotting() {
          if (isRecording) {
            return;
        }

        int i = recorder.getState();
        if (i == AudioRecord.STATE_INITIALIZED) {
            recorder.startRecording();
        }

        isRecording = true;

        recordingThread = new Thread(new Runnable() {
            @Override
            public void run() {
                lookForKeyword();
            }
        }, "AudioRecorder Thread");
        recordingThread.start();
        callback.onStarted();
    }

    public void stopKeywordSpotting() {
        if (recordingThread == null)
            return;

        isRecording = false;
        recordingThread = null;
        callback.onStopped();
    }


    private void lookForKeyword() {
        short data[] = new short[bufferSize / 2];
        int read = 0;

        try {
            while (isRecording) {
                read = recorder.read(data, 0, data.length);
                Log.i(TAG, "read length = " + read);
                if (AudioRecord.ERROR_INVALID_OPERATION != read) {
                    int result = detector.RunDetection(data, data.length);
                    Log.i(TAG, " ----> result = " + result);
                    if (result == -1) {
                        isRecording = false;
                        callback.onError();
                    } else if (result > 0) {
                        isRecording = false;
                        Log.i(TAG, "result detected! " + result);
                        callback.onSpotted(result);
                    }
                }
                Thread.sleep(30);
            }
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        if (recorder != null) {
            recorder.stop();
            callback.onStopped();
        }
        Log.i(TAG, "detectSpeaking finished.");
    }
}