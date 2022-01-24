/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <AVFoundation/AVAudioPlayer.h>

@interface AVAudioPlayerDelegate : NSObject <AVAudioPlayerDelegate>
{
  AVAudioPlayer* m_Player;
  BOOL m_Playing;
  NSString* m_LastFileName;
  NSString* m_LastFileType;
}

- (void) PlayBGMusic: (NSString*) fileName: (NSString*) fileType;
- (void) Pause;
- (void) Resume;
- (void) Stop;

@property (nonatomic, retain) AVAudioPlayer* player;
@property (nonatomic, copy) NSString* lastFileName;
@property (nonatomic, copy) NSString* lastFileType;

@end
