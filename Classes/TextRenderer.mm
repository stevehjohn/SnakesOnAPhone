/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "TextRenderer.h"
#import "Utils.h"
#import "Constants.h"

TextRenderer::TextRenderer(GL2DView* view, string text, TextPosition position, TextAnimation animation, float scale) : IGLViewConsumer(view)
{
  m_FontSheetRef = FONT_SPRITE_SHEET;
  m_FontSpriteSize = FONT_SPRITE_SIZE;
  m_Visible = TRUE;
  m_Controller = NULL;
  m_Animation = animation;
  m_Position = position;
  Utils::TextToSpriteCoords(text, m_FontSprites);
  m_StateVar = 0;
  m_JiggleVar = 0;
  m_TextLen = text.length();
  m_TextSize = m_TextLen * FONT_SPRITE_SIZE;
  m_Scale = scale;
  m_FireEventWhenDone = -1;
  m_Orientation = TextOrientationHorizontal;
  m_Anchor = TextAnchorCentre;
  m_Opacity = 1.0;
  switch (position)
  {
    case TextPositionManual:
      m_X = -1;
      m_Y = -1;
      break;
    case TextPositionCentreScreen:
      m_X = view->GetViewW() / 2;
      m_Y = view->GetViewH() / 2;
      break;
  }
  m_R = -1;
  m_G = -1;
  m_B = -1;
  m_CharSpacing = 1.0;
  
  for (int i = 0; i < m_TextLen; i++)
  {
    if (m_Animation == TextAnimationDropBounce)
    {
      m_DropOffsets.push_back(view->GetViewW() - m_X + FONT_SPRITE_SIZE / 2);
      m_DropAccelVals.push_back(((arc4random() % 40) + 40) / 10.0);
    }
    else
    {
      m_DropOffsets.push_back(0);
      m_DropAccelVals.push_back(0);
    }
  }
}

void TextRenderer::SetColour(float r, float g, float b)
{
  m_R = r;
  m_G = g;
  m_B = b;
}

void TextRenderer::SetPosition(int x, int y)
{
  m_X = x;
  m_Y = y;

  if (m_Animation == TextAnimationDropBounce)
  {
    m_DropOffsets.clear();
    for (int i = 0; i < m_TextLen; i++)
    {
      m_DropOffsets.push_back(m_View->GetViewW() - m_X + m_FontSpriteSize / 2);
    }
  }
}

void TextRenderer::SetPosition(Coords c)
{
  SetPosition(c.x, c.y);
}

void TextRenderer::SetCharSpacing(float spacing)
{
  m_CharSpacing = spacing;
}

void TextRenderer::SetOrientation(TextOrientation orientation)
{
  m_Orientation = orientation;
}

void TextRenderer::SetAnchor(TextAnchor anchor)
{
  m_Anchor = anchor;
}

void TextRenderer::AddAnimation(TextAnimation animation)
{
  m_Animation |= animation;
  
  if (animation == TextAnimationDropOff)
  {
    for (int i = 0; i < m_TextLen; i++)
    {
      m_DropAccelVals.clear();
      m_DropAccelVals.push_back(((arc4random() % 40) + 40) / 10.0);
    }
  }
  else if (animation == TextAnimationDropBounce)
  {
    m_DropOffsets.clear();
    m_DropAccelVals.clear();
    for (int i = 0; i < m_TextLen; i++)
    {
      m_DropOffsets.push_back(m_View->GetViewW() - m_X + m_FontSpriteSize / 2);
      m_DropAccelVals.push_back(((arc4random() % 40) + 40) / 10.0);
    }
  }
  else if (animation == TextAnimationSplat)
  {
    m_StateVar = 0;
    m_DropOffsets.clear();
    m_DropAccelVals.clear();
    for (int i = 0; i < m_TextLen; i++)
    {
      m_DropOffsets.push_back(0);
      m_DropAccelVals.push_back(0);
    }
  }
}

void TextRenderer::RemoveAnimation(TextAnimation animation)
{
  if (m_Animation & animation)
    m_Animation ^= animation;
}

void TextRenderer::SetVisible(bool visible)
{
  m_Visible = visible;
}

void TextRenderer::SetFontSheet(int fontSheetRef)
{
  m_FontSheetRef = fontSheetRef;
}

void TextRenderer::SetFontSpriteSize(int fontSpriteSize)
{
  m_FontSpriteSize = fontSpriteSize;
  m_TextSize = m_TextLen * m_FontSpriteSize;
  for (int i = 0; i < m_TextLen; i++)
  {
    if (m_Animation == TextAnimationDropBounce)
    {
      m_DropOffsets.push_back(m_View->GetViewW() - m_X + m_FontSpriteSize / 2);
      m_DropAccelVals.push_back(((arc4random() % 40) + 40) / 10.0);
    }
    else
    {
      m_DropOffsets.push_back(0);
      m_DropAccelVals.push_back(0);
    }
  }  
}

Coords TextRenderer::GetCoords()
{
  Coords c;
  c.x = m_X;
  c.y = m_Y;
  
  return c;
}

void TextRenderer::SetOpacity(float opacity)
{
  m_Opacity = opacity;
}

void TextRenderer::Render()
{
  if (! m_Visible)
    return;
  
  if (m_Animation == TextAnimationNone)
  {
    DrawText(m_Scale, m_Opacity);
    return;
  }
  
  if (m_Animation & TextAnimationJiggleLeft || m_Animation & TextAnimationJiggleRight)
  {
    m_JiggleVar += TEXT_ANIMATE_JIGGLE_INCREMENT;
    if (m_JiggleVar > 360)
      m_JiggleVar -= 360;
  }
  
  if (m_Animation & TextAnimationDropBounce || m_Animation & TextAnimationDropOff)
    RenderDropBounce();

  if (m_Animation & TextAnimationSplat || m_Animation & TextAnimationSplatRepeat || m_Animation & TextAnimationZoomFade)
    RenderSplat();  
}

void TextRenderer::SetController(IGenericEvent* controller)
{
  m_FireEventWhenDone = EVENT_TEXT_ANIMATE_DONE;
  m_Controller = controller;
}

void TextRenderer::RenderSplat()
{
  float scale = m_Scale;
  if (m_StateVar < TEXT_ANIMATE_SPLAT_FRAMES)
    scale = (1.0 / (TEXT_ANIMATE_SPLAT_FRAMES - m_StateVar)) * m_Scale;

  if (! (m_Animation == TextAnimationZoomFade && m_StateVar > TEXT_ANIMATE_SPLAT_FRAMES))
    DrawText(scale, m_Opacity);
  
  if (m_StateVar > TEXT_ANIMATE_SPLAT_FRAMES && m_StateVar < TEXT_ANIMATE_SPLAT_FRAMES * 2)
  {
    DrawText(m_StateVar / (float) TEXT_ANIMATE_SPLAT_FRAMES * m_Scale, (2.0 - m_StateVar / (float) TEXT_ANIMATE_SPLAT_FRAMES) * m_Opacity);
  }
  
  if (m_Animation & TextAnimationSplatRepeat)
  {
    m_StateVar++;
    if (m_StateVar >= TEXT_ANIMATE_SPLAT_FRAMES * 4)
      m_StateVar = TEXT_ANIMATE_SPLAT_FRAMES;
  }
  else 
  {
    if (m_StateVar < TEXT_ANIMATE_SPLAT_FRAMES * 2)
      m_StateVar++;
    else if (m_FireEventWhenDone != -1)
    {
      if (m_Controller)
      {
        int evt = m_FireEventWhenDone;
        m_FireEventWhenDone = -1;
        m_Controller->EventRaised(evt, this);
      } 
    }
  }
}

void TextRenderer::RenderDropBounce()
{
  bool offscreen = TRUE;
  
  for (int i = 0; i < m_TextLen; i++)
  {
    if (m_X + m_DropOffsets[i] > -m_FontSpriteSize * m_Scale)
    {
      m_DropOffsets[i] -= m_DropAccelVals[i];
      m_DropAccelVals[i] += TEXT_DROP_ACCELERATION;
    }

    if (m_Animation & TextAnimationDropOff)
    {
      if (m_X + m_DropOffsets[i] > -m_FontSpriteSize * m_Scale)
        offscreen = FALSE;
    }
    else if (m_DropOffsets[i] < 0)
    {
      m_DropOffsets[i] = 0;
      m_DropAccelVals[i] /= 2;
      if (m_DropAccelVals[i] < TEXT_DROP_ACCELERATION * 2 + 1)
      {
        m_DropAccelVals[i] = 0;
        if (arc4random() % 500 == 0)
        {
          m_DropAccelVals[i] = -(2.0 + (arc4random() % 8));
          
          if (i > 0)
            m_DropAccelVals[i - 1] = m_DropAccelVals[i] / 1.5;
          if (i > 1)
            m_DropAccelVals[i - 2] = m_DropAccelVals[i - 1] / 1.5;
          
          if (i < m_TextLen - 1)
            m_DropAccelVals[i + 1] = m_DropAccelVals[i] / 1.5;
          if (i < m_TextLen - 2)
            m_DropAccelVals[i + 2] = m_DropAccelVals[i + 1] / 1.5;
        }
      }
      else
      {
        m_DropAccelVals[i] = -m_DropAccelVals[i];
      }
    }
  }
  
  if (! (m_Animation & TextAnimationSplat || m_Animation & TextAnimationSplatRepeat || m_Animation & TextAnimationZoomFade))
    DrawText(m_Scale, m_Opacity);
}

void TextRenderer::DrawText(float scale, float opacity)
{
  float inc = m_FontSpriteSize * scale * m_CharSpacing;
  float x, y;
  int rot;
  if (m_Orientation == TextOrientationHorizontal)
  {
    rot = 90;
    x = m_X - (m_FontSpriteSize / 2);
    if (m_Anchor == TextAnchorCentre)
      y = m_Y - (m_TextSize / 2) * scale * m_CharSpacing - ((1.0 - scale * m_CharSpacing) * m_FontSpriteSize) / 2;
    else if (m_Anchor == TextAnchorLeft)
      y = m_Y - m_TextSize * scale * m_CharSpacing - (1.0 - scale * m_CharSpacing) * m_FontSpriteSize;
    else if (m_Anchor == TextAnchorRight)
      y = m_Y;
  }
  else if (m_Orientation == TextOrientation270)
  {
    rot = 180;
    x = m_X - (m_TextSize / 2) * scale * m_CharSpacing - ((1.0 - scale * m_CharSpacing) * m_FontSpriteSize) / 2;
    y = m_Y - (m_FontSpriteSize / 2);
  }
  else 
  {
    rot = 0;
    x = m_X - (m_TextSize / 2) * scale * m_CharSpacing - ((1.0 - scale * m_CharSpacing) * m_FontSpriteSize) / 2 + inc * (m_TextLen - 1);
    y = m_Y - (m_FontSpriteSize / 2);
  }
  
  if (m_Animation & TextAnimationJiggleLeft)
    y += sin(m_JiggleVar * PI / 180) * m_FontSpriteSize * scale / 8 + m_FontSpriteSize * scale / 8;
  else if (m_Animation & TextAnimationJiggleRight)
    y -= sin(m_JiggleVar * PI / 180) * m_FontSpriteSize * scale / 8 + m_FontSpriteSize * scale / 8;
  
  for (int i = m_TextLen - 1; i >= 0; i--)
  {
    if (m_R == -1)
      m_View->DrawSprite(m_FontSheetRef, m_FontSprites[i].x, m_FontSprites[i].y, x + m_DropOffsets[i], y, rot, scale, opacity);
    else
      m_View->DrawSprite(m_FontSheetRef, m_FontSprites[i].x, m_FontSprites[i].y, x + m_DropOffsets[i], y, rot, scale, opacity, m_R, m_G, m_B);
    if (m_Orientation == TextOrientationHorizontal)
      y += inc;
    else if (m_Orientation == TextOrientation270)
      x += inc;
    else 
      x -= inc;
  }
}