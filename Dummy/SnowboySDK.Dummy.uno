using Fuse;
using Fuse.Scripting;
using Uno.UX;
using Uno.Compiler.ExportTargetInterop;

[UXGlobalModule]
public extern(!Android && !iOS) class SnowboySDK : NativeEventEmitterModule {
  static readonly SnowboySDK _instance;
	public SnowboySDK() : base(true, "canListenChanged") {
		 if (_instance != null) return;

    _instance = this;
    Resource.SetGlobalKey(_instance, "SnowboySDK");
    AddMember(new NativeFunction("Test", (NativeCallback)Test));
    AddMember(new NativeFunction("InitDetector", (NativeCallback)InitDetector));
    AddMember(new NativeFunction("CanListen", (NativeCallback)CanListen));
    AddMember(new NativeFunction("EnsurePerms", (NativeCallback)EnsurePerms));
	}

  object EnsurePerms(Context c, object[] args) {
    Emit("canListenChanged", true);

    return null;
  }

  object CanListen(Context c, object[] args) {
    return true;
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