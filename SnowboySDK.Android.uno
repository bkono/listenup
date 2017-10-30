using Fuse;
using Fuse.Scripting;
using Uno.UX;
using Uno.Compiler.ExportTargetInterop;

[UXGlobalModule]
[Require("JNI.SharedLibrary", "@('lib/libsnowboy-detect-android.so':Path)")]
public extern(Android) class SnowboySDK : NativeEventEmitterModule {
  static readonly SnowboySDK _instance;
  public static Java.Object _detector;

  public SnowboySDK() : base(true, "messageReceived") {
    if (_instance != null) return;

    _instance = this;
    Resource.SetGlobalKey(_instance, "SnowboySDK");
    AddMember(new NativeFunction("Test", (NativeCallback)Test));
    AddMember(new NativeFunction("InitDetector", (NativeCallback)InitDetector));
    // AddMember(new NativeFunction("Send", (NativeCallback)Send));
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
      ai.kitt.snowboy.SnowboyDetect snowboyDetector = new ai.kitt.snowboy.SnowboyDetect(commonRes, umdl);
      @{_detector:Set(snowboyDetector)};
      } catch(Exception e) {
        e.printStackTrace(); 
      }
    @}
  }
}

[UXGlobalModule]
public extern(!Android) class SnowboySDK : NativeEventEmitterModule {
  static readonly SnowboySDK _instance;
	public SnowboySDK() : base(true, "messageReceived") {
		 if (_instance != null) return;

    _instance = this;
    Resource.SetGlobalKey(_instance, "SnowboySDK");
    AddMember(new NativeFunction("Test", (NativeCallback)Test));
    AddMember(new NativeFunction("InitDetector", (NativeCallback)InitDetector));
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

    return null;
  }
}