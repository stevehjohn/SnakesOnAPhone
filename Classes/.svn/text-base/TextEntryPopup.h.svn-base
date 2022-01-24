/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <string>

#import "IGenericEvent.h"
#import "UIAlertViewDelegate.h"

using namespace std;

class TextEntryPopup : public IGenericEvent
{
private:
  IGenericEvent* m_Controller;
  UIAlertViewDelegate* m_Alert;
  string m_Text;
  
public:
  TextEntryPopup(IGenericEvent* controller, string text, string caption);
  ~TextEntryPopup();

  void EventRaised(int eventType, void* raiser);

  string GetText();
};