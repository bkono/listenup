#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <EZAudio/EZAudio.h>
#import "snowboy-detect.h"
#import "uObjC.Foreign.h"

@interface SnowboyListener : NSObject <EZMicrophoneDelegate>
{
  snowboy::SnowboyDetect *_snowboyDetect;
  int detection_countdown;
}

@property(nonatomic, strong) EZMicrophone *microphone;

- (void)initPermissions;
- (void)initSnowboy:(NSString *)commonRes umdlPath:(NSString *)umdl;
- (void)initMic;
- (void)startKeywordSpotting;

@end