/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "Timer.h"

@implementation Timer

@synthesize timer = m_Timer;

- (id) init
{
  m_Callback = NULL;
  self.timer = nil;
  return [super init];
}

- (void) Start: (ITimerCallback*) callback: (float) interval
{
  m_Callback = callback;
  if (self.timer != nil)
  {
    [self.timer invalidate];
    self.timer = nil;
  }
  self.timer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval) interval
                                           target:self
                                         selector:@selector (Tick)
                                         userInfo:nil
                                          repeats:TRUE];
}

- (void) Stop
{
  if (self.timer != nil)
  {
    [self.timer invalidate];
    self.timer = nil;
  }
}

- (void) Tick
{
  m_Callback->Tick();
}

- (void) dealloc
{
  if (self.timer != nil)
  {
    [self.timer invalidate];
    self.timer = nil;
  }
  [super dealloc];
}

@end
