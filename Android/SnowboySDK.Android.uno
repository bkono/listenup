using Fuse;
using Fuse.Scripting;
using Uno;
using Uno.Permissions;
using Uno.UX;
using Uno.Compiler.ExportTargetInterop;

[UXGlobalModule]
[Require("JNI.SharedLibrary", "@('libsnowboy-detect-android.so':Path)")]
[ForeignInclude(Language.Java,
          "android.media.MediaPlayer",
          "android.media.AudioManager",
          "ai.kitt.snowboy.SnowboyDetect",
          "java.lang.Exception")]
[Require("AndroidManifest.Permission", "android.permission.RECORD_AUDIO")]
public extern(Android) class SnowboySDK : NativeEventEmitterModule {
  bool _canListen = false; 
  static readonly SnowboySDK _instance;
  public static Java.Object _detector;

  public SnowboySDK() : base(true, "canListenChanged") {
    if (_instance != null) return;

    _instance = this;
    Resource.SetGlobalKey(_instance, "SnowboySDK");
    AddMember(new NativeFunction("Test", (NativeCallback)Test));
    AddMember(new NativeFunction("InitDetector", (NativeCallback)InitDetector));
    AddMember(new NativeFunction("CanListen", (NativeCallback)CanListen));
    AddMember(new NativeFunction("EnsurePerms", (NativeCallback)EnsurePerms));
  }

  // Note, this was necessary outside of the init, because on the kindle tablets the js wasn't listening when the event was announced
  object EnsurePerms(Context c, object[] args) {
    debug_log "requesting permissions";
    Permissions.Request(Permissions.Android.RECORD_AUDIO).Then(OnPermitted, OnRejected);

    return null;
  }

  void OnPermitted(PlatformPermission permission) {
    debug_log "Permitted";
    SetCanListen(true);
  }

  void OnRejected(Exception e) {
    debug_log "Not permitted: " + e.Message;
    SetCanListen(false);
  }

  private void SetCanListen(bool value) {
    debug_log "can listen changed: " + value;
    _canListen = value;
    Emit("canListenChanged", _canListen);
  }

  object CanListen(Context c, object[] args) {
    return _canListen;
  }

  object Test(Context c, object[] args) {
    return "hi from non-static";
  }

  object InitDetector(Context c, object[] args) {
    if (args.Length != 2) {
        debug_log "only 2 args";
        return null;
    }

    debug_log args;  
    InitDetectorImpl(args[0] as string, args[1] as string);

    return null;
  }

  [Foreign(Language.Java)]
  public static void InitDetectorImpl(string commonRes, string umdl) {
    @{
      try {
      SnowboyDetect snowboyDetector = new SnowboyDetect(commonRes, umdl);
      @{_detector:Set(snowboyDetector)};
      } catch(Exception e) {
        e.printStackTrace(); 
      }
    @}
  }
}
