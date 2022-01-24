/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "ITimerCallback.h"

@interface Timer : NSObject
{
@private
  NSTimer* m_Timer;
  ITimerCallback* m_Callback;
}

-(void) Start: (ITimerCallback*) callback: (float) interval; 
-(void) Stop;
-(void) Tick;

-(void) dealloc;

@property (nonatomic, retain) NSTimer* timer;

@end