/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "IGameItem.h"
#import "General.h"
#import "GIWalls.h"
#import "IStateReporter.h"

typedef enum
{
  FrogTypeNormal = 0,
  FrogTypeGrowMore
} FrogType;

typedef enum
{
  FrogStateNormal = 0,
  FrogStateAppearing,
  FrogStateDisappearing
} FrogState;

class GIFrog : public IGameItem, public IStateReporter
{
private:
  int m_Frame;
  int m_FrameDir;
  Coords m_Coords;
  int m_FrameDelay;
  int m_DirChangeDelay;
  int m_FrogDir;
  int m_FrogTargetDir;
  FrogState m_State;
  int m_StateVar;
  int m_BoardW;
  int m_BoardH;
  bool m_TargetFixed;
  FrogType m_FrogType;
  
  void CheckWallCollision(GIWalls* walls);
public:
  GIFrog(int boardW, int boardH);
  
  void Render(GL2DView* view);
  void Update(vector<IGameItem*>* items, bool isClient);  
  void UpdateAsClient();
  int GetGameItemType();
  Coords GetCoords();
  void Eaten();
  void PlaceFrog(GIWalls* walls);

  int GetStateDataSize();
  void GetStateData(char* buffer);
  void PutStateData(char* buffer);
  FrogType GetFrogType();
  FrogState GetFrogState();
};