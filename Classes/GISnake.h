/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <vector>

#import "IGameItem.h"
#import "GIFrog.h"
#import "General.h"
#import "GIWalls.h"
#import "IGenericEvent.h"
#import "Constants.h"
#import "IStateReporter.h"

typedef struct _Segment
{
  float x;
  float y;
  int dir;
  float scale;
  float opacity;
  _Segment* next;
  _Segment* prev;
} Segment;

typedef enum
{
  SnakeStateAppearing = 0,
  SnakeStateNormal,
  SnakeStateGrowing,
  SnakeStateDying,
  SnakeStateDead,
  SnakeStateCelebrating
} SnakeState;

class GISnake : public IGameItem, public IStateReporter
{
private:
  Coords m_Coords;
  int m_Dir;
  Segment* m_Segments;
  Segment* m_Head;
  Segment* m_Tail;
  SnakeState m_State;
  int m_GrowState;
  int m_Score;
  int m_Wins;
  int m_SpriteYIdx;
  int m_DeathState;
  int m_BoardW;
  int m_BoardH;
  int m_Length;
  int m_AppearState;
  int m_CelebrateState;
  bool m_Suicided;
  int m_SegmentsToAdd;
  
  bool m_IsRobot;
  bool m_Paused;
  
  vector<Coords> m_Waypoints;
  
  IGenericEvent* m_Controller;
  
  void CreateSnake(int Segments);
  void CheckFrog(GIFrog* frog);
  void CheckWallCollision(GIWalls* walls);
  void CheckSnakeCollision(GISnake* snake);
  void StartDeath();
  bool CheckPotentialCollision(vector<IGameItem*>* items, Coords coords);
  void FrogNommed(int segmentsToAdd);
 
public:
  GISnake(int StartX, int StartY, int StartDir, int StartLen, int SpriteYIdx, int boardW, int boardH, bool isRobot);
  ~GISnake();

  void Render(GL2DView* view);
  void Update(vector<IGameItem*>* items, bool isClient);
  void CheckInteractions(vector<IGameItem*>* items);
  int GetGameItemType();
  Coords GetCoords();
  int GetDirection();
  void SetCoords(Coords coords);
  void SetDirection(int direction);
  int GetScore();
  void GetStats(int& score, int& wins);
  void SetStats(int score, int wins);
  int GetWins();
  SnakeState GetSnakeState();
  void SetSnakeState(SnakeState state);
  int GetSnakeLength();
  bool GetDidSuicide();
  void SetDidSuicide(bool didSuicide);
  void AddScore(int points);
  void AddWin();
  bool CheckCollision(Coords coords);
  void SetWaypoints(vector<Coords> waypoints);
  
  void RobotUpdate(vector<IGameItem*>* items);
  void ServerUpdate(Coords coords, int dir);

  Coords GetClosestFrog(vector<IGameItem*>* items);
  
  void SetController(IGenericEvent* controller);
  
  void SetPaused(bool isPaused);
  
  void TurnLeft();
  void TurnRight();  
  
  int GetStateDataSize();
  void GetStateData(char* buffer);
  void PutStateData(char* buffer);
};