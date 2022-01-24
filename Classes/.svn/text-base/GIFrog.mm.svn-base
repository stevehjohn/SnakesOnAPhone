/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "GIFrog.h"
#import "Constants.h"
#import "Utils.h"

GIFrog::GIFrog(int boardW, int boardH)
{
  m_Coords.x = - GAME_SPRITE_SIZE * 10;
  m_Coords.y = - GAME_SPRITE_SIZE * 10;
  m_FrogDir = 0;
  m_FrogTargetDir = m_FrogDir; 
  m_StateVar = 0;
  m_State = FrogStateAppearing;
  m_Frame = 0;
  m_FrameDir = 1;
  m_FrameDelay = 0;
  m_DirChangeDelay = FROG_DIR_CHANGE_DELAY + arc4random() % FROG_DIR_CHANGE_DELAY_RANDOM;
  m_TargetFixed = TRUE;
  m_BoardW = boardW;
  m_BoardH = boardH;
  m_FrogType = FrogTypeNormal;
}

void GIFrog::Render(GL2DView* view)
{
  int spriteY = 2;
  if (m_FrogType == FrogTypeGrowMore)
    spriteY = 3;
  switch (m_State)
  {
    case FrogStateNormal:
      view->DrawSprite(GAME_SPRITE_SHEET, m_Frame, spriteY, m_Coords.x, m_Coords.y, m_FrogDir, 1.0, 1.0);
      break;
    case FrogStateAppearing:
      view->DrawSprite(GAME_SPRITE_SHEET, m_Frame, spriteY, m_Coords.x, m_Coords.y, m_FrogDir, m_StateVar / (float) FROG_SPAWN_FRAMES, 1.0);
      break;
    case FrogStateDisappearing:
      view->DrawSprite(GAME_SPRITE_SHEET, m_Frame, spriteY, m_Coords.x, m_Coords.y, m_FrogDir, 1.0 + m_StateVar / (float) FROG_SPAWN_FRAMES, 1.0 - m_StateVar / (float) FROG_SPAWN_FRAMES);
      break;
  }
}

void GIFrog::Update(vector<IGameItem*>* items, bool isClient)
{
  vector<IGameItem*>::iterator iter = items->begin();
  
  // Check interactions
  GIWalls* walls = NULL;
  if (! isClient)
  {
    for (; iter != items->end(); ++iter)
    {
      switch ((*iter)->GetGameItemType())
      {
        case GIWALLS:
          walls = dynamic_cast<GIWalls*> (*iter);
          break;
      }
    }
    if (m_Coords.x == - GAME_SPRITE_SIZE * 10)
      PlaceFrog(walls);
  }

  AngleDelta a = Utils::GetAngleDelta(m_FrogDir);
  m_Coords.x += a.dX * FROG_MOVE_INCREMENT;
  m_Coords.y += a.dY * FROG_MOVE_INCREMENT;

  if (walls)
    CheckWallCollision(walls);
  
  // Wrap around board
  if (m_Coords.x < -GAME_SPRITE_SIZE)
    m_Coords.x = m_BoardW;
  else if (m_Coords.x > m_BoardW)
    m_Coords.x = -GAME_SPRITE_SIZE;
  if (m_Coords.y < -GAME_SPRITE_SIZE)
    m_Coords.y = m_BoardH;
  else if (m_Coords.y > m_BoardH)
    m_Coords.y = -GAME_SPRITE_SIZE;
  
  Utils::TurnInDirection(m_FrogDir, m_FrogTargetDir);
  
  m_FrameDelay++;
  if (m_FrameDelay >= FROG_FRAME_DELAY)
  {
    m_Frame += m_FrameDir;
    if (m_Frame == 0 || m_Frame == 3)
      m_FrameDir = -m_FrameDir;
    m_FrameDelay = 0;
  }
  
  if (! isClient)
  {
    if (! m_TargetFixed)
    {
      m_DirChangeDelay--;
      if (m_DirChangeDelay < 1)
      {
        m_FrogTargetDir += ((arc4random() % 180) / TURN_DELTA) * TURN_DELTA - 90;
        m_FrogTargetDir = (m_FrogTargetDir + 360) % 360;
        m_DirChangeDelay = FROG_DIR_CHANGE_DELAY + arc4random() % FROG_DIR_CHANGE_DELAY_RANDOM;
      }
    } 
    else 
    {
      if (m_FrogDir == m_FrogTargetDir)
        m_TargetFixed = FALSE;
    }
  }
  
  // Update any animations
  if (m_State != FrogStateNormal)
  {
    m_StateVar++;
    if (m_StateVar >= FROG_SPAWN_FRAMES)
    {
      if (m_State == FrogStateDisappearing)
      {
        if (isClient)
        {
          // Place frog off screen until we get new coords from server
          m_Coords.x = - GAME_SPRITE_SIZE * 10;
          m_Coords.y = - GAME_SPRITE_SIZE * 10;
        }
        else
          PlaceFrog(walls);
      }
      else
        m_State = FrogStateNormal;      
    }
  }
}

void GIFrog::CheckWallCollision(GIWalls* walls)
{
  if (walls->CheckCollision(m_Coords, GAME_SPRITE_SIZE))
  {
    AngleDelta a = Utils::GetAngleDelta(m_FrogDir);
    m_Coords.x -= a.dX * FROG_MOVE_INCREMENT;
    m_Coords.y -= a.dY * FROG_MOVE_INCREMENT;
    if (! m_TargetFixed)
    {
      if (arc4random() % 2 == 0)
        m_FrogTargetDir = (m_FrogDir + 500 - TURN_DELTA) % 360;
      else
        m_FrogTargetDir = (m_FrogDir + 590 - TURN_DELTA) % 360;
      m_TargetFixed = TRUE;
    }
  }
}

void GIFrog::Eaten()
{
  m_StateVar = 0;
  m_State = FrogStateDisappearing;
}

void GIFrog::PlaceFrog(GIWalls* walls)
{
  m_FrogType = FrogTypeNormal;
  if (arc4random() % GROWMORE_FROG_CHANCE == 0)
    m_FrogType = FrogTypeGrowMore;
  do 
  {
    m_Coords.x = arc4random() % m_BoardW;
    m_Coords.y = arc4random() % m_BoardH;
    m_FrogDir = (arc4random() % (360 / TURN_DELTA)) * TURN_DELTA;
    m_FrogTargetDir = m_FrogDir; 
    m_StateVar = 0;
    m_State = FrogStateAppearing;
    m_Frame = 0;
    m_FrameDir = 1;
    m_FrameDelay = 0;
    m_DirChangeDelay = FROG_DIR_CHANGE_DELAY + arc4random() % FROG_DIR_CHANGE_DELAY_RANDOM;
    m_TargetFixed = FALSE;
    if (walls == NULL)
      break;
  } while (walls->CheckCollision(m_Coords, GAME_SPRITE_SIZE));
}

int GIFrog::GetGameItemType()
{
  return GIFROG;
}

Coords GIFrog::GetCoords()
{
  if (m_State != FrogStateNormal)
  {
    Coords dummy;
    dummy.x = -(GAME_SPRITE_SIZE * 10);
    dummy.y = -(GAME_SPRITE_SIZE * 10);
    return dummy;
  }
  else
    return m_Coords;
}

int GIFrog::GetStateDataSize()
{
  return sizeof(Coords) + sizeof(int) * 2 + sizeof(FrogState) + sizeof(FrogType);
}

void GIFrog::GetStateData(char* buffer)
{
  int pos = 0;
  memcpy(buffer + pos, &m_Coords, sizeof(Coords));
  pos += sizeof(Coords);
  memcpy(buffer + pos, &m_FrogTargetDir, sizeof(int));
  pos += sizeof(int);
  memcpy(buffer + pos, &m_FrogDir, sizeof(int));
  pos += sizeof(int);
  memcpy(buffer + pos, &m_State, sizeof(FrogState));
  pos += sizeof(FrogType);
  memcpy(buffer + pos, &m_FrogType, sizeof(FrogType));
}

void GIFrog::PutStateData(char* buffer)
{
  FrogState newFrogState;

  int pos = 0;
  memcpy(&m_Coords, buffer + pos, sizeof(Coords));
  pos += sizeof(Coords);
  memcpy(&m_FrogTargetDir, buffer + pos, sizeof(int));
  pos += sizeof(int);
  memcpy(&m_FrogDir, buffer + pos, sizeof(int));
  pos += sizeof(int);
  memcpy(&newFrogState, buffer + pos, sizeof(FrogState));
  pos += sizeof(FrogType);
  memcpy(&m_FrogType, buffer + pos, sizeof(FrogType));
  
  if (newFrogState != m_State)
  {
    m_State = newFrogState;
    m_StateVar = 0;
  }
}

FrogType GIFrog::GetFrogType()
{
  return m_FrogType;
}

FrogState GIFrog::GetFrogState()
{
  return m_State;
}