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

#import "IGLViewConsumer.h"
#import "GL2DView.h"
#import "ITouchReceiver.h"
#import "IGenericEvent.h"
#import "SlidingView.h"
#import "Game.h"
#import "IGenericEvent.h"
#import "TouchableTextRenderer.h"
#import "SinglePlayerHighScore.h"
#import "MultiplayerHighScore.h"
#import "HighScoreManager.h"
#import "GISnake.h"
#import "ScrollingView.h"
#import "TextEntryPopup.h"
#import "Marquee.h"

using namespace std;

typedef enum
{
  MenuStateServerNameEntry = 0,
  MenuStateClientNameEntry,
  MenuStateStartJoin,
  MenuStateWaiting,
  MenuStateConnecting
} MenuState;

class MainMenu : public IGLViewConsumer, public ITouchReceiver, public IGenericEvent
{
private:
  IGenericEvent* m_Controller;
  SlidingView* m_SlidingView;
  Game* m_BG;
  vector<IGLViewConsumer*> m_Items;
  TouchableTextRenderer* m_OnePlayerButton;
  TouchableTextRenderer* m_TwoPlayerButton;
  TouchableTextRenderer* m_SharedTwoPlayerButton;
  HighScoreManager<SinglePlayerHighScore>* m_SinglePlayerScores;
  HighScoreManager<MultiplayerHighScore>* m_MultiplayerScores;
  TextRenderer* m_MainScreenRightArrow;
  TextRenderer* m_MainScreenLeftArrow;
  TouchableTextRenderer* m_StartGameButton;
  TouchableTextRenderer* m_JoinGameButton;
  TouchableTextRenderer* m_CancelButton;
  TextRenderer* m_WaitingForOpponent;
  TextRenderer* m_Connecting;
  MenuState m_State;
  ScrollingView* m_HighScores;
  ScrollingView* m_VersusRanking;
  string m_PlayerName;
  TextEntryPopup* m_PlayerNamePopup;
  TouchableTextRenderer* m_SoundsOnButton;
  TouchableTextRenderer* m_MusicOnButton;
  TouchableTextRenderer* m_ControlsOnButton;
  TouchableTextRenderer* m_SoundsOffButton;
  TouchableTextRenderer* m_MusicOffButton;
  TouchableTextRenderer* m_ControlsOffButton;
  TouchableTextRenderer* m_PrevBoardButton;
  TouchableTextRenderer* m_NextBoardButton;
  bool m_SoundsOn;
  bool m_MusicOn;
  bool m_ControlsOn;
  int m_BoardNo;
  int m_UnlockedBoards;
  BoardInfo m_BoardInfo;
  int m_BoardFadeState;
  bool m_BoardFadeIn;
  int m_BoardIncrement;
  Marquee* m_Marquee;
  
  void InitMenu();
  
public:
  MainMenu(GL2DView* view, HighScoreManager<SinglePlayerHighScore>* singlePlayerScores, HighScoreManager<MultiplayerHighScore>* multiPlayerScores,
           bool soundsOn, bool musicOn, bool controlsOn, int boardNo, int unlockedBoards);
  ~MainMenu();
  
  void RenderPreview();
  void SetController(IGenericEvent* controller);

  void Render();
  
  void TouchEvent(TouchInfo touches[], int count);

  void EventRaised(int eventType, void* raiser);
  
  void HighlightScore(int page, int pos);
  void SetPlayerName(string name);
  string GetPlayerName();
  int GetBoardNo();
};