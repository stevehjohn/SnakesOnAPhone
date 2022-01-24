/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "TextEntryPopup.h"
#import "Constants.h"
#import "Utils.h"

TextEntryPopup::TextEntryPopup(IGenericEvent* controller, string text, string caption)
{
  m_Controller = controller;

  m_Alert = [[UIAlertViewDelegate alloc] initWithReceiver: this: Utils::StdStringToNSString(text): Utils::StdStringToNSString(caption): YES: nil: @STR_OK];
}

TextEntryPopup::~TextEntryPopup()
{
  //[m_Alert release];
}

string TextEntryPopup::GetText()
{
  return m_Text;
}

void TextEntryPopup::EventRaised(int eventType, void* raiser)
{
  if (eventType == EVENT_TEXT_ENTERED)
  {
    m_Text = Utils::NSStringToStdString([m_Alert m_Text]);
    
    m_Controller->EventRaised(EVENT_TEXT_ENTERED, this);
  }
}
