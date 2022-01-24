/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "TextRenderer.h"
#import "ITouchReceiver.h"

class TouchableTextRenderer : public TextRenderer, public ITouchReceiver
{
private:
  int m_UserRef;
  TouchableTextRenderer();
  bool m_ShowBorder;
  bool m_Bounced;
  float m_Button[342];
  bool m_ButtonCalculated;
  bool m_AcceptInput;
  float m_BorderWidth;
  bool m_FireOnTouch;
  
  void CalcButton();
  
public:
  TouchableTextRenderer(GL2DView* view, string text, TextPosition position, TextAnimation animation, float scale);
  void TouchEvent(TouchInfo touches[], int count);
  
  void SetUserRef(int userRef);
  int GetUserRef();
  void SetShowBorder(bool showBorder);
  void SetBorderWidth(float width);
  void SetFireOnTouch(bool fireOnTouch);
  
  void Render();
};