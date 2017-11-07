using Fuse;
using Fuse.Scripting;
using Uno;
using Uno.Permissions;
using Uno.UX;
using Uno.Compiler.ExportTargetInterop;

[UXGlobalModule]
[Require("Cocoapods.Platform.Name", "ios")]
[Require("Cocoapods.Platform.Version", "10.0")]
[Require("Cocoapods.Podfile.Target", "pod 'EZAudio'")]
public extern(iOS) class SnowboySDK : NativeEventEmitterModule {
  bool _canListen = false; 
  static readonly SnowboySDK _instance;

  public SnowboySDK() : base(true, "canListenChanged", "started", "stopped", "errored", "spotted") {
    if (_instance != null) return;

    _instance = this;
    Resource.SetGlobalKey(_instance, "SnowboySDK");
    AddMember(new NativeFunction("Test", (NativeCallback)Test));
    AddMember(new NativeFunction("InitDetector", (NativeCallback)InitDetector));
    AddMember(new NativeFunction("StartKeywordSpotting", (NativeCallback)StartKeywordSpotting));
    AddMember(new NativeFunction("StopKeywordSpotting", (NativeCallback)StopKeywordSpotting));
    AddMember(new NativeFunction("CanListen", (NativeCallback)CanListen));
    AddMember(new NativeFunction("EnsurePerms", (NativeCallback)EnsurePerms));
  }

  object CanListen(Context c, object[] args) {
    return true;
  }

  object EnsurePerms(Context c, object[] args) {
    Emit("canListenChanged", true);

    return null;
  }

  object StartKeywordSpotting(Context c, object[] args) {
    Emit("started");
    Emit("spotted", 1);
    Emit("stopped");

    return true;
  }

  object StopKeywordSpotting(Context c, object[] args) {
    Emit("stopped");
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
