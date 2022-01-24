/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <vector>

#import "SpriteSheetInfo.h"
#import "UIViewGL.h"
#import "GL2DView.h"
#import "Timer.h"
#import "ITimerCallback.h"
#import "IGLViewConsumer.h"
#import "IGenericEvent.h"
#import "Game.h"
#import "HighScoreManager.h"
#import "SinglePlayerHighScore.h"
#import "TextEntryPopup.h"
#import "IPersister.h"
#import "MultiplayerHighScore.h"
#import "ISessionManager.h"
#import "MainMenu.h"
#import "UIAlertViewDelegate.h"

typedef enum
{
  AppStateMainMenu = 0,
  AppStatePlaying
} AppState;

typedef enum 
{
  TextEntryTypeHighScore = 0,
  TextEntryTypeP1Name,
  TextEntryTypeP2Name
} TextEntryType;

class AppController : public ITimerCallback, public ITouchReceiver, public IGenericEvent
{
private:
  GL2DView* m_View;
  SpriteSheetInfo* m_Backgrounds;
  SpriteSheetInfo* m_Sprites;
  SpriteSheetInfo* m_Font;
  SpriteSheetInfo* m_Obstacles;
  SpriteSheetInfo* m_FontSmall;
  SpriteSheetInfo* m_Controls;
  SpriteSheetInfo* m_Logo;

  Timer* m_Timer;
  vector<IGLViewConsumer*> m_Consumers;
  ITouchReceiver* m_TouchReceiver;
  AppState m_AppState;
  int m_StateVar;
  ISessionManager* m_SessionManager;
  Game* m_TheGame;
  HighScoreManager<SinglePlayerHighScore>* m_SinglePlayerScores;
  TextEntryPopup* m_TextBox;
  string m_LastHighScoreName;
  IPersister* m_SinglePlayerHighScoreFile;
  IPersister* m_PreferencesFile;
  string m_LastP1Name;
  string m_LastP2Name;
  TextEntryType m_TextEntryType;
  IPersister* m_MultiplayerHighScoreFile;
  HighScoreManager<MultiplayerHighScore>* m_MultiplayerScores;
  MainMenu* m_Menu;
  UIAlertViewDelegate* m_PausedAlert;
  int m_NewScore;
  int m_NewRank;
  string m_OpponentName;
  bool m_SoundOn;
  bool m_MusicOn;
  bool m_ControlsOn;
  int m_BoardNo;
  int m_UnlockedBoards;
  
  AppController();
  
  bool CheckHighScores();
  void AddHighScore();
  void ReadPreferences();
  void WritePreferences();
  void TextEntered();
  void ClearConsumers();
  void StartMenu();
  void StartGame(GameType type);
  void CheckHighScore();
  void RemotePause();
  void RemoteResume();
  void DataReceived();
  
public:
  AppController(GL2DView* view);
  ~AppController();
  
  void Start();
  
  void Tick();
  
  void TouchEvent(TouchInfo touches[], int count);
  
  void EventRaised(int eventType, void* raiser);
  
  void Interrupted();
  void Backgrounded();
  void Resumed();
};