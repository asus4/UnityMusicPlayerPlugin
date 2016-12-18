//
//  UnityMusicPlayerPlugin.h
//  UnityMPMusicPlayer
//
//  Created by Koki Ibukuro on 12/16/16.
//

#import <Foundation/Foundation.h>

@interface UnityMusicPlayerPlugin : NSObject


@property (atomic, readonly) double currentPlaybackTime;

+ (UnityMusicPlayerPlugin*) shared;
- (void) load:(UIViewController*)controller;
- (void) play;



@end
