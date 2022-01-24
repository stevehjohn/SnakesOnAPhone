/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "Constants.h"
#import "UIAlertViewDelegate.h"
#import "IGenericEvent.h"

@implementation UIAlertViewDelegate

@synthesize m_Alert, m_TextField, m_Text;

- (void) alertView: (UIAlertView*) alertView didDismissWithButtonIndex: (NSInteger) buttonIndex
{
  if (m_TextField != nil)
    [self textEntered];
  else 
  {
    if (m_Receiver)
    {
      m_Receiver->EventRaised(EVENT_ALERT_DISMISSED, self);
      m_Receiver = NULL;
    }
  }
}

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
  [m_Alert dismissWithClickedButtonIndex: 0 animated: YES];
  
  if (m_TextField != nil)
    [self textEntered];
  
  return NO;
}

- (void) textEntered
{  
  self.m_Text = self.m_TextField.text;
  
  if (m_Receiver)
  {
    m_Receiver->EventRaised(EVENT_TEXT_ENTERED, self);
    m_Receiver = NULL;
  }

  [m_Alert release];
  [m_TextField release];
}

- (void) dismiss
{
  [m_Alert dismissWithClickedButtonIndex: 0 animated: YES];
}

- (BOOL) textField: (UITextField*) textField shouldChangeCharactersInRange: (NSRange) range replacementString: (NSString*) string
{
  if (textField.text.length >= HIGH_SCORE_NAME_LENGTH && range.length == 0)
    return NO;
  
  return YES;
}

- (id) initWithReceiver: (IGenericEvent*) receiver: (NSString*) text: (NSString*) caption: (BOOL) textBox: (NSString*) message: (NSString*) button
{
  m_Receiver = receiver;
  
  self.m_Alert = [[UIAlertView alloc] init];
  m_Alert.title = caption;
  m_Alert.delegate = self;
  
  if (textBox)
  {
    m_Alert.message = @"\n\n";
    self.m_TextField = [[UITextField alloc] initWithFrame:CGRectMake(12, 40, 260, 25)];
    m_TextField.delegate = self;
    m_TextField.borderStyle = UITextBorderStyleRoundedRect;
    m_TextField.text = text;
    [m_TextField becomeFirstResponder];
    [m_Alert addSubview: m_TextField];
  }
  else
  {
    m_TextField = nil;
    m_Alert.message = message;
  }
  
  [m_Alert addButtonWithTitle: button];

  [m_Alert show];
  
  return [super init];
}

- (void) dealloc
{
  m_Alert.delegate = nil;
  
  [super dealloc];
}

@end