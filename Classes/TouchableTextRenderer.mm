/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "TouchableTextRenderer.h"
#import "Constants.h"
#import "ALManager.h"

TouchableTextRenderer::TouchableTextRenderer(GL2DView* view, string text, TextPosition position, TextAnimation animation, float scale) 
  : TextRenderer(view, text, position, animation, scale)
{
  m_UserRef = 0;
  m_Controller = NULL;
  m_ShowBorder = TRUE;
  m_Bounced = FALSE;
  m_ButtonCalculated = FALSE;
  m_AcceptInput = FALSE;
  m_BorderWidth = 1.5;
  m_FireOnTouch = FALSE;
}

void TouchableTextRenderer::CalcButton()
{
  int hh, hw;
  if (m_Orientation == TextOrientationHorizontal)
  {
    hw = m_TextSize / 2 * m_Scale;
    hh = m_FontSpriteSize * m_BorderWidth * m_Scale;
  }
  else
  {
    hw = m_FontSpriteSize * m_BorderWidth * m_Scale;
    hh = m_TextSize / 2 * m_Scale;
  }
  m_Button[0] = m_X - hh;
  m_Button[1] = m_Y - hw;
  m_Button[2] = 0;
  m_Button[3] = m_X + hh;
  m_Button[4] = m_Y + hw;
  m_Button[5] = 0;
  m_Button[6] = m_X + hh;
  m_Button[7] = m_Y - hw;
  m_Button[8] = 0;
  
  m_Button[9] = m_X - hh;
  m_Button[10] = m_Y - hw;
  m_Button[11] = 0;
  m_Button[12] = m_X + hh;
  m_Button[13] = m_Y + hw;
  m_Button[14] = 0;
  m_Button[15] = m_X - hh;
  m_Button[16] = m_Y + hw;
  m_Button[17] = 0;

  int idx = 18;
  int start = 0;
  int end = 170;
  if (m_Orientation == TextOrientationHorizontal)
    hh = 0;
  else
  {
    hw = 0;
    start += 90;
    end += 90;
  }
  for (int i = start; i <= end; i += 10)
  {
    m_Button[idx] = m_X + hh;
    idx++;
    m_Button[idx] = m_Y + hw;
    idx++;
    m_Button[idx] = 0;
    idx++;
    m_Button[idx] = m_X + hh - cos(i * PI / 180) * m_FontSpriteSize * m_BorderWidth * m_Scale;
    idx++;
    m_Button[idx] = m_Y + hw + sin(i * PI / 180) * m_FontSpriteSize * m_BorderWidth * m_Scale;
    idx++;
    m_Button[idx] = 0;
    idx++;
    m_Button[idx] = m_X + hh - cos((i + 10) * PI / 180) * m_FontSpriteSize * m_BorderWidth * m_Scale;
    idx++;
    m_Button[idx] = m_Y + hw + sin((i + 10) * PI / 180) * m_FontSpriteSize * m_BorderWidth * m_Scale;
    idx++;
    m_Button[idx] = 0;
    idx++;

    m_Button[idx] = m_X - hh;
    idx++;
    m_Button[idx] = m_Y - hw;
    idx++;
    m_Button[idx] = 0;
    idx++;
    m_Button[idx] = m_X - hh + cos(i * PI / 180) * m_FontSpriteSize * m_BorderWidth * m_Scale;
    idx++;
    m_Button[idx] = m_Y - hw - sin(i * PI / 180) * m_FontSpriteSize * m_BorderWidth * m_Scale;
    idx++;
    m_Button[idx] = 0;
    idx++;
    m_Button[idx] = m_X - hh + cos((i + 10) * PI / 180) * m_FontSpriteSize * m_BorderWidth * m_Scale;
    idx++;
    m_Button[idx] = m_Y - hw - sin((i + 10) * PI / 180) * m_FontSpriteSize * m_BorderWidth * m_Scale;
    idx++;
    m_Button[idx] = 0;
    idx++;
  }
  
  m_ButtonCalculated = TRUE;
}

void TouchableTextRenderer::Render()
{
  if (m_ShowBorder && m_Visible)
  {  
    if (! m_ButtonCalculated)
      CalcButton();    
    
    m_AcceptInput = FALSE;
    float opacity = 0.5;
    if (m_Animation & TextAnimationDropOff)
    {
      opacity += m_DropOffsets[0] / 80;
      m_Bounced = FALSE;
    }
    else if (! m_Bounced)
    {
      opacity -= m_DropOffsets[0] / 80;
    }
    if (opacity < 0) 
      opacity = 0;
    else if (opacity >= 0.5)
    {
      opacity = 0.5;
      m_Bounced = TRUE;
      m_AcceptInput = TRUE;
    }
    if (m_Orientation != TextOrientationHorizontal)
      m_View->DrawShape(m_Button, 114, opacity, 0.0, 0.0, 0.0);
    else
      m_View->DrawShape(m_Button, 114, opacity, 0.0, 0.0, 0.0);
  }
  
  TextRenderer::Render();
}

void TouchableTextRenderer::TouchEvent(TouchInfo touches[], int count)
{
  bool hit = FALSE;
  
  if (count == 1 && touches[0].phase == Ended)
  {
    if (m_ShowBorder)
    {
      if (m_AcceptInput)
      {
        int tx = touches[0].x;
        int ty = m_View->GetViewH() - touches[0].y;

        int hw, hh;
        if (m_Orientation == TextOrientationHorizontal)
        {
          hw = m_TextSize / 2 * m_Scale + m_FontSpriteSize * 1.5 * m_Scale;
          hh = m_FontSpriteSize * 1.5 * m_Scale;
        }
        else
        {
          hw = m_FontSpriteSize * 1.5 * m_Scale;
          hh = m_TextSize / 2 * m_Scale + m_FontSpriteSize * 1.5 * m_Scale;
        }
        if (tx >= m_X - hh && tx <= m_X + hh && ty >= m_Y - hw && ty <= m_Y + hw)
          hit = TRUE;
      }
    }
    else
    {
      int tx = touches[0].x;
      int ty = m_View->GetViewH() - touches[0].y;
      
      float inc = m_FontSpriteSize * m_Scale * m_CharSpacing;
      float x, y;
      int rot;
      if (m_Orientation == TextOrientationHorizontal)
      {
        rot = 90;
        x = m_X - (m_FontSpriteSize / 2);
        if (m_Anchor == TextAnchorCentre)
          y = m_Y - (m_TextSize / 2) * m_Scale * m_CharSpacing - ((1.0 - m_Scale * m_CharSpacing) * m_FontSpriteSize) / 2;
        else if (m_Anchor == TextAnchorLeft)
          y = m_Y - m_TextSize * m_Scale * m_CharSpacing - (1.0 - m_Scale * m_CharSpacing) * m_FontSpriteSize;
        else if (m_Anchor == TextAnchorRight)
          y = m_Y;
      }
      else if (m_Orientation == TextOrientation270)
      {
        rot = 180;
        x = m_X - (m_TextSize / 2) * m_Scale * m_CharSpacing - ((1.0 - m_Scale * m_CharSpacing) * m_FontSpriteSize) / 2;
        y = m_Y - (m_FontSpriteSize / 2);
      }
      else 
      {
        rot = 0;
        x = m_X - (m_TextSize / 2) * m_Scale * m_CharSpacing - ((1.0 - m_Scale * m_CharSpacing) * m_FontSpriteSize) / 2 + inc * (m_TextLen - 1);
        y = m_Y - (m_FontSpriteSize / 2);
      }
      
      if (m_Animation & TextAnimationJiggleLeft)
        y += sin(m_JiggleVar * PI / 180) * m_FontSpriteSize * m_Scale / 8 + m_FontSpriteSize * m_Scale / 8;
      else if (m_Animation & TextAnimationJiggleRight)
        y -= sin(m_JiggleVar * PI / 180) * m_FontSpriteSize * m_Scale / 8 + m_FontSpriteSize * m_Scale / 8;
      
      for (int i = m_TextLen - 1; i >= 0; i--)
      {
        if (tx >= x + m_DropOffsets[i] + (1.0 - m_Scale) * m_FontSpriteSize / 2
            && ty >= y + (1.0 - m_Scale) * m_FontSpriteSize / 2
            && tx <= x + m_DropOffsets[i] + m_FontSpriteSize * m_Scale + (1.0 - m_Scale) * m_FontSpriteSize / 2
            && ty <= y + m_FontSpriteSize * m_Scale + (1.0 - m_Scale) * m_FontSpriteSize / 2)
        {
          hit = TRUE;
          break;
        }

        if (m_Orientation == TextOrientationHorizontal)
          y += inc;
        else if (m_Orientation == TextOrientation270)
          x += inc;
        else 
          x -= inc;
      }
    }
  }
  
  if (hit)
  {
    ALManager::Instance()->PlaySound(SOUND_BOING);
    m_Animation |= TextAnimationSplat;
    m_StateVar = TEXT_ANIMATE_SPLAT_FRAMES;
    if (! m_FireOnTouch)
      m_FireEventWhenDone = EVENT_TEXT_TOUCHED;
    else
    {
      if (m_Controller)
        m_Controller->EventRaised(EVENT_TEXT_TOUCHED, this);
    }
  }
}

void TouchableTextRenderer::SetUserRef(int userRef)
{
  m_UserRef = userRef;
}

int TouchableTextRenderer::GetUserRef()
{
  return m_UserRef;
}

void TouchableTextRenderer::SetShowBorder(bool showBorder)
{
  m_ShowBorder = showBorder;
}

void TouchableTextRenderer::SetBorderWidth(float width)
{
  m_BorderWidth = width;
}

void TouchableTextRenderer::SetFireOnTouch(bool fireOnTouch)
{
  m_FireOnTouch = fireOnTouch;
}
