/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <Foundation/Foundation.h>
#import <vector>

#import "ITouchReceiver.h"

using namespace std;

@interface UIViewGL : UIView 
{
@private
  vector<ITouchReceiver*> m_Receivers;
}

-(void) addTouchReceiver:(ITouchReceiver*) receiver;
-(void) dispatchTouches: (UIEvent*) event;

@end
