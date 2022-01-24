/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <vector>
#import <string>

#import "GL2DView.h"
#import "IGLViewConsumer.h"
#import "IGameItem.h"
#import "ITouchReceiver.h"
#import "GISnake.h"
#import "General.h"
#import "IGenericEvent.h"
#import "TextRenderer.h"
#import "ISessionManager.h"
#import "RematchMenu.h"

typedef enum
{
  None = 0,
  P1Left = 1,
  P1Right = 2,
  P2Left = 4,
  P2Right = 8
} TouchState;

typedef enum
{
  GameTypeDemo = 0,
  GameTypeSinglePlayer,
  GameTypeLocalMultiplayer,
  GameTypeMultiplayer
} GameType;

typedef enum
{
  GameStateWaitingForSync = 0,
  GameStateWaitingForNames,
  GameStateStarting,
  GameStatePlaying,
  GameStateSnakeDied,
  GameStateEnding,
  GameStateEnded,
  GameStateAskRematch
} GameState;

class Game : public IGLViewConsumer, public ITouchReceiver, public IGenericEvent
{
private:
  BoardInfo m_Board;
  int m_BoardNo;
  vector<IGameItem*> m_GameItems;
  GISnake* m_Player;
  GISnake* m_Opponent;
  int m_PlayerWins;
  int m_OpponentWins;
  int m_PlayerScore;
  int m_OpponentScore;
  int m_TouchState;
  int m_OpponentTouchState;
  Coords m_Camera;
  int m_DisplayScores[2];
  GameType m_GameType;
  GameState m_GameState;
  int m_StateVar;
  float m_GameTextScale;
  ISessionManager* m_SessionManager;
  int m_DataFrame;
  RematchMenu* m_RematchMenu;
  int m_GameCount;
  float m_RadarState;
  int m_ControlsDisplayFrames;
  float m_ControlsOpacity;
  int m_ControlsRotation;
  int m_BackgroundNo;
  int m_UnlockedBoards;
  BOOL m_UnlockNotified;
  TextRenderer* m_UnlockOverlays[2];
  int m_UnlockDisplayCount;
  
  TextRenderer* m_TextOverlays[2];
  
  IGenericEvent* m_Controller;
  
  void AdjustView();
  void DrawChar(int spriteX, int spriteY, int x, int y);
  TouchInfo* GetMostRecentTouchInArea(TouchInfo touches[], int count, int x, int y, int w, int h);
  void SendData();
  void BuildStateData(char*& data, int& len);
  void ReadData(char* data, int len);
  void ReadStateData(char* data, int len);
  void ReadHighLevelStateData(char* data, int len);
  void ShowPlayerText(string text);
  void GameEnded();
  void SnakeCollided();
  void GameEnding();
  void RenderHUD(BOOL isPlayer);
  void RenderRadar();
  void RenderRadarItem(Coords c, bool IsSnake, bool Pulse);
  void RenderControls();

  void InitClass();
  void CleanUpClass();
  
public:
  Game(GL2DView* view, GameType type, BOOL showControls);
  ~Game();
  
  void Initialise(int boardNumber);
  
  void Render();
  
  void TouchEvent(TouchInfo touches[], int count);
  
  void EventRaised(int eventType, void* raiser);
  
  void SetController(IGenericEvent* controller);
  void SetSessionManager(ISessionManager* manager);
  void SetUnlockedBoards(int unlockedBoards);
  void GotNames();
  
  GameType GetGameType();
  int GetPlayerScore();
  int GetOpponentScore();
  int GetPlayerWins();
  int GetOpponentWins();
  BOOL GetDidOpponentQuit();
  int GetBackgroundNo();
};