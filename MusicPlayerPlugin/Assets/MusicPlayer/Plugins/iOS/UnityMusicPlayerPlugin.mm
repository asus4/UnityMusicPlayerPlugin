//
//  UnityMusicPlayerPlugin.mm
//  UnityMPMusicPlayer
//
//  Created by Koki Ibukuro on 12/16/16.
//

#import <MediaPlayer/MediaPlayer.h>
#import "UnityMusicPlayerPlugin.h"

// #define MakeStringCopy( _x_ ) ( _x_ != NULL && [_x_ isKindOfClass:[NSString class]] ) ? strdup( [_x_ UTF8String] ) : NULL
//extern void UnitySendMessage(const char *, const char *, const char *);


#pragma mark - UnityMusicPlayerPlugin

extern UIViewController* UnityGetGLViewController();

extern "C" {
    void _unityMusicPlayer_load() {
        [UnityMusicPlayerPlugin.shared load:UnityGetGLViewController()];
    }
    
    void _unityMusicPlayer_play() {
        [UnityMusicPlayerPlugin.shared play];
    }
    
    double _unityMusicPlayer_currentTime() {
        return UnityMusicPlayerPlugin.shared.currentPlaybackTime;
    }
}

#pragma mark - UnityMusicPlayerPlugin

@interface UnityMusicPlayerPlugin()<MPMediaPickerControllerDelegate>
{
    
}
@property (atomic, strong) MPMusicPlayerController* player;
@property (atomic, weak) UIViewController* viewController;
@end

@implementation UnityMusicPlayerPlugin

static UnityMusicPlayerPlugin * _shared;
+ (UnityMusicPlayerPlugin*) shared {
    @synchronized(self) {
        if(_shared == nil) {
            _shared = [[self alloc] init];
        }
    }
    return _shared;
}

- (id) init {
    if(self = [super init]) {
        self.player = [MPMusicPlayerController systemMusicPlayer];
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(onNowPlayingItemChanged:)
                                                   name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                                 object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(onPlaybackStateChanged:)
                                                   name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                                 object:nil];
        [self.player beginGeneratingPlaybackNotifications];
    }
    return self;
}

- (void) dealloc {
    [self.player endGeneratingPlaybackNotifications];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void) load:(UIViewController *)controller {
    self.viewController = controller;
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] init];
    picker.delegate = self;
    picker.allowsPickingMultipleItems = NO;
    [controller presentViewController:picker animated:YES completion:nil];
}

- (void) play {
    if(self.player.playbackState == MPMusicPlaybackStatePlaying) {
        [self.player pause];
    }
    else {
        [self.player play];
    }
}

- (void) onNowPlayingItemChanged:(NSNotification*) notification {
    MPMediaItem *item = self.player.nowPlayingItem;
    if(item == NULL) {
        return;
    }
    if(item.mediaType != MPMediaTypeMusic) {
        return;
    }
    
    NSDictionary *json = @{
        @"title":item.title,
        @"artist":item.artist,
        @"album":item.albumTitle,
        @"duration": [NSNumber numberWithDouble:item.playbackDuration],
        @"currentTime": [NSNumber numberWithDouble:self.currentPlaybackTime]
    };
    NSData *data = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    NSString* msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    // NSLog(@"%@", msg);
    
    UnitySendMessage("MusicPlayerPlugin", "OnItemChanged", msg.UTF8String);
}

- (void) onPlaybackStateChanged:(NSNotification*) notification {
    int state = self.player.playbackState;
    UnitySendMessage("MusicPlayerPlugin", "OnPlaybackStateChanged", [NSString stringWithFormat:@"%d", state].UTF8String);
}

- (double) currentPlaybackTime {
    double time = self.player.currentPlaybackTime;
    return isnan(time) ? 0 : time;
}


#pragma - MPMediaPickerControllerDelegate

- (void) mediaPicker:(MPMediaPickerController *)mediaPicker
   didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
    
    [self.player setQueueWithItemCollection:mediaItemCollection];
    [self.player play];
}

- (void) mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
