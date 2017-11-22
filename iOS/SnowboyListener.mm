#import "SnowboyListener.hh"
@{SnowboySDK:IncludeDirective}

@implementation SnowboyListener

- (void) initPermissions {
   NSLog(@"initPermissions called");
   [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:nil];
}

// Needs to take params for the resources. and cross fingers.
- (void)initSnowboy:(NSString *)commonRes 
                    umdlPath:(NSString *)umdl {
    NSLog(@"in initsnowboy");
    _snowboyDetect = NULL;
    // This is what's blowing up. need to use the paths provided
    _snowboyDetect = new snowboy::SnowboyDetect(std::string([commonRes UTF8String]),
                                                std::string([umdl UTF8String]));
    _snowboyDetect->SetSensitivity("0.5");
    _snowboyDetect->SetAudioGain(1.0);
}

- (void) initMic {
    AudioStreamBasicDescription audioStreamBasicDescription = [EZAudioUtilities monoFloatFormatWithSampleRate:16000];
    audioStreamBasicDescription.mFormatID = kAudioFormatLinearPCM;
    audioStreamBasicDescription.mSampleRate = 16000;
    audioStreamBasicDescription.mFramesPerPacket = 1;
    audioStreamBasicDescription.mBytesPerPacket = 2;
    audioStreamBasicDescription.mBytesPerFrame = 2;
    audioStreamBasicDescription.mChannelsPerFrame = 1;
    audioStreamBasicDescription.mBitsPerChannel = 16;
    audioStreamBasicDescription.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;
    audioStreamBasicDescription.mReserved = 0;
    
    NSArray *inputs = [EZAudioDevice inputDevices];
    [self.microphone setDevice:[inputs lastObject]];
    self.microphone = [EZMicrophone microphoneWithDelegate:self withAudioStreamBasicDescription:audioStreamBasicDescription];
}

- (void) startKeywordSpotting {
    detection_countdown = 5;
    [self.microphone startFetchingAudio];
    @{SnowboySDK.OnStarted():Call()};
}

- (void) stopKeywordSpotting {
    [self.microphone stopFetchingAudio];
    @{SnowboySDK.OnStopped():Call()};
}

-(void) microphone:(EZMicrophone *)microphone
  hasAudioReceived:(float **)buffer
    withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
    dispatch_async(dispatch_get_main_queue(),^{
        int result = _snowboyDetect->RunDetection(buffer[0], bufferSize);
        NSLog(@"result -> %i", result);
        if (result > 0) {
          NSLog(@"hotword detected");
          [self stopKeywordSpotting];
          detection_countdown = 30;
          @{SnowboySDK.OnSpotted(int):Call(result)};
        } else {
            if (detection_countdown == 0){
              NSLog(@"no hotword detected");
            } else {
                detection_countdown--;
            }
        }
    });
}

@end