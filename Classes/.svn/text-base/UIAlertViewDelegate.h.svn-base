/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <UIKit/UIAlertView.h>

#import "IGenericEvent.h"

@interface UIAlertViewDelegate : NSObject <UIAlertViewDelegate, UITextFieldDelegate>
{
@private
  UIAlertView* m_Alert; 
  UITextField* m_TextField;
  IGenericEvent* m_Receiver;
  NSString* m_Text;
}

@property (nonatomic, retain) UIAlertView* m_Alert;
@property (nonatomic, retain) UITextField* m_TextField;
@property (nonatomic, retain) NSString* m_Text;

- (id) initWithReceiver: (IGenericEvent*) receiver: (NSString*) text: (NSString*) caption: (BOOL) textBox: (NSString*) message: (NSString*) button;
- (void) textEntered;
- (void) dismiss;

@end