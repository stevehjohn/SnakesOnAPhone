/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "AVAudioPlayerDelegate.h"
#import "Constants.h"

@implementation AVAudioPlayerDelegate

@synthesize player = m_Player, lastFileName = m_LastFileName, lastFileType = m_LastFileType;

- (id) init
{
  m_Playing = NO;
  self.player = nil;
  
  return [super init];
}

- (void) PlayBGMusic: (NSString*) fileName: (NSString*) fileType
{
  [self setLastFileName: fileName];
  [self setLastFileType: fileType];
  
  NSString* path = [[NSBundle mainBundle] pathForResource: fileName ofType: fileType];
  
  NSURL* url = [NSURL fileURLWithPath: path];
  
  NSError* err = nil;
  
  if (self.player != nil)
  {
    [self Stop];
  }
  
  self.player = [AVAudioPlayer alloc];
  [self.player initWithContentsOfURL: url error: &err];
  [self.player setDelegate: self];
  
  [self.player play];
  m_Playing = YES;
}

- (void) Pause
{
  if (! m_Playing)
    return;
  
  [self.player pause];
}

- (void) Resume
{
  if (! m_Playing)
    return;

  [self.player play];
}

- (void) Stop
{
  if (self.player != nil)
    [self.player stop];
  self.player = nil;
  m_Playing = NO;
}

- (void) Replay
{
  [self PlayBGMusic: self.lastFileName: self.lastFileType];
}

#pragma mark AVAudioPlayerDelegate methods
   
- (void) audioPlayerDidFinishPlaying: (AVAudioPlayer*) player successfully: (BOOL) flag
{
  [NSTimer scheduledTimerWithTimeInterval: BG_MUSIC_REPEAT_PAUSE
                                   target: self
                                 selector: @selector(Replay)
                                 userInfo: nil
                                  repeats: NO];
}

@end
