using Fuse;
using Fuse.Platform;
using Fuse.Scripting;
using Uno;
using Uno.Permissions;
using Uno.UX;
using Uno.Compiler.ExportTargetInterop;

[UXGlobalModule]
[Require("Cocoapods.Platform.Name", "ios")]
[Require("Cocoapods.Platform.Version", "10.0")]
[Require("Cocoapods.Podfile.Target", "pod 'EZAudio'")]
[Require("LinkDirectory", "@('.':Path)")]
[Require("IncludeDirectory", "@('.':Path)")]
[Require("LinkLibrary", "snowboy-detect")]
[Require("Source.Include", "@('snowboy-detect.h':Path)")]
[ForeignInclude(Language.ObjC, "AVFoundation/AVFoundation.h")]
[ForeignInclude(Language.ObjC, "AudioToolbox/AudioToolbox.h")]
[ForeignInclude(Language.ObjC, "EZAudio/EZAudio.h")]
[ForeignInclude(Language.ObjC, "SnowboyListener.hh")]
public extern(iOS) class SnowboySDK : NativeEventEmitterModule {
  bool _canListen = false; 
  static readonly SnowboySDK _instance;
  public static ObjC.Object _listener;
  public static bool _initialized = false;

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

    Lifecycle.Started += Started;
  }

  [Foreign(Language.ObjC)]
  extern(iOS) void Started(ApplicationState state)
  @{
    NSLog(@"starting Started");
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [session setMode:AVAudioSessionModeMeasurement error:&error];
    
    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
    
    [session setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    if (error) {
        NSLog(@"ERROR%@", error);
    }
    NSLog(@"about to alloc the listener started");
    SnowboyListener* s = [[SnowboyListener alloc] init];
    @{_listener:Set(s)};
    NSLog(@"past alloc the listener");
  @}

  object CanListen(Context c, object[] args) {
    return true;
  }

  static void OnStarted() {
    _instance.Emit("started");
  }

  static void OnStopped() {
    debug_log "stopped spotting";
    _instance.Emit("stopped");
  }

  static void OnError() {
    debug_log "error during spotting";
    _instance.Emit("errored");
  }

  static void OnSpotted(int result) {
    debug_log "spotted, result = " + result;
    _instance.Emit("spotted", result);
  }

  object EnsurePerms(Context c, object[] args) {
    debug_log "in ensure perms";
    if(_listener == null) {
      debug_log "listener still null";
      return null;
    }

    EnsurePermsImpl(_listener);
    Emit("canListenChanged", true);

    return null;
  }

  [Foreign(Language.ObjC)]
  public static void EnsurePermsImpl(ObjC.Object listener) 
  @{
    NSLog(@"in ensure perms impl");
    SnowboyListener *ls = (SnowboyListener *)listener;
    [ls initPermissions];
  @}

  object StartKeywordSpotting(Context c, object[] args) {
    StartKeywordSpottingImpl(_listener); 
    return true;
  }

  [Foreign(Language.ObjC)]
  public static void StartKeywordSpottingImpl(ObjC.Object listener) 
  @{
    NSLog(@"in start keyword spotting");
    SnowboyListener *ls = (SnowboyListener *)listener;
    [ls startKeywordSpotting];
  @}

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

    if (_initialized) {
      debug_log "already intialized";
      return null;
    }

    debug_log args;  
    InitDetectorImpl(_listener, args[0] as string, args[1] as string);
    _initialized = true;

    return null;
  }

  [Foreign(Language.ObjC)]
  public static void InitDetectorImpl(ObjC.Object listener, string commonRes, string umdl) 
  @{
    SnowboyListener *ls = (SnowboyListener *)listener;
    [ls initSnowboy:commonRes umdlPath:umdl];
    [ls initMic];
  @}
}
