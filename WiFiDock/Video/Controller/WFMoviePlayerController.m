//
//  WFMoviePlayerController.m
//  WiFiDock
//
//  Created by apple on 15-1-9.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFMoviePlayerController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface WFMoviePlayerController ()
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@end

@implementation WFMoviePlayerController


- (MPMoviePlayerController *)moviePlayer
{
    if (!_moviePlayer) {
        
        _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:self.movieURL];
        _moviePlayer.view.frame = self.view.bounds;
        _moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_moviePlayer.view];
    }
    return _moviePlayer;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.moviePlayer play];
    [self addNotification];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.moviePlayer.fullscreen = YES;
}

- (void)addNotification
{
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(stateChanged) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    
    [nc addObserver:self selector:@selector(finished) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    [nc addObserver:self selector:@selector(finished) name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    
    [nc addObserver:self selector:@selector(captureFinished:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:nil];
}

- (void)captureImageAtTime:(float)time
{
    [self.moviePlayer requestThumbnailImagesAtTimes:@[@(time)] timeOption:MPMovieTimeOptionNearestKeyFrame];
}

- (void)captureFinished:(NSNotification *)notification
{
    
    [self.delegate moviePlayerDidCapturedWithImage:notification.userInfo[MPMoviePlayerThumbnailImageKey]];
}

- (void)finished
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.delegate moviePlayerDidFinished];
    NSLog(@"完成");
}

- (void)stateChanged
{
    switch (self.moviePlayer.playbackState) {
        case MPMoviePlaybackStatePlaying:
            NSLog(@"播放");
            break;
        case MPMoviePlaybackStatePaused:
            NSLog(@"暂停");
            break;
        case MPMoviePlaybackStateStopped:
            // 执行[self.moviePlayer stop]或者前进后退不工作时会触发
            NSLog(@"停止");
            break;
        default:
            break;
    }
}

@end
