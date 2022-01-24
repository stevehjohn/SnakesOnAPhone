/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <cmath>

#import "GIWalls.h"
#import "Constants.h"
#import "Utils.h"

GIWalls::GIWalls(vector<BasicSprite>* walls)
{
  m_Blocks = walls;
}

//static GL2DView* tmpview = NULL;

void GIWalls::Render(GL2DView* view)
{
  vector<BasicSprite>::iterator iter = m_Blocks->begin();
  
  //tmpview = view;
  view->SetAlphaBlendState(FALSE);
  for (; iter != m_Blocks->end(); ++iter)
  {
    BasicSprite sprite = *iter;
    view->DrawSprite(OBSTACLE_SPRITE_SHEET, sprite.spriteX, sprite.spriteY, sprite.x, sprite.y, sprite.angle, 1.0, 1.0);
  }
  view->SetAlphaBlendState(TRUE);
}

bool GIWalls::CheckCollision(Coords coords, int size)
{
  vector<BasicSprite>::iterator iter = m_Blocks->begin();
  
  for (; iter != m_Blocks->end(); ++iter)
  {
    if ((*iter).x >= coords.x - OBSTACLE_SPRITE_SIZE &&
        (*iter).x < coords.x + size &&
        (*iter).y >= coords.y - OBSTACLE_SPRITE_SIZE &&
        (*iter).y < coords.y + size)
      return TRUE;
  }
  return FALSE;
}

bool GIWalls::CheckLineOfSight(Coords c1, Coords c2)
{
  float dist = Utils::CalculateDistance(c1, c2);
  float opp = (c2.y - c1.y);
  float oh = opp / dist;
  int targetAngle = asin(oh) * 180 / PI;
  if (c2.x > c1.x)
    targetAngle = (360 - targetAngle) % 360;
  targetAngle += 360;
  
  vector<BasicSprite>::iterator iter = m_Blocks->begin();
  
  for (; iter != m_Blocks->end(); ++iter)
  {
    Coords objCoords = { (*iter).x, (*iter).y };
    float objDist = Utils::CalculateDistance(c1, objCoords);
    if (objDist < dist)
    {
      opp = ((*iter).y - c1.y);
      oh = opp / objDist;
      int objAngle = asin(oh) * 180 / PI;
      if ((*iter).x > c1.x)
        objAngle = (360 - objAngle) % 360;
      objAngle += 360;
      
      if (targetAngle <= objAngle + 5 && targetAngle >= objAngle - 5)
      {
        /*
        if (tmpview)
        {
          BasicSprite sprite = *iter;
          tmpview->DrawSprite(OBSTACLE_SPRITE_SHEET, sprite.spriteX, sprite.spriteY, sprite.x, sprite.y, sprite.angle, 1.0, 1.0, 0.0, 0.0, 1.0);
          if (sprite.x == tmpview->GetViewW() - OBSTACLE_SPRITE_SIZE)
            int lksdf = 2938;
        }*/
        
        return FALSE;
      }
    }
  }
  
  return TRUE;
}

int GIWalls::GetGameItemType()
{
  return GIWALLS;
}