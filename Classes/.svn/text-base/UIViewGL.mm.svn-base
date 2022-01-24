/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "UIViewGL.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIViewGL

+(Class) layerClass
{
  return [CAEAGLLayer class];
}

-(void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event
{
  [self dispatchTouches: event];
}

-(void) touchesMoved: (NSSet *) touches withEvent: (UIEvent *)event
{
  [self dispatchTouches: event];
}

-(void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *)event
{
  [self dispatchTouches: event];
}

-(void) addTouchReceiver:(ITouchReceiver*) receiver
{
  m_Receivers.push_back(receiver);
}

-(void) dispatchTouches:(UIEvent*) event
{
  int count = event.allTouches.count;
  TouchInfo info[count];
  
  int i = 0;
  for (UITouch *touch in event.allTouches)
  {
    CGPoint tCoords = [touch locationInView: self];
    info[i].x = tCoords.x;
    info[i].y = tCoords.y;
    switch ([touch phase])
    {
      case UITouchPhaseBegan:
        info[i].phase = Began;
        break;
      case UITouchPhaseMoved:
        info[i].phase = Moved;
        break;
      case UITouchPhaseStationary:
        info[i].phase = Stationary;
        break;
      case UITouchPhaseEnded:
        info[i].phase = Ended;
        break;
      case UITouchPhaseCancelled:
        info[i].phase = Cancelled;
        break;
    }
    i++;
  }
  
  vector<ITouchReceiver*>::iterator iter = m_Receivers.begin();
  
  for (; iter != m_Receivers.end(); ++iter)
  {
    (*iter)->TouchEvent(info, count);
  }
}

@end
