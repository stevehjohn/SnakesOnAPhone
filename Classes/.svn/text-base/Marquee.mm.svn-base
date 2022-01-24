/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "Marquee.h"
#import "Utils.h"

Marquee::Marquee(GL2DView* view) : IGLViewConsumer(view)
{
  m_Frame = 0;
  m_ItemNo = 0;
  m_Text = NULL;
}

Marquee::~Marquee()
{
  if (m_Text)
  {
    delete m_Text;
    m_Text = NULL;
  }
}

void Marquee::SetPosition(int x, int y)
{
  m_Coords.x = x;
  m_Coords.y = y;
}

void Marquee::AddText(string text)
{
  m_Items.push_back(text);
}

void Marquee::Render()
{
  if (m_Items.size() < 1)
    return;
  
  if (m_Frame == 0)
  {
    m_Text = new TextRenderer(m_View, m_Items[m_ItemNo], TextPositionManual, TextAnimationNone, Utils::IsiPad() ? 0.5 : 1.0);
    if (! Utils::IsiPad())
    {
      m_Text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
      m_Text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    }
    m_Text->SetPosition(m_Coords);
    m_Text->SetColour(1.0, 1.0, 1.0);
  }
  
  if (m_Frame < 15)
    m_Text->SetOpacity(m_Frame / 15.0);
  else if (m_Frame > MARQUEE_ITEM_DISPLAY_FRAMES + 15)
    m_Text->SetOpacity((15 - (m_Frame - MARQUEE_ITEM_DISPLAY_FRAMES - 15)) / 15.0);
  else
    m_Text->SetOpacity(1.0);
  
  m_Text->Render();
  m_Frame++;

  if (m_Frame > MARQUEE_ITEM_DISPLAY_FRAMES + 30)
  {
    m_Frame = 0;
    delete m_Text;
    m_Text = NULL;
    m_ItemNo++;
    if (m_ItemNo >= m_Items.size())
      m_ItemNo = 0;
  }
}