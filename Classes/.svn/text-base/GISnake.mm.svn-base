/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <cmath>

#import "GISnake.h"
#import "Constants.h"
#import "Utils.h"

GISnake::GISnake(int StartX, int StartY, int StartDir, int StartLen, int SpriteYIdx, int boardW, int boardH, bool isRobot)
{
  m_Coords.x = StartX;
  m_Coords.y = StartY;
  m_Dir = StartDir;
  m_State = SnakeStateAppearing;
  m_AppearState = 0;
  m_GrowState = 0;
  m_CelebrateState = 0;
  m_Score = 0;
  m_Wins = 0;
  m_SpriteYIdx = SpriteYIdx;
  m_Length = StartLen;
  CreateSnake(StartLen);
  m_BoardW = boardW;
  m_BoardH = boardH;
  m_IsRobot = isRobot;
  m_Controller = NULL;
  m_Paused = FALSE;
  m_Suicided = FALSE;
}

void GISnake::CreateSnake(int Segments)
{
  int increment = SNAKE_SEGMENT_GAP / SNAKE_MOVE_INCREMENT;
  // increment nodes per segment + 1 node for the tail
  // (Segments - 1 becuase the tail will be one)
  int nodes = (Segments - 1) * increment + 1;
  
  // Using a circular linked list for the segments:
  // - Only need to alloc when adding segments
  // - Can move snake along by moving head/tail pointers
  Segment* curSeg = 0;
  float x = m_Coords.x, y = m_Coords.y;
  AngleDelta delta = Utils::GetAngleDelta(m_Dir);
  float dX = delta.dX * SNAKE_MOVE_INCREMENT;
  float dY = delta.dY * SNAKE_MOVE_INCREMENT;
  Segment* newSeg;
  for (int i = 0; i < nodes; i++)
  {
    if (! curSeg)
    {
      curSeg = (Segment*) malloc(sizeof(Segment));
      curSeg->prev = curSeg;
      curSeg->next = curSeg;
      m_Head = curSeg;
      m_Tail = curSeg;
    }
    else 
    {
      newSeg = (Segment*) malloc(sizeof(Segment));
      curSeg->next = newSeg;
      newSeg->prev = curSeg;
      newSeg->next = m_Head;
      m_Tail = newSeg;
      m_Head->prev = newSeg;
      curSeg = newSeg;      
    }
    curSeg->x = x;
    curSeg->y = y;
    curSeg->dir = m_Dir;
    curSeg->scale = 0.0;
    curSeg->opacity = 0.0;
    
    x -= dX;
    y -= dY;
  }

  m_State = SnakeStateAppearing;
  m_AppearState = 0;
}

void GISnake::Render(GL2DView* view)
{
  Segment* seg = m_Tail;
  int sprite;
  int increment = SNAKE_SEGMENT_GAP / SNAKE_MOVE_INCREMENT;
  while (1) 
  {
    if (seg == m_Head)
      sprite = 0;
    else if (seg == m_Tail)
      sprite = 2;
    else
      sprite = 1;

    view->DrawSprite(GAME_SPRITE_SHEET, sprite, m_SpriteYIdx, seg->x, seg->y, seg->dir, seg->scale, seg->opacity);
    if (seg == m_Head)
      break;
    
    for (int i = 0; i < increment; i++)
    {
      seg = seg->prev;
    }
  } 
}

void GISnake::Update(vector<IGameItem*>* items, bool isClient)
{
  if (m_IsRobot)
    RobotUpdate(items);
  
  // Do any state animations
  if (m_State == SnakeStateAppearing)
  {
    Segment* seg = m_Head;
    do
    {
      seg->opacity += SNAKE_APPEAR_INCREMENT;
      seg->scale += SNAKE_APPEAR_INCREMENT;
      if (seg->opacity >= 1.0)
      {
        seg->opacity = 1.0;
        seg->scale = 1.0;
        m_State = SnakeStateNormal;
      }
      seg = seg->next;
    } while (seg != m_Head);
  }
  
  if (m_State == SnakeStateNormal)
  {
    if (! m_Paused)
    {
      m_Tail = m_Tail->prev;
      m_Head = m_Head->prev;
    }
  }
  else if (m_State == SnakeStateGrowing)
  {
    m_GrowState++;
    Segment* seg = m_Head;
    for (int i = 0; i < SNAKE_SEGMENT_GAP / SNAKE_MOVE_INCREMENT; i++)
      seg = seg->next;
    seg->scale = m_GrowState * (1.0 / (SNAKE_SEGMENT_GAP / SNAKE_MOVE_INCREMENT));
    seg = m_Head;
    for (int i = 0; i < m_GrowState; i++)
      seg = seg->next;
    do {
      seg->x = seg->prev->x;
      seg->y = seg->prev->y;
      seg->dir = seg->prev->dir;
      seg = seg->prev;
    } while (seg != m_Head);
    if (m_GrowState == SNAKE_SEGMENT_GAP / SNAKE_MOVE_INCREMENT)
    {
      m_State = SnakeStateNormal;
      m_SegmentsToAdd--;
      if (m_SegmentsToAdd > 0)
        FrogNommed(m_SegmentsToAdd);
    }
  } 
  else if (m_State == SnakeStateDying)
  {
    Segment* seg = m_Head;
    bool adjusted = FALSE;
    
    int count = 0;
    while (count <= m_DeathState)
    {
      count++;
      if (seg->scale < 2)
      {
        seg->scale += SNAKE_DEATH_INCREMENT;
        seg->opacity = 2 - seg->scale;
        adjusted = TRUE;
      }
      if (seg == m_Tail)
        break;
      for (int i = 0; i < SNAKE_SEGMENT_GAP / SNAKE_MOVE_INCREMENT; i++)
        seg = seg->next;
    }
    m_DeathState++;
    
    if (! adjusted)
    {
      m_State = SnakeStateDead;
      if (m_Controller)
        m_Controller->EventRaised(EVENT_SNAKE_DEAD, this);
    }
    return;
  }
  else if (m_State == SnakeStateCelebrating)
  {
    int angle = m_CelebrateState;
    
    Segment* seg = m_Tail;
    do
    {
      AngleDelta d = Utils::GetAngleDelta(angle);
      seg->x += d.dX;
      seg->y += d.dY;
      
      angle += 10;
      angle %= 360;
      seg = seg->prev;
    } while (seg != m_Tail);
    
    m_CelebrateState += 10;
    m_CelebrateState %= 360;
  }
  else
  {
    return;
  }
  
  if (! m_Paused)
  {
    // Move the snake
    AngleDelta delta = Utils::GetAngleDelta(m_Dir);
    float dX = delta.dX * SNAKE_MOVE_INCREMENT;
    float dY = delta.dY * SNAKE_MOVE_INCREMENT;
    
    m_Coords.x += dX;
    m_Coords.y += dY;
    m_Head->x = m_Coords.x;
    m_Head->y = m_Coords.y;
    m_Head->dir = m_Dir;
  }
  
  // Wrap around arena
  if (m_Coords.x < -GAME_SPRITE_SIZE)
    m_Coords.x = m_BoardW;
  else if (m_Coords.x > m_BoardW)
    m_Coords.x = 0 - GAME_SPRITE_SIZE;
  if (m_Coords.y < -GAME_SPRITE_SIZE)
    m_Coords.y = m_BoardH;
  else if (m_Coords.y > m_BoardH)
    m_Coords.y = 0 - GAME_SPRITE_SIZE;
}

void GISnake::CheckInteractions(vector<IGameItem*>* items)
{
  if (m_State == SnakeStateNormal)
  {
    vector<IGameItem*>::iterator iter = items->begin();
    
    for (; iter != items->end(); ++iter)
    {
      switch ((*iter)->GetGameItemType())
      {
        case GIFROG:
          CheckFrog(dynamic_cast<GIFrog*> (*iter));
          break;
        case GIWALLS:
#ifndef INVULNERABLE
          CheckWallCollision(dynamic_cast<GIWalls*> (*iter));
#endif
          break;
        case GISNAKE:
#ifndef INVULNERABLE
          CheckSnakeCollision(dynamic_cast<GISnake*> (*iter));
#endif
          break;
      }
    }
  }
}

void GISnake::RobotUpdate(vector<IGameItem*>* items)
{
#ifdef DUMB_OPPONENT
  return;
#endif
  
  if (m_Paused)
    return;
  
  // See if we need to avoid anything
  bool bHit;
  int lookAhead = 40;
  int angle = 0;
  Coords coords;
  AngleDelta d;
  int lc = 0, rc = 0;
  while (TRUE)
  {
    d = Utils::GetAngleDelta((m_Dir + angle) % 360);
    coords.x = m_Coords.x + lookAhead * d.dX;
    coords.y = m_Coords.y + lookAhead * d.dY;
    bHit = CheckPotentialCollision(items, coords);
    if (bHit) rc++; // = angle <= 75 ? 2 : 1;
    
    if (angle != 0)
    {
      d = Utils::GetAngleDelta((m_Dir - angle + 360) % 360);
      coords.x = m_Coords.x + lookAhead * d.dX;
      coords.y = m_Coords.y + lookAhead * d.dY;
      bHit = CheckPotentialCollision(items, coords);
      if (bHit) lc++; //= angle <= 75 ? 1 : 2;
    }
    
    angle += 15;

    if (angle >= 120)
    {
      break;
    }
  }
  
  // If angle != 0, then we are avoiding
  if (lc != 0 || rc != 0)
  {
    if (lc < rc)
      m_Dir += 360 - TURN_DELTA;
    else if (lc > rc)
      m_Dir += TURN_DELTA;
    else
    {
      if (arc4random() % 2 == 0)
        m_Dir += 360 - TURN_DELTA;
      else
        m_Dir += TURN_DELTA;
    }
    m_Dir = m_Dir % 360;
  }
  else
  {
    Coords target = GetClosestFrog(items);
    if (target.x != - GAME_SPRITE_SIZE * 10)
    {
      float curDist = pow(m_Coords.x - target.x, 2);
      curDist += pow(m_Coords.y - target.y, 2);
      curDist = sqrt(curDist);
      float opp = (target.y - m_Coords.y);
      float oh = opp / curDist;
      angle = asin(oh) * 180 / PI;
      angle = (angle + 270);
      if (target.x > m_Coords.x)
        angle = (360 - angle) % 360;
      Utils::TurnInDirection(m_Dir, (int) angle);
    }
  }
}

void GISnake::ServerUpdate(Coords coords, int dir)
{
  m_Coords = coords;
  m_Dir = dir;
}

bool GISnake::CheckPotentialCollision(vector<IGameItem*>* items, Coords coords)
{
  bool bHit = FALSE;
  vector<IGameItem*>::iterator iter;
  iter = items->begin();
  for (; iter != items->end(); ++iter)
  {
    switch ((*iter)->GetGameItemType())
    {
      case GIWALLS:
        bHit = bHit || ((GIWalls*) (*iter))->CheckCollision(coords, GAME_SPRITE_SIZE);
        break;
      case GISNAKE:
        bHit = bHit || ((GISnake*) (*iter))->CheckCollision(coords);
        break;
    }
    if (bHit)
      break;
  }
  return bHit;
}

Coords GISnake::GetClosestFrog(vector<IGameItem*>* items)
{
  vector<IGameItem*>::iterator iter;
  iter = items->begin();
  GIWalls* walls;
  for (; iter != items->end(); ++iter)
  {
    switch ((*iter)->GetGameItemType())
    {
      case GIWALLS:
        walls = (GIWalls*) (*iter);
        break;
    }
  }

  Coords closest = { - GAME_SPRITE_SIZE * 10, - GAME_SPRITE_SIZE * 10 };
  float dist = 9999999;
  float curDist;
  
  iter = items->begin();
  
  for (; iter != items->end(); ++iter)
  {
    if ((*iter)->GetGameItemType() == GIFROG)
    {
      GIFrog* frog = dynamic_cast<GIFrog*>(*iter);
      if (frog->GetFrogState() == FrogStateNormal)
      {        
        if (walls->CheckLineOfSight(m_Coords, frog->GetCoords()))
        {
          Coords frogCoords = frog->GetCoords();
          // Pythag
          curDist = Utils::CalculateDistance(m_Coords, frogCoords);
          if (curDist < dist)
          {
            dist = curDist;
            closest = frogCoords;
          }
        }
      }
    }
  }
  
  // If no bug in line of sight, find a waypoint to head to
  // (one with a bug close by)
  if (closest.x == - GAME_SPRITE_SIZE * 10)
  {
    float dist = 9999999;
    vector<Coords>::iterator wpiter = m_Waypoints.begin();
    for (; wpiter != m_Waypoints.end(); ++wpiter)
    {
      if (walls->CheckLineOfSight(m_Coords, *wpiter))
      {
        // Is in the line of sight, now find its closest bug
        iter = items->begin();
        for (; iter != items->end(); ++iter)
        {
          if ((*iter)->GetGameItemType() == GIFROG)
          {
            GIFrog* frog = dynamic_cast<GIFrog*>(*iter);
            if (frog->GetFrogState() == FrogStateNormal)
            { 
              curDist = Utils::CalculateDistance(*wpiter, frog->GetCoords());
              if (curDist < dist)
              {
                dist = curDist;
                closest = *wpiter;
              }
            }
          }
        }
      }
    }
  }

  // If still nothing, just find a waypoint in LOS
  if (closest.x == - GAME_SPRITE_SIZE * 10)
  {
    vector<Coords>::iterator wpiter = m_Waypoints.begin();
    for (; wpiter != m_Waypoints.end(); ++wpiter)
    {
      if (walls->CheckLineOfSight(m_Coords, *wpiter))
      {
        closest = *wpiter;
        break;
      }
    }
  }
  
  return closest;
}

void GISnake::CheckFrog(GIFrog* frog)
{
  // Can't eat a frog if growing from the last one (or paused)
  if (m_State == SnakeStateGrowing || m_Paused)
    return;
  
  Coords coords = frog->GetCoords();
  if (m_Coords.x >= coords.x - GAME_SPRITE_SIZE &&
      m_Coords.x < coords.x + GAME_SPRITE_SIZE &&
      m_Coords.y >= coords.y - GAME_SPRITE_SIZE &&
      m_Coords.y < coords.y + GAME_SPRITE_SIZE)
  {
    if (frog->GetFrogType() == FrogTypeGrowMore)
      FrogNommed(GROWMORE_FROG_SEGMENT_REWARD);
    else
      FrogNommed(1);
    frog->Eaten();
    m_Controller->EventRaised(EVENT_FROG_NOMMED, this);
  }
}

void GISnake::FrogNommed(int segmentsToAdd)
{
  m_SegmentsToAdd = segmentsToAdd;
  m_Score += FROG_SCORE;
  m_State = SnakeStateGrowing;
  m_Length++;
  m_GrowState = 0;
  Segment* seg;
  for (int i = 0; i < SNAKE_SEGMENT_GAP / SNAKE_MOVE_INCREMENT; i++)
  {
    seg = (Segment*) malloc(sizeof(Segment));
    seg->x = m_Head->x;
    seg->y = m_Head->y;
    seg->dir = m_Head->dir;
    seg->scale = 1.0;
    seg->opacity = 1.0;
    seg->next = m_Head->next;
    m_Head->next->prev = seg;
    seg->prev = m_Head;
    m_Head->next = seg;
  }
  seg = m_Head;
  for (int i = 0; i < SNAKE_SEGMENT_GAP / SNAKE_MOVE_INCREMENT; i++)
    seg = seg->next;
  seg->scale = 0.0;
}

void GISnake::CheckWallCollision(GIWalls* walls)
{
  if (walls->CheckCollision(m_Coords, GAME_SPRITE_SIZE))
  {
    m_Suicided = TRUE;
    StartDeath();
  }
}

void GISnake::CheckSnakeCollision(GISnake* snake)
{
  if (snake->CheckCollision(m_Coords))
  {
    StartDeath();
  }
}

void GISnake::StartDeath()
{
  if (m_State == SnakeStateDying || m_State == SnakeStateDead)
    return;
  
  m_DeathState = 0;
  m_State = SnakeStateDying;
  if (m_Controller)
    m_Controller->EventRaised(EVENT_SNAKE_DYING, this);
}

bool GISnake::CheckCollision(Coords coords)
{
  // Can't collide with a dying/dead snake
  // m_DeathState > 0 is checked to allow simultaneous collisions to kill both snakes
  if ((m_State == SnakeStateDying && m_DeathState > 0) || m_State == SnakeStateDead)
    return FALSE;
  
  Segment* seg = m_Head;
  // If is self, move beyond it's own head before detecting
  if (coords.x == m_Coords.x && coords.y == m_Coords.y)
  {
    for (int i = 0; i < (SNAKE_SEGMENT_GAP / SNAKE_MOVE_INCREMENT) * 4; i++)
    {
      seg = seg->next;
      if (seg == m_Tail)
        return FALSE;
    }
  }
  while (seg != m_Tail)
  {
    if (seg->x >= coords.x - GAME_SPRITE_SIZE &&
        seg->x < coords.x + GAME_SPRITE_SIZE &&
        seg->y >= coords.y - GAME_SPRITE_SIZE &&
        seg->y < coords.y + GAME_SPRITE_SIZE)
    {
      if (coords.x == m_Coords.x && coords.y == m_Coords.y)
        m_Suicided = TRUE;
      return TRUE;
    }
    for (int i = 0; i < SNAKE_SEGMENT_GAP / SNAKE_MOVE_INCREMENT; i++)
      seg = seg->next;
  }
  return FALSE;
}

void GISnake::SetWaypoints(vector<Coords> waypoints)
{
  m_Waypoints = waypoints;
}

void GISnake::SetController(IGenericEvent* controller)
{
  m_Controller = controller;
}

void GISnake::SetPaused(bool isPaused)
{
  m_Paused = isPaused;
}

void GISnake::TurnLeft()
{
  if (m_Paused)
    return;
  
  m_Dir -= TURN_DELTA;
  if (m_Dir < 0)
    m_Dir += 360;
}

void GISnake::TurnRight()
{
  if (m_Paused)
    return;

  m_Dir += TURN_DELTA;
  if (m_Dir > 359)
    m_Dir -= 360;
}

Coords GISnake::GetCoords()
{
  return m_Coords;
}

int GISnake::GetDirection()
{
  return m_Dir;
}

void GISnake::SetCoords(Coords coords)
{
  m_Coords = coords;
}

void GISnake::SetDirection(int direction)
{
  m_Dir = direction;
}

int GISnake::GetScore()
{
  return m_Score;
}

void GISnake::GetStats(int& score, int& wins)
{
  score = m_Score;
  wins = m_Wins;
}

void GISnake::SetStats(int score, int wins)
{
  m_Score = score;
  m_Wins = wins;
}

int GISnake::GetWins()
{
  return m_Wins;
}

SnakeState GISnake::GetSnakeState()
{
  return m_State;
}

void GISnake::SetSnakeState(SnakeState state)
{
  m_State = state;
}

int GISnake::GetSnakeLength()
{
  return m_Length;
}

bool GISnake::GetDidSuicide()
{
  return m_Suicided;
}

void GISnake::SetDidSuicide(bool didSuicide)
{
  m_Suicided = didSuicide;
}

void GISnake::AddScore(int points)
{
  m_Score += points;
}

void GISnake::AddWin()
{
  m_Wins++;
}

int GISnake::GetGameItemType()
{
  return GISNAKE;
}

int GISnake::GetStateDataSize()
{
  return sizeof(Coords) + sizeof(int) + sizeof(SnakeState) + sizeof(int);
}

void GISnake::GetStateData(char* buffer)
{
  int pos = 0;
  memcpy(buffer + pos, &m_Coords, sizeof(Coords));
  pos += sizeof(Coords);
  memcpy(buffer + pos, &m_Dir, sizeof(int));
  pos += sizeof(int);
  memcpy(buffer + pos, &m_State, sizeof(SnakeState));
  pos += sizeof(SnakeState);
  memcpy(buffer + pos, &m_Length, sizeof(int));
}

void GISnake::PutStateData(char* buffer)
{
  SnakeState newSnakeState;
  
  int pos = 0;
  memcpy(&m_Coords, buffer + pos, sizeof(Coords));
  pos += sizeof(Coords);
  memcpy(&m_Dir, buffer + pos, sizeof(int));
  pos += sizeof(int);
  memcpy(&newSnakeState, buffer + pos, sizeof(SnakeState));
  pos += sizeof(SnakeState);
  int newLen;
  memcpy(&newLen, buffer + pos, sizeof(int));
  
  if (newSnakeState != m_State)
  {
    switch (newSnakeState)
    {
      case SnakeStateGrowing:
        FrogNommed(1);
        break;
      case SnakeStateDying:
        StartDeath();
        break;
    }
  }
  else if (newLen < m_Length && m_State == SnakeStateNormal)
  {
    FrogNommed(1);
  }
}

GISnake::~GISnake()
{
  Segment* seg = m_Head;
  Segment* next = m_Head->next;
  while (TRUE)
  {
    free(seg);
    if (seg == m_Tail)
      break;
    seg = next;
    next = seg->next;
  }
}
