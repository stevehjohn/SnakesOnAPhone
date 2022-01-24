/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <sstream>

#import "AppController.h"
#import "Constants.h"
#import "Game.h"
#import "Utils.h"
#import "SimplePersister.h"
#import "BJSessionManager.h"
#import "ALManager.h"
#import "AVAPManager.h"

#ifdef ALL_BOARDS
#import "BoardBuilder.h"
#endif

AppController::AppController(GL2DView* view)
{
  m_View = view;
  
  m_Font = m_View->LoadSpriteSheet(FONT_SPRITE_SHEET, "Font.png", FONT_SPRITE_SIZE, FONT_SPRITE_SIZE, 0);
  m_Sprites = m_View->LoadSpriteSheet(GAME_SPRITE_SHEET, "Sprites.png", GAME_SPRITE_SIZE, GAME_SPRITE_SIZE, 1);
  m_Backgrounds = m_View->LoadSpriteSheet(BG_SPRITE_SHEET, "Backgrounds.png", BG_SPRITE_SIZE, BG_SPRITE_SIZE, 0);
  m_Obstacles = m_View->LoadSpriteSheet(OBSTACLE_SPRITE_SHEET, "Obstacles.png", OBSTACLE_SPRITE_SIZE, OBSTACLE_SPRITE_SIZE, 1);
  m_FontSmall = m_View->LoadSpriteSheet(FONT_SMALL_SPRITE_SHEET, "FontSmall.png", FONT_SMALL_SPRITE_SIZE, FONT_SMALL_SPRITE_SIZE, 1);  
  m_Controls = m_View->LoadSpriteSheet(CONTROLS_SPRITE_SHEET, "Controls.png", CONTROLS_SPRITE_SIZE, CONTROLS_SPRITE_SIZE, 0);  
  if (Utils::IsiPad())
    m_Logo = m_View->LoadSpriteSheet(LOGO_SPRITE_SHEET, "LogoLarge.png", LOGO_SPRITE_SHEET_H, LOGO_SPRITE_SHEET_W, 0);
  else
    m_Logo = m_View->LoadSpriteSheet(LOGO_SPRITE_SHEET, "LogoSmall.png", LOGO_SMALL_SPRITE_SHEET_H, LOGO_SMALL_SPRITE_SHEET_W, 0);
  
  ALManager* alInst = ALManager::Instance();
  alInst->LoadSound(SOUND_BOING, "Boing", 22050);
  alInst->LoadSound(SOUND_CHOMP_1, "Chomp1", 22050);
  alInst->LoadSound(SOUND_CHOMP_2, "Chomp2", 22050);
  alInst->LoadSound(SOUND_COLLIDE_1, "Collide1", 22050);
  
  m_TouchReceiver = 0;
  m_SessionManager = new BJSessionManager();
  
  m_SinglePlayerHighScoreFile = new SimplePersister("1PHS.dat");
  m_SinglePlayerScores = new HighScoreManager<SinglePlayerHighScore>(m_SinglePlayerHighScoreFile, HIGH_SCORE_COUNT_SINGLE_PLAYER);
  
  m_MultiplayerHighScoreFile = new SimplePersister("2PHS.dat");
  m_MultiplayerScores = new HighScoreManager<MultiplayerHighScore>(m_MultiplayerHighScoreFile, HIGH_SCORE_COUNT_MULTIPLAYER);
  
  m_PreferencesFile = new SimplePersister("Prefs.dat");
  m_SoundOn = TRUE;
  m_MusicOn = TRUE;
  m_ControlsOn = TRUE;
  
  m_BoardNo = 0;
  m_UnlockedBoards = 2;

  ReadPreferences();
  
  m_TextBox = NULL;
  
  m_NewScore = 0;
  m_NewRank = 0;
  
  m_PausedAlert = NULL;
  
  if (m_MusicOn)
    AVAPManager::Instance()->PlayMusic("Theme", "mp3");
  
  alInst->SetSoundStatus(m_SoundOn);
}

void AppController::Start()
{  
  m_TheGame = NULL;
  
  StartMenu();
  
  m_Timer = [[Timer alloc] init];
  [m_Timer Start : this : (1.0 / FRAMES_PER_SECOND)];
}

void AppController::ClearConsumers()
{
  vector<IGLViewConsumer*>::iterator iter = m_Consumers.begin();
  
  for (; iter != m_Consumers.end(); ++iter)
    delete (*iter);
  
  m_Consumers.clear();
  
  m_TheGame = NULL;
  m_TouchReceiver = NULL;
  m_Menu = NULL;
}

void AppController::StartMenu()
{
  MainMenu* menu = new MainMenu(m_View, m_SinglePlayerScores, m_MultiplayerScores, m_SoundOn, m_MusicOn, m_ControlsOn, m_BoardNo, m_UnlockedBoards);
  menu->SetController(this);
  menu->SetPlayerName(m_LastHighScoreName);
  m_Menu = menu;
  m_TouchReceiver = menu;
  m_Consumers.push_back(menu);
  
  if (m_NewScore)
    m_Menu->HighlightScore(3, m_NewScore);
  else if (m_NewRank)
    m_Menu->HighlightScore(4, m_NewRank);
  
  m_AppState = AppStateMainMenu;
}

void AppController::StartGame(GameType type)
{
  m_NewScore = 0;
  m_NewRank = 0;
  
  m_TheGame = new Game(m_View, type, m_ControlsOn);
  if (type == GameTypeMultiplayer)
  {
    m_TheGame->SetSessionManager(m_SessionManager);
  }
  m_TheGame->Initialise(m_BoardNo);
  m_TheGame->SetUnlockedBoards(m_UnlockedBoards);
  m_TheGame->SetController(this);
  m_TouchReceiver = m_TheGame;
  m_Consumers.push_back(m_TheGame);
  
  m_AppState = AppStatePlaying;
  
  [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
}

void AppController::Tick()
{  
  m_View->BeginFrame(FALSE);
  
  vector<IGLViewConsumer*>::iterator iter = m_Consumers.begin();
  
  for (; iter != m_Consumers.end(); ++iter)
  {
    (*iter)->Render();
  }
  
  m_View->EndFrame();
}

void AppController::TouchEvent(TouchInfo touches[], int count)
{
  if (m_TouchReceiver)
    m_TouchReceiver->TouchEvent(touches, count);
}

void AppController::DataReceived()
{
  int len;
  char* data;
  m_SessionManager->GetData((void*&) data, len);

  switch (data[0])
  {
    case PACKET_OPPONENT_NAME:
      if (len == 1)
      {
        m_OpponentName = STR_DEFAULT_OPPONENT_NAME;
      }
      else
      {
        m_OpponentName = string(len - 1, ' ');
        for (int i = 1; i < len; i++)
          m_OpponentName[i - 1] = ((char*) data)[i];
      }
      break;
    case PACKET_PAUSE_NOTIFICATION:
      RemotePause();
      break;
    case PACKET_RESUME_NOTIFICATION:
      RemoteResume();
      break;
    default:
      if (m_TheGame)
        m_TheGame->EventRaised(EVENT_DATA_RECEIVED, m_SessionManager);
  }
}

void AppController::EventRaised(int eventType, void* raiser)
{
  switch (eventType)
  {
    case EVENT_DATA_RECEIVED:
      {
        DataReceived();
      }
      break;
    case EVENT_GAME_OVER:
      [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
      m_SessionManager->EndSession();
      if (! CheckHighScores())
      {
        ClearConsumers();
        StartMenu();
      }
      break;
    case EVENT_1P_SELECTED:
      ClearConsumers();
      StartGame(GameTypeSinglePlayer);
      break;
    case EVENT_SHARED_2P_SELECTED:
      ClearConsumers();
      StartGame(GameTypeLocalMultiplayer);
      m_TextEntryType = TextEntryTypeP1Name;
      [[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationPortrait];
      m_TextBox = new TextEntryPopup(this, m_LastP1Name, STR_P1_NAME_ENTRY);
      break;
    case EVENT_SESSION_STARTED:      
      {
        int len = m_LastHighScoreName.length() + 1;
        char data[len];
        data[0] = PACKET_OPPONENT_NAME;
        for (int i = 0; i < len - 1; i++)
          data[i + 1] = m_LastHighScoreName[i];
        m_SessionManager->SendData((void*) data, len, TRUE);
        ClearConsumers();
        StartGame(GameTypeMultiplayer);
      }
      break;
    case EVENT_TEXT_ENTERED:
      TextEntered();
      break;
    case EVENT_START_GAME_SELECTED:
      m_SessionManager->StartSession(this, SessionModeServer);
      break;
    case EVENT_JOIN_GAME_SELECTED:
      m_SessionManager->StartSession(this, SessionModeClient);
      break;
    case EVENT_START_GAME_CANCELLED:
      m_SessionManager->EndSession();
      break;
    case EVENT_CONNECTING:
      if (m_Menu)
        m_Menu->EventRaised(EVENT_CONNECTING, this);
      break;
    case EVENT_SESSION_ERROR:
      {
        if (m_PausedAlert)
        {
          [m_PausedAlert dismiss];
          [m_PausedAlert release];
          m_PausedAlert = NULL;
          [m_Timer Start: this: (1.0 / FRAMES_PER_SECOND)];
        }
        UIAlertViewDelegate* connectionAlert = [[UIAlertViewDelegate alloc] initWithReceiver: NULL: nil: @STR_UNABLE_CONNECT: NO: @STR_UNABLE_CONNECT_MSG: @STR_OK];
        [connectionAlert release];
        if (m_Menu)
          m_Menu->EventRaised(EVENT_SESSION_ERROR, this);
      }
      break;
    case EVENT_CONNECTION_LOST:
      {
        if (m_TheGame && ! m_TheGame->GetDidOpponentQuit())
        {
          ClearConsumers();
          StartMenu();
          if (m_PausedAlert)
          {
            [m_PausedAlert dismiss];
            [m_PausedAlert release];
            m_PausedAlert = NULL;
            [m_Timer Start: this: (1.0 / FRAMES_PER_SECOND)];
          }
          UIAlertViewDelegate* connectionAlert = [[UIAlertViewDelegate alloc] initWithReceiver: NULL: nil: @STR_CONNECTION_LOST: NO: @STR_CONNECTION_LOST_MSG: @STR_OK];
          [connectionAlert release];
        }
      }
      break;
    case EVENT_ALERT_DISMISSED:
      if ((UIAlertViewDelegate*) raiser == m_PausedAlert)
      {
        [m_PausedAlert release];
        m_PausedAlert = NULL;
        if (m_TheGame && m_TheGame->GetGameType() == GameTypeMultiplayer)
        {
          m_SessionManager->EndSession();
          ClearConsumers();
          StartMenu();
        }
        [m_Timer Start: this: (1.0 / FRAMES_PER_SECOND)];
      }
      break;
    case EVENT_SEARCH_CANCELLED:
      m_SessionManager->EndSession();
      break;
    case EVENT_PLAYER_NAME_ENTERED:
      m_LastHighScoreName = m_Menu->GetPlayerName();
      WritePreferences();
      break;
    case EVENT_SOUND_OFF:
      m_SoundOn = FALSE;
      ALManager::Instance()->SetSoundStatus(FALSE);
      WritePreferences();
      break;
    case EVENT_SOUND_ON:
      m_SoundOn = TRUE;
      ALManager::Instance()->SetSoundStatus(TRUE);
      WritePreferences();
      break;
    case EVENT_MUSIC_OFF:
      m_MusicOn = FALSE;
      AVAPManager::Instance()->Stop();
      WritePreferences();
      break;
    case EVENT_MUSIC_ON:
      m_MusicOn = TRUE;
      AVAPManager::Instance()->PlayMusic("Theme", "mp3");
      WritePreferences();
      break;
    case EVENT_CONTROLS_OFF:
      m_ControlsOn = FALSE;
      WritePreferences();
      break;
    case EVENT_CONTROLS_ON:
      m_ControlsOn = TRUE;
      WritePreferences();
      break;
    case EVENT_BOARD_CHANGED:
      m_BoardNo = m_Menu->GetBoardNo();
      WritePreferences();
      break;
    case EVENT_1P_PAUSED:
      m_PausedAlert = [[[UIAlertViewDelegate alloc] initWithReceiver: this: nil: @STR_PAUSED: NO: @"": @STR_CONTINUE] retain];
      [m_Timer Stop];
      break;
    case EVENT_NEW_ARENA_UNLOCKED:
      m_UnlockedBoards++;
      WritePreferences();
      break;
  }
}

void AppController::TextEntered()
{
  switch (m_TextEntryType) 
  {
    case TextEntryTypeHighScore:
      AddHighScore();
      ClearConsumers();
      StartMenu();
      break;
    case TextEntryTypeP1Name:
      m_LastP1Name = m_TextBox->GetText();
      delete m_TextBox;
      m_TextEntryType = TextEntryTypeP2Name;
      [[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationPortraitUpsideDown];
      m_TextBox = new TextEntryPopup(this, m_LastP2Name, STR_P2_NAME_ENTRY);
      break;
    case TextEntryTypeP2Name:
      m_LastP2Name = m_TextBox->GetText();
      delete m_TextBox;
      m_TextBox = NULL;
      [[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeRight];
      WritePreferences();
      m_TheGame->GotNames();
      break;
  }
}

bool AppController::CheckHighScores()
{
  bool highScore = FALSE;
  
  switch (m_TheGame->GetGameType())
  {
    case GameTypeSinglePlayer:
      {
        SinglePlayerHighScore score(m_TheGame->GetPlayerScore());
        if (m_SinglePlayerScores->IsHighScore(score))
        {
          highScore = TRUE;
          m_TextEntryType = TextEntryTypeHighScore;
          m_TextBox = new TextEntryPopup(this, m_LastHighScoreName, STR_HI_SCORE_POPUP);
        }
      }
      break;
    case GameTypeLocalMultiplayer:
      {
        MultiplayerHighScore score(m_TheGame->GetPlayerWins(), Utils::StdStringToUppercase(m_LastP1Name), m_TheGame->GetOpponentWins(), Utils::StdStringToUppercase(m_LastP2Name));
        m_NewRank = m_MultiplayerScores->InsertHighScore(score);
      }
      break;
    case GameTypeMultiplayer:
      {
        MultiplayerHighScore score(m_TheGame->GetPlayerWins(), Utils::StdStringToUppercase(m_LastHighScoreName), m_TheGame->GetOpponentWins(), Utils::StdStringToUppercase(m_OpponentName));
        m_NewRank = m_MultiplayerScores->InsertHighScore(score);
      }
      break;
  }
  
  return highScore;
}

void AppController::AddHighScore()
{  
  m_LastHighScoreName = m_TextBox->GetText();
  SinglePlayerHighScore score(m_TheGame->GetPlayerScore(), Utils::StdStringToUppercase(m_LastHighScoreName));
  
  m_NewScore = m_SinglePlayerScores->InsertHighScore(score);

  delete m_TextBox;
  m_TextBox = NULL;
  
  WritePreferences();
}

void AppController::ReadPreferences()
{
  m_LastHighScoreName = "";
  m_PreferencesFile->Open(PersisterModeRead);
  string data;
  if (m_PreferencesFile->ReadLine(data))
    m_LastHighScoreName = data;
  if (m_PreferencesFile->ReadLine(data))
    m_LastP1Name = data;
  if (m_PreferencesFile->ReadLine(data))
    m_LastP2Name = data;
  if (m_PreferencesFile->ReadLine(data))
    m_SoundOn = data == "YES" ? TRUE : FALSE;
  if (m_PreferencesFile->ReadLine(data))
    m_MusicOn = data == "YES" ? TRUE : FALSE;
  if (m_PreferencesFile->ReadLine(data))
    m_ControlsOn = data == "YES" ? TRUE : FALSE;
  if (m_PreferencesFile->ReadLine(data))
  {
    stringstream ss(data);
    ss >> m_BoardNo;
  }
  if (m_PreferencesFile->ReadLine(data))
  {
    stringstream ss(data);
    ss >> m_UnlockedBoards;
  }
  
#ifdef ALL_BOARDS
  m_UnlockedBoards = BoardBuilder::GetBoardCount();
#endif
  
  m_PreferencesFile->Close();
}

void AppController::WritePreferences()
{
  m_PreferencesFile->Open(PersisterModeWrite);
  m_PreferencesFile->WriteLine(m_LastHighScoreName);
  m_PreferencesFile->WriteLine(m_LastP1Name);
  m_PreferencesFile->WriteLine(m_LastP2Name);
  m_PreferencesFile->WriteLine(m_SoundOn ? "YES" : "NO");
  m_PreferencesFile->WriteLine(m_MusicOn ? "YES" : "NO");
  m_PreferencesFile->WriteLine(m_ControlsOn ? "YES" : "NO");
  {
    stringstream ss;
    ss << m_BoardNo;
    m_PreferencesFile->WriteLine(ss.str());
  }
  {
    stringstream ss;
    ss << m_UnlockedBoards;
    m_PreferencesFile->WriteLine(ss.str());
  }
  m_PreferencesFile->Close();
}

void AppController::Interrupted()
{
  if (m_TheGame && m_TheGame->GetGameType() == GameTypeMultiplayer)
  {
    char data = PACKET_PAUSE_NOTIFICATION;
    m_SessionManager->SendData(&data, 1, TRUE);
  }
  
  [m_Timer Stop];
  
  AVAPManager::Instance()->Pause();
}

void AppController::Backgrounded()
{
  [m_Timer Stop];
  
  if (m_TheGame && m_TheGame->GetGameType() == GameTypeMultiplayer)
  {
    m_SessionManager->EndSession();
    ClearConsumers();
    StartMenu();
  }
  
  AVAPManager::Instance()->Pause();
}

void AppController::Resumed()
{
  if (m_TheGame && m_TheGame->GetGameType() == GameTypeMultiplayer)
  {
    char data = PACKET_RESUME_NOTIFICATION;
    m_SessionManager->SendData(&data, 1, TRUE);
  }

  AVAPManager::Instance()->Resume();

  if (m_TheGame && m_TheGame->GetGameType() == GameTypeSinglePlayer)
  {
    m_PausedAlert = [[[UIAlertViewDelegate alloc] initWithReceiver: this: nil: @STR_PAUSED: NO: @STR_PAUSED_BY_INTERRUPT: @STR_CONTINUE] retain];
    return;
  }
  
  [m_Timer Start: this: (1.0 / FRAMES_PER_SECOND)];
}

void AppController::RemotePause()
{
  if (m_PausedAlert)
  {
    [m_PausedAlert dismiss];
    [m_PausedAlert release];
    m_PausedAlert = NULL;
  }
  m_PausedAlert = [[[UIAlertViewDelegate alloc] initWithReceiver: this: nil: @STR_PAUSED: NO: @STR_PAUSED_MSG: @STR_QUIT] retain];
  [m_Timer Stop];
}

void AppController::RemoteResume()
{
  if (m_PausedAlert)
  {
    [m_PausedAlert dismiss];
    [m_PausedAlert release];
    m_PausedAlert = NULL;
  }
  [m_Timer Start: this: (1.0 / FRAMES_PER_SECOND)];
}

AppController::~AppController()
{
  // TODO: Cleanup
  ClearConsumers();
  delete m_SessionManager;
  delete m_SinglePlayerScores;
  delete m_SinglePlayerHighScoreFile;
  delete m_PreferencesFile;
  delete m_MultiplayerScores;
  delete m_MultiplayerHighScoreFile;
  
  if (m_TextBox)
  {
    delete m_TextBox;
    m_TextBox = NULL;
  }
  
  [m_Timer release];
}