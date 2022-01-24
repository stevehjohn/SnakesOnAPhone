/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <sstream>

#import "MainMenu.h"
#import "TextRenderer.h"
#import "TouchableTextRenderer.h"
#import "Constants.h"
#import "Utils.h"
#import "BoardBuilder.h"

MainMenu::MainMenu(GL2DView* view, HighScoreManager<SinglePlayerHighScore>* singlePlayerScores, HighScoreManager<MultiplayerHighScore>* multiPlayerScores,
                   bool soundsOn, bool musicOn, bool controlsOn, int boardNo, int unlockedBoards) : IGLViewConsumer(view)
{
  m_SinglePlayerScores = singlePlayerScores;
  m_MultiplayerScores = multiPlayerScores;
  
  m_SoundsOn = soundsOn;
  m_MusicOn = musicOn;
  m_ControlsOn = controlsOn;
  
  m_Controller = NULL;
  
  m_SlidingView = new SlidingView(view);

  m_BG = new Game(view, GameTypeDemo, FALSE);
  m_BG->Initialise(-1);

  m_SharedTwoPlayerButton = NULL;
  
  m_BoardNo = boardNo;
  m_UnlockedBoards = unlockedBoards;
  m_BoardInfo = BoardBuilder::GetBoardPreview(m_BoardNo);
  m_BoardFadeState = 0;
  m_BoardFadeIn = FALSE;
  m_BoardIncrement = 0;
  
  InitMenu();
}

MainMenu::~MainMenu()
{
  vector<IGLViewConsumer*>::iterator iter = m_Items.begin();
 
  for (; iter != m_Items.end(); ++iter)
  {
    delete (*iter);
  }
  m_Items.clear();
  
  delete m_OnePlayerButton;
  m_OnePlayerButton = NULL;
  delete m_TwoPlayerButton;
  m_TwoPlayerButton = NULL;
  if (m_SharedTwoPlayerButton)
  {
    delete m_SharedTwoPlayerButton;
    m_SharedTwoPlayerButton = NULL;
  }
  delete m_StartGameButton;
  m_StartGameButton = NULL;
  delete m_JoinGameButton;
  m_JoinGameButton = NULL;
  delete m_CancelButton;
  m_CancelButton = NULL;
  delete m_SoundsOnButton;
  m_SoundsOnButton = NULL;
  delete m_SoundsOffButton;
  m_SoundsOffButton = NULL;
  delete m_MusicOnButton;
  m_MusicOnButton = NULL;
  delete m_MusicOffButton;
  m_MusicOffButton = NULL;
  delete m_ControlsOnButton;
  m_ControlsOnButton = NULL;
  delete m_ControlsOffButton;
  m_ControlsOffButton = NULL;
  delete m_PrevBoardButton;
  m_PrevBoardButton = NULL;
  delete m_NextBoardButton;
  m_NextBoardButton = NULL;
    
  delete m_SlidingView;
}

void MainMenu::InitMenu()
{
  int scale = 1;
  bool ipad = Utils::IsiPad();
  if (ipad)
    scale = 2;
  
  TextRenderer* text;

  TouchableTextRenderer* touchText;
  if (ipad)
  {
    touchText = new TouchableTextRenderer(m_View, STR_ONE_PLAYER, TextPositionManual, TextAnimationDropBounce, 0.5);
    touchText->SetPosition(380, 512);
  }
  else
  {
    touchText = new TouchableTextRenderer(m_View, STR_ONE_PLAYER, TextPositionManual, TextAnimationDropBounce, 1.0);
    touchText->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    touchText->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    touchText->SetPosition(130, 240);
  }
  touchText->SetColour(1.0, 1.0, 1.0);
  touchText->SetController(this);
  m_SlidingView->AddItem(touchText, 2);
  m_OnePlayerButton = touchText;

  if (ipad)
  {
    touchText = new TouchableTextRenderer(m_View, STR_TWO_PLAYER, TextPositionManual, TextAnimationDropBounce, 0.5);
    touchText->SetPosition(260, 512);
  }
  else
  {
    touchText = new TouchableTextRenderer(m_View, STR_TWO_PLAYER, TextPositionManual, TextAnimationDropBounce, 1.0);
    touchText->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    touchText->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    touchText->SetPosition(60, 240);
  }
  touchText->SetColour(1.0, 1.0, 1.0);
  touchText->SetController(this);
  m_SlidingView->AddItem(touchText, 2);
  m_TwoPlayerButton = touchText;
  
  if (ipad)
  {
    touchText = new TouchableTextRenderer(m_View, STR_SHARED_TWO_PLAYER, TextPositionManual, TextAnimationDropBounce, 0.5);
    touchText->SetColour(1.0, 1.0, 1.0);
    touchText->SetPosition(140, 512);
    touchText->SetController(this);
    m_SlidingView->AddItem(touchText, 2);
    m_SharedTwoPlayerButton = touchText;
  }
  
  if (ipad)
  {
    touchText = new TouchableTextRenderer(m_View, STR_START_GAME, TextPositionManual, TextAnimationDropBounce, 0.5);
    touchText->SetPosition(380, 512);
  }
  else
  {
    touchText = new TouchableTextRenderer(m_View, STR_START_GAME, TextPositionManual, TextAnimationDropBounce, 1.0);
    touchText->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    touchText->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    touchText->SetPosition(170, 240);
  }
  touchText->SetColour(1.0, 1.0, 1.0);  
  touchText->SetController(this);
  touchText->SetVisible(FALSE);
  m_SlidingView->AddItem(touchText, 2);
  m_StartGameButton = touchText;
  
  if (ipad)
  {
    touchText = new TouchableTextRenderer(m_View, STR_JOIN_GAME, TextPositionManual, TextAnimationDropBounce, 0.5);
    touchText->SetPosition(260, 512);
  }
  else
  {
    touchText = new TouchableTextRenderer(m_View, STR_JOIN_GAME, TextPositionManual, TextAnimationDropBounce, 1.0);
    touchText->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    touchText->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    touchText->SetPosition(100, 240);
  }
  touchText->SetColour(1.0, 1.0, 1.0);  
  touchText->SetController(this);
  touchText->SetVisible(FALSE);
  m_SlidingView->AddItem(touchText, 2);
  m_JoinGameButton = touchText;

  if (ipad)
  {
    touchText = new TouchableTextRenderer(m_View, STR_MAIN_MENU, TextPositionManual, TextAnimationDropBounce, 0.5);
    touchText->SetPosition(140, 512);
  }
  else
  {
    touchText = new TouchableTextRenderer(m_View, STR_MAIN_MENU, TextPositionManual, TextAnimationDropBounce, 1.0);
    touchText->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    touchText->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    touchText->SetPosition(30, 240);
  }
  touchText->SetController(this);
  touchText->SetVisible(FALSE);
  m_SlidingView->AddItem(touchText, 2);
  m_CancelButton = touchText;

  if (ipad)
  {
    text = new TextRenderer(m_View, STR_WAITING_ANSWER, TextPositionManual, TextAnimationDropBounce, 0.5);
    text->SetPosition(380, 512);
  }
  else
  {
    text = new TextRenderer(m_View, STR_WAITING_ANSWER, TextPositionManual, TextAnimationDropBounce, 1.0);
    text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    text->SetPosition(130, 240);
  }
  text->SetColour(1.0, 1.0, 1.0);
  text->SetVisible(FALSE);
  m_SlidingView->AddItem(text, 2);
  m_Items.push_back(text);
  m_WaitingForOpponent = text;

  if (ipad)
  {
    text = new TextRenderer(m_View, STR_CONNECTING, TextPositionManual, TextAnimationDropBounce, 0.5);
    text->SetPosition(380, 512);
  }
  else
  {
    text = new TextRenderer(m_View, STR_CONNECTING, TextPositionManual, TextAnimationDropBounce, 1.0);
    text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    text->SetPosition(130, 240);
  }
  text->SetColour(1.0, 1.0, 1.0);
  text->SetVisible(FALSE);
  m_SlidingView->AddItem(text, 2);
  m_Items.push_back(text);
  m_Connecting = text;

  for (int i = 0; i < 5; i++)
  {
    if (i < 4)
    {
      touchText = new TouchableTextRenderer(m_View, ">", TextPositionManual, TextAnimationSplat, 0.5 * scale);
      touchText->SetColour(1.0, 1.0, 1.0);
      touchText->SetPosition(m_View->GetViewW() / 2, (FONT_SPRITE_SIZE / 4) * scale); // / 4 because 0.5 scaled 
      touchText->SetCharSpacing(1.0);  
      touchText->AddAnimation(TextAnimationJiggleLeft);
      touchText->SetController(this);
      touchText->SetUserRef(1);
      touchText->SetShowBorder(FALSE);
      touchText->SetOpacity(0.5);
      m_SlidingView->AddItem(touchText, i);
      m_Items.push_back(touchText);
      
      if (i == 2)
        m_MainScreenRightArrow = touchText;
    }

    if (i > 0)
    {
      touchText = new TouchableTextRenderer(m_View, "<", TextPositionManual, TextAnimationSplat, 0.5 * scale);
      touchText->SetColour(1.0, 1.0, 1.0);
      touchText->SetPosition(m_View->GetViewW() / 2, m_View->GetViewH() - (FONT_SPRITE_SIZE / 4) * scale);
      touchText->SetCharSpacing(1.0);  
      touchText->AddAnimation(TextAnimationJiggleRight);
      touchText->SetController(this);
      touchText->SetUserRef(2);
      touchText->SetShowBorder(FALSE);
      touchText->SetOpacity(0.5);
      m_SlidingView->AddItem(touchText, i);
      m_Items.push_back(touchText);
      
      if (i == 2)
        m_MainScreenLeftArrow = touchText;
    }
  }
  
  vector<SinglePlayerHighScore> scores = m_SinglePlayerScores->GetScores();
  vector<SinglePlayerHighScore>::iterator item = scores.begin();
  
  if (ipad)
    m_HighScores = new ScrollingView(m_View, scores.size() * FONT_SPRITE_SIZE / 3 * scale, m_View->GetViewW() - FONT_SPRITE_SIZE * scale);
  else
    m_HighScores = new ScrollingView(m_View, scores.size() * (FONT_SMALL_SPRITE_SIZE + 2), m_View->GetViewW() - FONT_SPRITE_SIZE * scale);
  m_SlidingView->AddItem(m_HighScores, 3);
  m_Items.push_back(m_HighScores);
  
  int i = 1;
  for (; item != scores.end(); ++item)
  {
    int x;
    if (ipad)
      x = m_View->GetViewW() - FONT_SPRITE_SIZE * scale - (i - 1) * FONT_SPRITE_SIZE / 3 * scale;
    else
      x = m_View->GetViewW() - FONT_SPRITE_SIZE * scale - (i - 1) * (FONT_SMALL_SPRITE_SIZE + 2);

    stringstream ss;
    ss << i;
    if (ipad)
    {
      text = new TextRenderer(m_View, ss.str(), TextPositionManual, TextAnimationNone, 0.3 * scale);
      text->SetPosition(x, m_View->GetViewH() - FONT_SPRITE_SIZE * scale);
    }
    else
    {
      text = new TextRenderer(m_View, ss.str(), TextPositionManual, TextAnimationNone, 1.0);
      text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
      text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
      text->SetPosition(x, m_View->GetViewH() - FONT_SPRITE_SIZE * scale);
    }
    text->SetColour(1.0, 1.0, 1.0);
    text->SetCharSpacing(0.8);
    m_HighScores->AddItem(text);
    m_Items.push_back(text);

    string txt = item->GetName();
    if (ipad)
    {
      text = new TextRenderer(m_View, txt, TextPositionManual, TextAnimationNone, 0.3 * scale);
      text->SetPosition(x, m_View->GetViewH() * 0.8);
    }
    else
    {
      text = new TextRenderer(m_View, txt, TextPositionManual, TextAnimationNone, 1.0);
      text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
      text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
      text->SetPosition(x, m_View->GetViewH() * 0.8);
    }
    text->SetColour(1.0, 1.0, 1.0);
    text->SetAnchor(TextAnchorLeft);
    m_HighScores->AddItem(text);
    m_Items.push_back(text);

    ss.str("");
    ss << item->GetScore();
    txt = ss.str();
    if (ipad)
    {
      text = new TextRenderer(m_View, txt, TextPositionManual, TextAnimationNone, 0.3 * scale);
      text->SetPosition(x, FONT_SPRITE_SIZE * scale - 0.7 * FONT_SPRITE_SIZE);
    }
    else
    {
      text = new TextRenderer(m_View, txt, TextPositionManual, TextAnimationNone, 1.0);
      text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
      text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
      text->SetPosition(x, FONT_SPRITE_SIZE * scale * 0.5 + FONT_SMALL_SPRITE_SIZE);
    }
    text->SetColour(1.0, 1.0, 1.0);
    text->SetAnchor(TextAnchorRight);
    m_HighScores->AddItem(text);
    m_Items.push_back(text);
    
    i++;
  }

  if (ipad)
  {
    text = new TextRenderer(m_View, STR_HIGH_SCORES, TextPositionManual, TextAnimationNone, 0.3 * scale);    
    text->SetPosition(736, 512);
  }
  else
  {
    text = new TextRenderer(m_View, STR_HIGH_SCORES, TextPositionManual, TextAnimationNone, 1.0);    
    text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    text->SetPosition(304, 240);
  }
  text->SetColour(1.0, 1.0, 1.0);
  m_SlidingView->AddItem(text, 3);
  m_Items.push_back(text);
  
  vector<MultiplayerHighScore> mpscores = m_MultiplayerScores->GetScores();
  vector<MultiplayerHighScore>::iterator mpitem = mpscores.begin();
  
  if (ipad)
    m_VersusRanking = new ScrollingView(m_View, mpscores.size() * FONT_SPRITE_SIZE / 3 * scale, m_View->GetViewW() - FONT_SPRITE_SIZE * scale);
  else
    m_VersusRanking = new ScrollingView(m_View, mpscores.size() * (FONT_SMALL_SPRITE_SIZE + 2), m_View->GetViewW() - FONT_SPRITE_SIZE * scale);
  m_SlidingView->AddItem(m_VersusRanking, 4);
  m_Items.push_back(m_VersusRanking);
  
  i = 1;
  for (; mpitem != mpscores.end(); ++mpitem)
  {
    int x;
    if (ipad)
      x = m_View->GetViewW() - FONT_SPRITE_SIZE * scale - (i - 1) * FONT_SPRITE_SIZE / 3 * scale;
    else
      x = m_View->GetViewW() - FONT_SPRITE_SIZE * scale - (i - 1) * (FONT_SMALL_SPRITE_SIZE + 2) * scale;

    stringstream ss;
    ss << mpitem->GetP1Score();
    ss << STR_SCORE_SEPARATOR;
    ss << mpitem->GetP2Score();

    if (ipad)
    {
      text = new TextRenderer(m_View, ss.str(), TextPositionManual, TextAnimationNone, 0.3 * scale);
      text->SetPosition(x, m_View->GetViewH() / 2);
    }
    else
    {
      text = new TextRenderer(m_View, ss.str(), TextPositionManual, TextAnimationNone, 1.0);
      text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
      text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
      text->SetPosition(x, m_View->GetViewH() / 2);
    }
    text->SetColour(1.0, 1.0, 1.0);
    m_VersusRanking->AddItem(text);
    m_Items.push_back(text);
    
    string txt = mpitem->GetP1Name();
    if (ipad)
    {
      text = new TextRenderer(m_View, txt, TextPositionManual, TextAnimationNone, 0.3 * scale);
    }
    else
    {
      text = new TextRenderer(m_View, txt, TextPositionManual, TextAnimationNone, 1.0);
      text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
      text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    }
    text->SetColour(1.0, 1.0, 1.0);
    text->SetPosition(x, m_View->GetViewH() * 0.9);
    text->SetAnchor(TextAnchorLeft);
    m_VersusRanking->AddItem(text);
    m_Items.push_back(text);

    txt = mpitem->GetP2Name();
    if (ipad)
    {
      text = new TextRenderer(m_View, txt, TextPositionManual, TextAnimationNone, 0.3 * scale);
    }
    else
    {
      text = new TextRenderer(m_View, txt, TextPositionManual, TextAnimationNone, 1.0);
      text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
      text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    }
    text->SetColour(1.0, 1.0, 1.0);
    text->SetPosition(x, m_View->GetViewH() * 0.1);
    text->SetAnchor(TextAnchorRight);
    m_VersusRanking->AddItem(text);
    m_Items.push_back(text);
    
    i++;
  }

  if (ipad)
  {
    text = new TextRenderer(m_View, STR_VERSUS_RANKING, TextPositionManual, TextAnimationNone, 0.3 * scale);
    text->SetPosition(736, 512);
  }
  else
  {
    text = new TextRenderer(m_View, STR_VERSUS_RANKING, TextPositionManual, TextAnimationNone, 1.0);
    text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    text->SetPosition(304, 240);
  }
  text->SetColour(1.0, 1.0, 1.0);
  m_SlidingView->AddItem(text, 4);
  m_Items.push_back(text);
    
  if (ipad)
  {
    text = new TextRenderer(m_View, STR_SOUNDS, TextPositionManual, TextAnimationNone, 0.5);
    text->SetPosition(720, 820);
  }
  else
  {
    text = new TextRenderer(m_View, STR_SOUNDS, TextPositionManual, TextAnimationNone, 1.0);
    text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    text->SetPosition(300, 400);
  }
  text->SetColour(1.0, 1.0, 1.0);
  m_SlidingView->AddItem(text, 1);
  m_Items.push_back(text);
  
  if (ipad)
  {
    touchText = new TouchableTextRenderer(m_View, STR_ON, TextPositionManual, TextAnimationDropBounce, 0.5);
    touchText->SetPosition(650, 820);
  }
  else
  {
    touchText = new TouchableTextRenderer(m_View, STR_ON, TextPositionManual, TextAnimationDropBounce, 1.0);
    touchText->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    touchText->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    touchText->SetPosition(260, 400);
  }
  touchText->SetColour(1.0, 1.0, 1.0);
  if (! m_SoundsOn)
    touchText->SetVisible(FALSE);
  touchText->SetController(this);
  m_SlidingView->AddItem(touchText, 1);
  m_SoundsOnButton = touchText;
  
  if (ipad)
  {
    touchText = new TouchableTextRenderer(m_View, STR_OFF, TextPositionManual, TextAnimationDropBounce, 0.5);
    touchText->SetPosition(650, 820);
  }
  else
  {
    touchText = new TouchableTextRenderer(m_View, STR_OFF, TextPositionManual, TextAnimationDropBounce, 1.0);
    touchText->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    touchText->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    touchText->SetPosition(260, 400);
  }
  touchText->SetColour(1.0, 1.0, 1.0);
  if (m_SoundsOn)
    touchText->SetVisible(FALSE);
  touchText->SetController(this);
  m_SlidingView->AddItem(touchText, 1);
  m_SoundsOffButton = touchText;

  if (ipad)
  {
    text = new TextRenderer(m_View, STR_MUSIC, TextPositionManual, TextAnimationNone, 0.5);
    text->SetPosition(720, 530);
  }
  else
  {
    text = new TextRenderer(m_View, STR_MUSIC, TextPositionManual, TextAnimationNone, 1.0);
    text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    text->SetPosition(300, 250);
  }
  text->SetColour(1.0, 1.0, 1.0);
  m_SlidingView->AddItem(text, 1);
  m_Items.push_back(text);
  
  if (ipad)
  {
    touchText = new TouchableTextRenderer(m_View, STR_ON, TextPositionManual, TextAnimationDropBounce, 0.5);
    touchText->SetPosition(650, 530);
  }
  else
  {
    touchText = new TouchableTextRenderer(m_View, STR_ON, TextPositionManual, TextAnimationDropBounce, 1.0);
    touchText->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    touchText->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    touchText->SetPosition(260, 250);
  }
  touchText->SetColour(1.0, 1.0, 1.0);
  if (! m_MusicOn)
    touchText->SetVisible(FALSE);
  touchText->SetController(this);
  m_SlidingView->AddItem(touchText, 1);  
  m_MusicOnButton = touchText;

  if (ipad)
  {
    touchText = new TouchableTextRenderer(m_View, STR_OFF, TextPositionManual, TextAnimationDropBounce, 0.5);
    touchText->SetPosition(650, 530);
  }
  else
  {
    touchText = new TouchableTextRenderer(m_View, STR_OFF, TextPositionManual, TextAnimationDropBounce, 1.0);
    touchText->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    touchText->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    touchText->SetPosition(260, 250);
  }
  touchText->SetColour(1.0, 1.0, 1.0);
  if (m_MusicOn)
    touchText->SetVisible(FALSE);
  touchText->SetController(this);
  m_SlidingView->AddItem(touchText, 1);  
  m_MusicOffButton = touchText;

  if (ipad)
  {
    text = new TextRenderer(m_View, STR_CONTROLS, TextPositionManual, TextAnimationNone, 0.5);
    text->SetPosition(720, 210);
  }
  else 
  {
    text = new TextRenderer(m_View, STR_CONTROLS, TextPositionManual, TextAnimationNone, 1.0);
    text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    text->SetPosition(300, 95);
  }
  text->SetColour(1.0, 1.0, 1.0);
  m_SlidingView->AddItem(text, 1);
  m_Items.push_back(text);
  
  if (ipad)
  {
    touchText = new TouchableTextRenderer(m_View, STR_ON, TextPositionManual, TextAnimationDropBounce, 0.5);
    touchText->SetPosition(650, 210);
  }
  else
  {
    touchText = new TouchableTextRenderer(m_View, STR_ON, TextPositionManual, TextAnimationDropBounce, 1.0);
    touchText->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    touchText->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    touchText->SetPosition(260, 95);
  }
  touchText->SetColour(1.0, 1.0, 1.0);
  if (! m_ControlsOn)
    touchText->SetVisible(FALSE);
  touchText->SetController(this);
  m_SlidingView->AddItem(touchText, 1);  
  m_ControlsOnButton = touchText;

  if (ipad)
  {
    touchText = new TouchableTextRenderer(m_View, STR_OFF, TextPositionManual, TextAnimationDropBounce, 0.5);
    touchText->SetPosition(650, 210);
  }
  else
  {
    touchText = new TouchableTextRenderer(m_View, STR_OFF, TextPositionManual, TextAnimationDropBounce, 1.0);
    touchText->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    touchText->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    touchText->SetPosition(260, 95);
  }
  touchText->SetColour(1.0, 1.0, 1.0);
  if (m_ControlsOn)
    touchText->SetVisible(FALSE);
  touchText->SetController(this);
  m_SlidingView->AddItem(touchText, 1);  
  m_ControlsOffButton = touchText;
  
  if (m_UnlockedBoards == BoardBuilder::GetBoardCount())
  {
    if (ipad)
    {
      text = new TextRenderer(m_View, STR_ARENAS_UNLOCKED, TextPositionManual, TextAnimationNone, 0.5);
      text->SetPosition(520, 512);
    }
    else
    {
      text = new TextRenderer(m_View, STR_ARENAS_UNLOCKED, TextPositionManual, TextAnimationNone, 1.0);
      text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
      text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
      text->SetPosition(210, 240);
    }
    m_SlidingView->AddItem(text, 1);
    m_Items.push_back(text);
  }
  else 
  {
    if (ipad)
    {
      text = new TextRenderer(m_View, STR_ARENA_CONDITION_1, TextPositionManual, TextAnimationNone, 0.5);
      text->SetPosition(550, 512);
    }
    else
    {
      text = new TextRenderer(m_View, STR_ARENA_CONDITION_1, TextPositionManual, TextAnimationNone, 1.0);
      text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
      text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
      text->SetPosition(220, 240);
    }
    m_SlidingView->AddItem(text, 1);
    m_Items.push_back(text);
    
    stringstream ss;
    ss << BoardBuilder::GetPointsToUnlock(m_UnlockedBoards + 1);
    ss << STR_ARENA_CONDITION_2;
    ss << m_UnlockedBoards;
    if (ipad)
    {
      text = new TextRenderer(m_View, ss.str(), TextPositionManual, TextAnimationNone, 0.5);
      text->SetPosition(490, 512);
    }
    else
    {
      text = new TextRenderer(m_View, ss.str(), TextPositionManual, TextAnimationNone, 1.0);
      text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
      text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
      text->SetPosition(200, 240);
    }
    m_SlidingView->AddItem(text, 1);
    m_Items.push_back(text);
  }
  
  if (ipad)
  {
    touchText = new TouchableTextRenderer(m_View, "<", TextPositionManual, TextAnimationDropBounce, 0.5);
    touchText->SetPosition(240, 900);
  }
  else
  {
    touchText = new TouchableTextRenderer(m_View, "<", TextPositionManual, TextAnimationDropBounce, 1.0);
    touchText->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    touchText->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    touchText->SetPosition(95, 425);
  }
  touchText->SetColour(1.0, 1.0, 1.0);
  touchText->SetController(this);
  touchText->SetFireOnTouch(TRUE);
  if (m_BoardNo < 1)
    touchText->SetVisible(FALSE);
  m_SlidingView->AddItem(touchText, 1);  
  m_PrevBoardButton = touchText;
  
  if (ipad)
  {
    touchText = new TouchableTextRenderer(m_View, ">", TextPositionManual, TextAnimationDropBounce, 0.5);
    touchText->SetPosition(240, 124);
  }
  else
  {
    touchText = new TouchableTextRenderer(m_View, ">", TextPositionManual, TextAnimationDropBounce, 1.0);
    touchText->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    touchText->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    touchText->SetPosition(95, 55);
  }
  touchText->SetColour(1.0, 1.0, 1.0);
  touchText->SetController(this);
  touchText->SetFireOnTouch(TRUE);
  if (m_BoardNo >= m_UnlockedBoards - 1)
    touchText->SetVisible(FALSE);
  m_SlidingView->AddItem(touchText, 1);  
  m_NextBoardButton = touchText;
  
  if (ipad)
  {
    touchText = new TouchableTextRenderer(m_View, STR_FULL_TITLE, TextPositionManual, TextAnimationDropBounce, 0.5);
    touchText->SetPosition(718, 512);
  }
  else
  {
    touchText = new TouchableTextRenderer(m_View, STR_FULL_TITLE, TextPositionManual, TextAnimationDropBounce, 1.0);
    touchText->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    touchText->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    touchText->SetPosition(300, 240);
  }
  touchText->SetColour(1.0, 1.0, 1.0);
  touchText->SetController(this);
  touchText->SetUserRef(3);
  touchText->SetBorderWidth(0.85);
  m_SlidingView->AddItem(touchText, 0);
  m_Items.push_back(touchText);

  if (ipad)
  {
    touchText = new TouchableTextRenderer(m_View, STR_CREDITS_2, TextPositionManual, TextAnimationDropBounce, 0.5);
    touchText->SetPosition(608, 512);
  }
  else
  {
    touchText = new TouchableTextRenderer(m_View, STR_CREDITS_2, TextPositionManual, TextAnimationDropBounce, 1.0);
    touchText->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    touchText->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    touchText->SetPosition(250, 240);
  }
  touchText->SetColour(1.0, 1.0, 1.0);
  touchText->SetController(this);
  touchText->SetUserRef(5);
  touchText->SetBorderWidth(0.85);
  m_SlidingView->AddItem(touchText, 0);
  m_Items.push_back(touchText);

  if (ipad)
  {
    text = new TextRenderer(m_View, STR_CREDITS_1, TextPositionManual, TextAnimationNone, 0.5);
    text->SetPosition(648, 512);
  }
  else
  {
    text = new TextRenderer(m_View, STR_CREDITS_1, TextPositionManual, TextAnimationNone, 1.0);
    text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    text->SetPosition(270, 240);
  }
  text->SetColour(1.0, 1.0, 1.0);
  m_SlidingView->AddItem(text, 0);
  m_Items.push_back(text);
  
  if (ipad)
  {
    text = new TextRenderer(m_View, STR_CREDITS_4, TextPositionManual, TextAnimationNone, 0.5);
    text->SetPosition(468, 718);
  }
  else
  {
    text = new TextRenderer(m_View, STR_CREDITS_4, TextPositionManual, TextAnimationNone, 1.0);
    text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    text->SetPosition(180, 335);
  }
  text->SetColour(1.0, 1.0, 1.0);
  m_SlidingView->AddItem(text, 0);
  m_Items.push_back(text);

  if (ipad)
  {
    touchText = new TouchableTextRenderer(m_View, STR_CREDITS_5, TextPositionManual, TextAnimationDropBounce, 0.5);
    touchText->SetPosition(468, 326);
  }
  else
  {
    touchText = new TouchableTextRenderer(m_View, STR_CREDITS_5, TextPositionManual, TextAnimationDropBounce, 1.0);
    touchText->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    touchText->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    touchText->SetPosition(180, 145);
  }
  touchText->SetColour(1.0, 1.0, 1.0);
  touchText->SetController(this);
  touchText->SetUserRef(4);
  touchText->SetBorderWidth(0.85);
  m_SlidingView->AddItem(touchText, 0);
  m_Items.push_back(touchText);
  
  if (ipad)
  {
    text = new TextRenderer(m_View, STR_CREDITS_3, TextPositionManual, TextAnimationNone, 0.5);
    text->SetPosition(508, 512);
  }
  else
  {
    text = new TextRenderer(m_View, STR_CREDITS_3, TextPositionManual, TextAnimationNone, 1.0);
    text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    text->SetPosition(200, 240);
  }
  text->SetColour(1.0, 1.0, 1.0);
  m_SlidingView->AddItem(text, 0);
  m_Items.push_back(text);
  
  if (ipad)
  {
    text = new TextRenderer(m_View, STR_CREDITS_6, TextPositionManual, TextAnimationNone, 0.5);
    text->SetPosition(300, 512);
  }
  else
  {
    text = new TextRenderer(m_View, STR_CREDITS_6, TextPositionManual, TextAnimationNone, 1.0);
    text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    text->SetPosition(130, 240);
  }
  text->SetColour(1.0, 1.0, 1.0);
  m_SlidingView->AddItem(text, 0);
  m_Items.push_back(text);

  if (ipad)
  {
    text = new TextRenderer(m_View, STR_CREDITS_7, TextPositionManual, TextAnimationNone, 0.5);
    text->SetPosition(260, 512);
  }
  else
  {
    text = new TextRenderer(m_View, STR_CREDITS_7, TextPositionManual, TextAnimationNone, 1.0);
    text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    text->SetPosition(110, 240);
  }
  text->SetColour(1.0, 1.0, 1.0);
  m_SlidingView->AddItem(text, 0);
  m_Items.push_back(text);
  
  m_Marquee = new Marquee(m_View);
  if (ipad)
    m_Marquee->SetPosition(220, 512);
  else
    m_Marquee->SetPosition(90, 240);
  m_Marquee->AddText("SARAH GREEN");
  m_Marquee->AddText("JODIE MACBEATH");
  m_Marquee->AddText("JACQUELINE & BRIAN JOHN");
  m_Marquee->AddText("GLYN JOHN");
  m_Marquee->AddText("MATTHEW & LARA FONG BALDWIN");
  m_Marquee->AddText("NICK CLEMENT");
  m_Marquee->AddText("PETE & BETH CUDMORE");
  m_Marquee->AddText("AIMEE'S WINEHOUSE");
  m_Items.push_back(m_Marquee);
  m_SlidingView->AddItem(m_Marquee, 0);
  
  if (ipad)
  {
    text = new TextRenderer(m_View, STR_CREDITS_8, TextPositionManual, TextAnimationNone, 0.5);
    text->SetPosition(90, 512);
  }
  else
  {
    text = new TextRenderer(m_View, STR_CREDITS_8, TextPositionManual, TextAnimationNone, 1.0);
    text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    text->SetPosition(45, 240);
  }
  text->SetColour(1.0, 1.0, 1.0);
  m_SlidingView->AddItem(text, 0);
  m_Items.push_back(text);

  if (ipad)
  {
    text = new TextRenderer(m_View, STR_CREDITS_9, TextPositionManual, TextAnimationNone, 0.5);
    text->SetPosition(50, 512);
  }
  else
  {
    text = new TextRenderer(m_View, STR_CREDITS_9, TextPositionManual, TextAnimationNone, 1.0);
    text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
    text->SetPosition(25, 240);
  }
  text->SetColour(1.0, 1.0, 1.0);
  m_SlidingView->AddItem(text, 0);
  m_Items.push_back(text);

  m_SlidingView->SetStartPage(2);
}

void MainMenu::RenderPreview()
{
  m_View->SetViewArea(0, m_SlidingView->GetOffset(), m_View->GetViewW(), m_View->GetViewH());
  int by = m_View->GetViewH() / 4 - (OBSTACLE_SPRITE_SIZE / 2) * 3 - m_View->GetViewH();
  int bx = 0;
  if (Utils::IsiPad())
  {
    by += (OBSTACLE_SPRITE_SIZE / 2);
    bx += OBSTACLE_SPRITE_SIZE * 2;
  }  
  int lrx = bx + BG_SPRITE_SIZE / 4 - 2;
  int lry = by + BG_SPRITE_SIZE / 4 - 2;
  int tlx = lrx + m_BoardInfo.width / 2 + 4;
  int tly = by + m_BoardInfo.height / 2 + 2 + OBSTACLE_SPRITE_SIZE;
  
  float vertices[] = { lrx, lry, 0, tlx, lry, 0, lrx, tly, 0,
                       lrx, tly, 0, tlx, lry, 0, tlx, tly, 0 };
  
  for (int i = 0; i < 6; i++)
  {
    m_View->DrawShape(vertices, 6, 0.25, 0.0, 0.0, 0.0);
    vertices[0]--;
    vertices[1]--;
    vertices[3]++;
    vertices[4]--;
    vertices[6]--;
    vertices[7]++;
    vertices[9]--;
    vertices[10]++;
    vertices[12]++;
    vertices[13]--;
    vertices[15]++;
    vertices[16]++;
  }
  
  float opacity = 1.0;
  if (m_BoardIncrement != 0)
  {
    m_BoardFadeState++;
    if (m_BoardFadeState > BOARD_SELECT_FADE_FRAMES)
    {
      m_BoardFadeState = 0;
      if (! m_BoardFadeIn)
      {
        // TODO: Stop buttons bouncing in on every press
        m_BoardFadeIn = TRUE;
        int oldBoardNo = m_BoardNo;
        m_BoardNo += m_BoardIncrement;
        m_Controller->EventRaised(EVENT_BOARD_CHANGED, this);
        m_BoardInfo = BoardBuilder::GetBoardPreview(m_BoardNo);
        if (m_BoardNo == m_UnlockedBoards - 2)
        {
          if (oldBoardNo == m_UnlockedBoards - 1) m_NextBoardButton->AddAnimation(TextAnimationDropBounce);
          m_NextBoardButton->RemoveAnimation(TextAnimationDropOff);
          m_NextBoardButton->SetVisible(TRUE);
        }
        if (m_BoardNo == m_UnlockedBoards - 1)
        {
          m_NextBoardButton->AddAnimation(TextAnimationDropOff);
        }
        if (m_BoardNo == 1)
        {
          if (oldBoardNo == 0) m_PrevBoardButton->AddAnimation(TextAnimationDropBounce);
          m_PrevBoardButton->RemoveAnimation(TextAnimationDropOff);
          m_PrevBoardButton->SetVisible(TRUE);
        }
        if (m_BoardNo == 0)
        {
          m_PrevBoardButton->AddAnimation(TextAnimationDropOff);
        }
      }
      else
      {
        m_BoardIncrement = 0;
        m_BoardFadeIn = FALSE;
        m_BoardFadeState = 0;
      }
    }
    
    if (m_BoardFadeIn)
      opacity = m_BoardFadeState / (float) BOARD_SELECT_FADE_FRAMES;
    else
      opacity = (BOARD_SELECT_FADE_FRAMES - m_BoardFadeState) / (float) BOARD_SELECT_FADE_FRAMES;
  }
  
  int spritey = m_BG->GetBackgroundNo();
  spritey++;
  if (spritey > 2)
    spritey = 0;
  if (opacity == 1.0)
    m_View->SetAlphaBlendState(FALSE);
  int s1, s2;
  for (int x = 0; x < m_BoardInfo.width; x += BG_SPRITE_SIZE)
  {
    s1 = (x / BG_SPRITE_SIZE) % 2;
    s2 = (x / BG_SPRITE_SIZE) % 2 * 2;
    for (int y = 0; y < m_BoardInfo.height; y += BG_SPRITE_SIZE)
    {
      m_View->DrawSprite(BG_SPRITE_SHEET, s1 + s2, spritey, bx + x / 2, by + y / 2, 0, 0.5, opacity);
      s1 = 1 - s1;
    }  
  }
  m_View->SetAlphaBlendState(TRUE);
  
  vector<BasicSprite>::iterator iter = m_BoardInfo.board.begin();
  for (; iter != m_BoardInfo.board.end(); ++iter)
  {
    BasicSprite sprite = *iter;
    m_View->DrawSprite(OBSTACLE_SPRITE_SHEET, sprite.spriteX, sprite.spriteY, bx + sprite.x / 2 + OBSTACLE_SPRITE_SIZE / 4 * 3, by + sprite.y / 2 + OBSTACLE_SPRITE_SIZE / 4 * 3, sprite.angle, 0.5, opacity);
  }  
  
  stringstream ss;
  ss << m_BoardNo + 1;
  string str = ss.str();
  
  int x = 95 - FONT_SMALL_SPRITE_SIZE / 2;
  int y = 240 - str.length() * FONT_SMALL_SPRITE_SIZE / 2 - m_View->GetViewH();
  int inc = FONT_SMALL_SPRITE_SIZE;
  int sheet = FONT_SMALL_SPRITE_SHEET;
  float scale = 1.0;
  if (Utils::IsiPad())
  {
    x = 240 - FONT_SPRITE_SIZE / 2;
    y = 512 - str.length() * FONT_SPRITE_SIZE / 2 - m_View->GetViewH();
    inc = FONT_SPRITE_SIZE / 2;
    sheet = FONT_SPRITE_SHEET;
    scale = 0.5;
  }
  
  Coords c;
  for (int i = 0; i < str.length(); i++)
  {
    c = Utils::CharToSpriteCoords(str[str.length() - 1 - i]);
    m_View->DrawSprite(sheet, c.x, c.y, x, y, 90, scale, opacity * 0.5, 0.0, 0.0, 0.0);
    y += inc;
  }
}

void MainMenu::SetController(IGenericEvent* controller)
{
  m_Controller = controller;
}

void MainMenu::Render()
{  
  if (m_BG)
    m_BG->Render();
  
  RenderPreview();
  m_View->SetViewArea(0, m_SlidingView->GetOffset(), m_View->GetViewW(), m_View->GetViewH());
  if (Utils::IsiPad())
    m_View->DrawSprite(LOGO_SPRITE_SHEET, 0, 0, 470, -m_View->GetViewH() * 2 + 220, 0, 1.0, 1.0);
  else
    m_View->DrawSprite(LOGO_SPRITE_SHEET, 0, 0, 170, -m_View->GetViewH() * 2 + 75, 0, 1.0, 1.0);
  m_SlidingView->Render();
}

void MainMenu::TouchEvent(TouchInfo touches[], int count)
{
  m_SlidingView->TouchEvent(touches, count);
}

void MainMenu::EventRaised(int eventType, void* raiser)
{
  if (eventType == EVENT_TEXT_TOUCHED)
  {
    if (raiser == m_OnePlayerButton)
    {
      m_Controller->EventRaised(EVENT_1P_SELECTED, this);
    }
    else if (raiser == m_TwoPlayerButton)
    {
      m_OnePlayerButton->AddAnimation(TextAnimationDropOff);
      m_TwoPlayerButton->AddAnimation(TextAnimationDropOff);
      if (m_SharedTwoPlayerButton)
        m_SharedTwoPlayerButton->AddAnimation(TextAnimationDropOff);
      m_MainScreenRightArrow->AddAnimation(TextAnimationDropOff);
      m_MainScreenLeftArrow->AddAnimation(TextAnimationDropOff);
      m_StartGameButton->SetVisible(TRUE);
      m_JoinGameButton->SetVisible(TRUE);
      m_CancelButton->SetVisible(TRUE);
      m_StartGameButton->AddAnimation(TextAnimationDropBounce);
      m_JoinGameButton->AddAnimation(TextAnimationDropBounce);
      m_CancelButton->AddAnimation(TextAnimationDropBounce);
      m_StartGameButton->RemoveAnimation(TextAnimationDropOff);
      m_JoinGameButton->RemoveAnimation(TextAnimationDropOff);
      m_CancelButton->RemoveAnimation(TextAnimationDropOff);
      //m_Controller->EventRaised(EVENT_2P_SELECTED, this);
      m_SlidingView->SetLocked(TRUE);
      m_State = MenuStateStartJoin;
    }
    else if (raiser == m_SharedTwoPlayerButton)
    {
      m_Controller->EventRaised(EVENT_SHARED_2P_SELECTED, this);
    }
    else if (raiser == m_CancelButton)
    {
      m_StartGameButton->AddAnimation(TextAnimationDropOff);
      m_JoinGameButton->AddAnimation(TextAnimationDropOff);
      m_CancelButton->AddAnimation(TextAnimationDropOff);
      m_OnePlayerButton->AddAnimation(TextAnimationDropBounce);
      m_OnePlayerButton->RemoveAnimation(TextAnimationDropOff);
      m_TwoPlayerButton->AddAnimation(TextAnimationDropBounce);
      m_TwoPlayerButton->RemoveAnimation(TextAnimationDropOff);
      if (m_SharedTwoPlayerButton)
      {
        m_SharedTwoPlayerButton->AddAnimation(TextAnimationDropBounce);
        m_SharedTwoPlayerButton->RemoveAnimation(TextAnimationDropOff);
      }
      m_MainScreenRightArrow->AddAnimation(TextAnimationSplat);
      m_MainScreenRightArrow->RemoveAnimation(TextAnimationDropOff);
      m_MainScreenLeftArrow->AddAnimation(TextAnimationSplat);
      m_MainScreenLeftArrow->RemoveAnimation(TextAnimationDropOff);
      m_WaitingForOpponent->AddAnimation(TextAnimationDropOff);
      m_Connecting->AddAnimation(TextAnimationDropOff);
      m_SlidingView->SetLocked(FALSE);
      m_Controller->EventRaised(EVENT_START_GAME_CANCELLED, this);
    }
    else if (raiser == m_StartGameButton)
    {
      m_State = MenuStateServerNameEntry;
      m_PlayerNamePopup = new TextEntryPopup(this, m_PlayerName, STR_ENTER_NAME);
    }
    else if (raiser == m_JoinGameButton)
    {
      m_State = MenuStateClientNameEntry;
      m_PlayerNamePopup = new TextEntryPopup(this, m_PlayerName, STR_ENTER_NAME);
    }
    else if (raiser == m_SoundsOnButton)
    {
      m_SoundsOnButton->AddAnimation(TextAnimationDropOff);
      m_SoundsOffButton->AddAnimation(TextAnimationDropBounce);
      m_SoundsOffButton->RemoveAnimation(TextAnimationDropOff);
      m_SoundsOffButton->SetVisible(TRUE);
      m_Controller->EventRaised(EVENT_SOUND_OFF, this);
    }
    else if (raiser == m_SoundsOffButton)
    {
      m_SoundsOffButton->AddAnimation(TextAnimationDropOff);
      m_SoundsOnButton->AddAnimation(TextAnimationDropBounce);
      m_SoundsOnButton->RemoveAnimation(TextAnimationDropOff);
      m_SoundsOnButton->SetVisible(TRUE);
      m_Controller->EventRaised(EVENT_SOUND_ON, this);
    }
    else if (raiser == m_MusicOnButton)
    {
      m_MusicOnButton->AddAnimation(TextAnimationDropOff);
      m_MusicOffButton->AddAnimation(TextAnimationDropBounce);
      m_MusicOffButton->RemoveAnimation(TextAnimationDropOff);
      m_MusicOffButton->SetVisible(TRUE);
      m_Controller->EventRaised(EVENT_MUSIC_OFF, this);
    }
    else if (raiser == m_MusicOffButton)
    {
      m_MusicOffButton->AddAnimation(TextAnimationDropOff);
      m_MusicOnButton->AddAnimation(TextAnimationDropBounce);
      m_MusicOnButton->RemoveAnimation(TextAnimationDropOff);
      m_MusicOnButton->SetVisible(TRUE);
      m_Controller->EventRaised(EVENT_MUSIC_ON, this);
    }
    else if (raiser == m_ControlsOnButton)
    {
      m_ControlsOnButton->AddAnimation(TextAnimationDropOff);
      m_ControlsOffButton->AddAnimation(TextAnimationDropBounce);
      m_ControlsOffButton->RemoveAnimation(TextAnimationDropOff);
      m_ControlsOffButton->SetVisible(TRUE);
      m_Controller->EventRaised(EVENT_CONTROLS_OFF, this);
    }
    else if (raiser == m_ControlsOffButton)
    {
      m_ControlsOffButton->AddAnimation(TextAnimationDropOff);
      m_ControlsOnButton->AddAnimation(TextAnimationDropBounce);
      m_ControlsOnButton->RemoveAnimation(TextAnimationDropOff);
      m_ControlsOnButton->SetVisible(TRUE);
      m_Controller->EventRaised(EVENT_CONTROLS_ON, this);
    }
    else if (raiser == m_NextBoardButton)
    {
      if (m_BoardIncrement == 0)
      {
        m_BoardIncrement = 1;
      }
    }
    else if (raiser == m_PrevBoardButton)
    {
      if (m_BoardIncrement == 0)
      {
        m_BoardIncrement = -1;
      }
    }
    else 
    {
      TouchableTextRenderer* ttr = (TouchableTextRenderer*) raiser;
      switch (ttr->GetUserRef()) 
      {
        case 1:    
          m_SlidingView->SlideToNext();
          break;
        case 2:      
          m_SlidingView->SlideToPrev();
          break;
        case 3:
          {
            NSURL* snakesurl = [NSURL URLWithString: @STR_URL_SNAKES];
            [[UIApplication sharedApplication] openURL: snakesurl];
          }
          break;
        case 4:
          {
            NSURL* westyurl = [NSURL URLWithString: @STR_URL_WESTY];
            [[UIApplication sharedApplication] openURL: westyurl];
          }
          break;
        case 5:
          {
            NSURL* snakesurl = [NSURL URLWithString: @STR_URL_SYNIAD];
            [[UIApplication sharedApplication] openURL: snakesurl];
          }
          break;
      }
    }
  }
  else if (eventType == EVENT_CONNECTING)
  {
    m_Connecting->SetVisible(TRUE);
    m_Connecting->AddAnimation(TextAnimationDropBounce);
    m_Connecting->RemoveAnimation(TextAnimationDropOff);
    if (m_State == MenuStateStartJoin)
    {
      m_StartGameButton->AddAnimation(TextAnimationDropOff);
      m_JoinGameButton->AddAnimation(TextAnimationDropOff);
    }
    else if (m_State == MenuStateWaiting)
    {
      m_WaitingForOpponent->AddAnimation(TextAnimationDropOff);
    }
    m_State = MenuStateConnecting;
  }
  else if (eventType == EVENT_SESSION_ERROR)
  {
    if (m_State == MenuStateConnecting)
    {
      m_Connecting->AddAnimation(TextAnimationDropOff);
      m_StartGameButton->AddAnimation(TextAnimationDropBounce);
      m_StartGameButton->RemoveAnimation(TextAnimationDropOff);
      m_JoinGameButton->AddAnimation(TextAnimationDropBounce);
      m_JoinGameButton->RemoveAnimation(TextAnimationDropOff);
      m_State = MenuStateStartJoin;
    }
  }
  else if (eventType == EVENT_TEXT_ENTERED)
  {
    m_PlayerName = m_PlayerNamePopup->GetText();
    m_Controller->EventRaised(EVENT_PLAYER_NAME_ENTERED, this);
    delete m_PlayerNamePopup;
    m_PlayerNamePopup = NULL;
    if (m_State == MenuStateServerNameEntry)
    {
      m_StartGameButton->AddAnimation(TextAnimationDropOff);
      m_JoinGameButton->AddAnimation(TextAnimationDropOff);
      m_WaitingForOpponent->SetVisible(TRUE);
      m_WaitingForOpponent->AddAnimation(TextAnimationDropBounce);
      m_WaitingForOpponent->RemoveAnimation(TextAnimationDropOff);
      m_Controller->EventRaised(EVENT_START_GAME_SELECTED, this);
      m_State = MenuStateWaiting;
    }
    else if (m_State == MenuStateClientNameEntry)
    {
      m_State = MenuStateStartJoin;
      m_Controller->EventRaised(EVENT_JOIN_GAME_SELECTED, this);
    }
  }
}

void MainMenu::HighlightScore(int page, int pos)
{
  m_SlidingView->SlideTo(page);
  IGLViewConsumer* item;
  
  float scale = Utils::IsiPad() ? 2.0 : 1.0;

  ScrollingView* scroller;
  if (page == 3)
    scroller = m_HighScores;
  else if (page == 4)
    scroller = m_VersusRanking;
  else
    return;
  
  int x = m_View->GetViewW() - FONT_SPRITE_SIZE * scale - ((pos - 1) * FONT_SPRITE_SIZE / 3 * scale);
  if (x < FONT_SPRITE_SIZE / 3 * scale)
    scroller->SetOffset(abs(x) + FONT_SPRITE_SIZE / 3 * scale);

  pos = (pos - 1) * 3;
  for (int i = 0; i < 3; i++)
  {
    item = scroller->GetItem(pos + i);
    
    if (item)
    {
      TextRenderer* text = dynamic_cast<TextRenderer*> (item);
      if (text)
      {
        text->SetColour(0.7, 0.5, 1.0);
        text->AddAnimation(TextAnimationSplatRepeat);
      }
    }
  }
}

void MainMenu::SetPlayerName(string name)
{
  m_PlayerName = name;
}

string MainMenu::GetPlayerName()
{
  return m_PlayerName;
}

int MainMenu::GetBoardNo()
{
  return m_BoardNo;
}

