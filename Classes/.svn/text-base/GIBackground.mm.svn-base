/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "Constants.h"
#import "GIBackground.h"
#import "Utils.h"

GIBackground::GIBackground(int arenaW, int arenaH, int bgItemCount)
{
  m_ArenaW = arenaW;
  m_ArenaH = arenaH;
  InitBG(bgItemCount);
  m_SpriteY = arc4random() % 3;
}

void GIBackground::InitBG(int bgItems)
{
  BasicSprite sprite;
  for (int i = 0; i < bgItems; i++)
  {
    bool found = FALSE;
    do
    {
      sprite.x = (arc4random() % (m_ArenaW / BG_SPRITE_SIZE) - 2) * BG_SPRITE_SIZE + BG_SPRITE_SIZE;
      sprite.y = (arc4random() % (m_ArenaH / BG_SPRITE_SIZE) - 2) * BG_SPRITE_SIZE + BG_SPRITE_SIZE;
      vector<BasicSprite>::iterator iter = m_BGItems.begin();
      found = FALSE;
      for (; iter != m_BGItems.end(); ++iter)
      {
        if (iter->x == sprite.x && iter->y == sprite.y)
        {
          found = TRUE;
          break;
        }
      }
    } while (found);
    sprite.angle = (arc4random() % 4) * 90;
    sprite.spriteX = arc4random() % 2 + 1; // I only like the flowers and stones at the moment
    sprite.spriteY = 0;
    m_BGItems.push_back(sprite);
  }
}

void GIBackground::Render(GL2DView* view)
{
  // Don't need alpha blending for the background (grass) tiles
  view->SetAlphaBlendState(FALSE);
  int s1, s2;
  for (int x = 0; x < m_ArenaW; x += BG_SPRITE_SIZE)
  {
    s1 = (x / BG_SPRITE_SIZE) % 2;
    s2 = (x / BG_SPRITE_SIZE) % 2 * 2;
    for (int y = 0; y < m_ArenaH; y += BG_SPRITE_SIZE)
    {
      view->DrawSprite(BG_SPRITE_SHEET, s1 + s2, m_SpriteY, x, y, 0, 1.0, 1.0);
      s1 = 1 - s1;
    }  
  }
  view->SetAlphaBlendState(TRUE);
  
  /*
  vector<BasicSprite>::iterator iter = m_BGItems.begin();
  
  BasicSprite sprite;
  for (; iter != m_BGItems.end(); ++iter)
  {
    sprite = *iter;
    view->DrawSprite(BG_SPRITE_SHEET, sprite.spriteX, sprite.spriteY, sprite.x, sprite.y, sprite.angle, 1.0, 1.0);
  }
   */
}

int GIBackground::GetGameItemType()
{
  return GIBACKGROUND;
}

int GIBackground::GetBackgroundNumber()
{
  return m_SpriteY;
}