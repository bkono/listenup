package listenup.android;

public interface KeywordSpottingCallback {
	void onStarted();
	void onStopped();
	void onError();
	void onSpotted(int result);
}