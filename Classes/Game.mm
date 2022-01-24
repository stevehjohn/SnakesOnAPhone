/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <sstream>

#import "Game.h"
#import "GIBackground.h"
#import "GIFrog.h"
#import "Constants.h"
#import "GIWalls.h"
#import "BoardBuilder.h"
#import "TextRenderer.h"
#import "Utils.h"
#import "ALManager.h"

Game::Game(GL2DView* view, GameType type, BOOL showControls) : IGLViewConsumer(view)
{
  // Vars to persist across multiplayer rematches
  m_BoardNo = 0;
  m_GameType = type;
  m_PlayerWins = 0;
  m_OpponentWins = 0;
  m_PlayerScore = 0;
  m_OpponentScore = 0;
  m_SessionManager = NULL;
  m_Controller = NULL;
  m_DisplayScores[0] = 0;
  m_DisplayScores[1] = 0;
  m_GameCount = 0;
  m_RadarState = 0.0;
  if (showControls)
  {
    m_ControlsDisplayFrames = CONTROLS_DISPLAY_FRAMES;
    m_ControlsOpacity = 0.5;
  }
  else 
  {
    m_ControlsDisplayFrames = 0;
    m_ControlsOpacity = 0.0;
  }
  m_ControlsRotation = 0;
  InitClass();
}

void Game::InitClass()
{
  m_GameCount++;
  // Vars to start afresh each round
  m_RematchMenu = NULL;
  m_TouchState = None;
  m_OpponentTouchState = None;
  m_DataFrame = 0;
  m_TextOverlays[0] = NULL;
  m_TextOverlays[1] = NULL;
  m_UnlockOverlays[0] = NULL;
  m_UnlockOverlays[1] = NULL;
  m_UnlockDisplayCount = 0;
  if (m_GameType == GameTypeMultiplayer)
    m_GameState = GameStateWaitingForSync;
  else if (m_GameType == GameTypeLocalMultiplayer && m_GameCount < 2)
    m_GameState = GameStateWaitingForNames;
  else
    m_GameState = GameStateStarting;
  m_StateVar = 0;
  
  if (Utils::IsiPad())
    m_GameTextScale = 1.0;
  else
    m_GameTextScale = 0.8;
}

void Game::Initialise(int boardNumber)
{
  m_Board = BoardBuilder::GetBoard(boardNumber);
  m_BoardNo = boardNumber;
  m_Camera.x = 0;
  m_Camera.y = 0;
    
  GIBackground* bg = new GIBackground(m_Board.width, m_Board.height, 0);
  m_BackgroundNo = bg->GetBackgroundNumber();
  m_GameItems.push_back(bg);
  m_GameItems.push_back(new GIWalls(&m_Board.board));
  m_GameItems.push_back(new GIFrog(m_Board.width, m_Board.height));
  m_GameItems.push_back(new GIFrog(m_Board.width, m_Board.height));
  m_GameItems.push_back(new GIFrog(m_Board.width, m_Board.height));
  m_GameItems.push_back(new GIFrog(m_Board.width, m_Board.height));
  
  GISnake* player;
  if (m_GameType == GameTypeDemo)
  {
    player = new GISnake(64, 64, 0, 2, 0, m_Board.width, m_Board.height, TRUE);
    player->SetWaypoints(m_Board.waypoints);
  }
  else
    player = new GISnake(64, 64, 0, 2, 0, m_Board.width, m_Board.height, FALSE);
  player->SetController(this);
  m_GameItems.push_back(player);
  if (m_GameType == GameTypeMultiplayer && m_SessionManager->IsServer())
    m_Opponent = player;
  else 
    m_Player = player;
  
  switch (m_GameType)
  {
    case GameTypeSinglePlayer:
    case GameTypeDemo:
      player = new GISnake(m_Board.width - 84, m_Board.height - 84, 180, 2, 1, m_Board.width, m_Board.height, TRUE);
      player->SetWaypoints(m_Board.waypoints);
      player->SetController(this);
      m_GameItems.push_back(player);
      m_Opponent = player;
      break;
    case GameTypeMultiplayer:
    case GameTypeLocalMultiplayer:
      player = new GISnake(m_Board.width - 84, m_Board.height - 84, 180, 2, 1, m_Board.width, m_Board.height, FALSE);
      player->SetController(this);
      m_GameItems.push_back(player);
      if (m_GameType == GameTypeMultiplayer && m_SessionManager->IsServer())
        m_Player = player;
      else 
        m_Opponent = player;
      break;
  }
  
  if (m_GameType == GameTypeMultiplayer && m_SessionManager->IsServer())
  {
    char arenadata[2];
    arenadata[0] = PACKET_ARENA_NUMBER;
    arenadata[1] = m_BoardNo;
    m_SessionManager->SendData(&arenadata, 2, TRUE);
  }
  
  m_Player->SetStats(m_PlayerScore, m_PlayerWins);
  m_Opponent->SetStats(m_OpponentScore, m_OpponentWins);
  
  if (m_GameType != GameTypeDemo)
  {
    if (m_GameState != GameStateWaitingForNames)
      ShowPlayerText(STR_READY);
    
    m_StateVar = 0;
    m_Player->SetPaused(TRUE);
    m_Opponent->SetPaused(TRUE);
  }
  else 
  {
    m_GameState = GameStatePlaying;
    m_StateVar = 0;
  }
}

void Game::AdjustView()
{ 
  float scale = 1;
  
  Coords coords = m_Player->GetCoords();  
  coords.x -= m_View->GetViewW() * scale / 2;
  coords.y -= m_View->GetViewH() * scale / 2;
  
  /*
  AngleDelta d = Utils::GetAngleDelta(m_Player->GetDirection());
  coords.x += d.dX * 300;
  coords.y += d.dY * 500;
  */
  /*
   * Camera panning below works properly, but leaves player blind when
   * they switch ends of the board, so left it out for now.
   *
  if (m_Camera.x < coords.x - CAMERA_MOVE_INCREMENT)
    m_Camera.x += CAMERA_MOVE_INCREMENT;
  else if (m_Camera.x > coords.x + CAMERA_MOVE_INCREMENT)
    m_Camera.x -= CAMERA_MOVE_INCREMENT;
  else
    m_Camera.x = coords.x;
  
  if (m_Camera.y < coords.y - CAMERA_MOVE_INCREMENT)
    m_Camera.y += CAMERA_MOVE_INCREMENT;
  else if (m_Camera.y > coords.y + CAMERA_MOVE_INCREMENT)
    m_Camera.y -= CAMERA_MOVE_INCREMENT;
  else 
    m_Camera.y = coords.y;  
    */
  
  m_Camera.x = coords.x;
  m_Camera.y = coords.y;
  
  if (m_Camera.x < 0) m_Camera.x = 0;
  if (m_Camera.y < 0) m_Camera.y = 0;
  if (m_Camera.x > m_Board.width - m_View->GetViewW() * scale) m_Camera.x = m_Board.width - m_View->GetViewW() * scale;
  if (m_Camera.y > m_Board.height - m_View->GetViewH() * scale) m_Camera.y = m_Board.height - m_View->GetViewH() * scale;

  m_View->SetViewArea(m_Camera.x, m_Camera.y, m_View->GetViewW() * scale, m_View->GetViewH() * scale);
}

void Game::Render()
{
  AdjustView();
  
  vector<IGameItem*>::iterator iter = m_GameItems.begin();
  
  // Render previous state of all items
  for (; iter != m_GameItems.end(); ++iter)
  {
    (*iter)->Render(m_View);
  }
  
  if (m_GameType != GameTypeDemo && ! Utils::IsiPad() && m_GameState == GameStatePlaying)
  {
    RenderRadar();
  }
    
  if (m_GameState != GameStateWaitingForSync) // TODO: Will need a timeout on this
  {
    if (m_TouchState & P1Left)
      m_Player->TurnLeft();
    if (m_TouchState & P1Right)
      m_Player->TurnRight();

    if (m_GameType == GameTypeLocalMultiplayer)
    {      
      if (m_TouchState & P2Left)
        m_Opponent->TurnLeft();
      if (m_TouchState & P2Right)
        m_Opponent->TurnRight();
    }
    else if (m_GameType == GameTypeMultiplayer)
    {
      if (m_OpponentTouchState & P1Left)
        m_Opponent->TurnLeft();
      if (m_OpponentTouchState & P1Right)
        m_Opponent->TurnRight();
    }

    // Now allow items to update their state
    iter = m_GameItems.begin();
    for (; iter != m_GameItems.end(); ++iter)
    {
      (*iter)->Update(&m_GameItems, m_GameType == GameTypeMultiplayer && ! m_SessionManager->IsServer());
    }
    
    // Now allow items to check interactions with each other
    // Separate call to Update so that all items have changed their state
    // before any interaction checks are done
    if (! (m_GameType == GameTypeMultiplayer && ! m_SessionManager->IsServer()))
    {
      iter = m_GameItems.begin();
      for (; iter != m_GameItems.end(); ++iter)
      {
        (*iter)->CheckInteractions(&m_GameItems);
      }

      if (m_GameState == GameStateSnakeDied)
      {
        SnakeCollided();
        m_GameState = GameStatePlaying;
      }
    }
        
    if (m_GameType != GameTypeDemo)
    {
      if (m_GameType == GameTypeLocalMultiplayer)
      {
        RenderHUD(TRUE);
        RenderHUD(FALSE);
      }
      else 
        RenderHUD(TRUE);      

      RenderControls();
      
      if (m_GameType == GameTypeSinglePlayer)
      {
        m_View->DrawSprite(FONT_SMALL_SPRITE_SHEET, 7, 6, m_View->GetViewW() - FONT_SMALL_SPRITE_SIZE, m_View->GetViewH() - FONT_SMALL_SPRITE_SIZE, 90, 1.0, 0.5, 0.0, 0.0, 0.0);
      }
    }
    
    if (m_GameType == GameTypeMultiplayer)
    {
      if (m_DataFrame < 1)
      {
        SendData();
        m_DataFrame = DATA_SEND_FREQUENCY;
      }
      m_DataFrame--;
    }
    
    // Check for unlocking of next board
    if (m_GameType == GameTypeSinglePlayer && ! m_UnlockNotified)
    {
      if (m_Player->GetScore() >= BoardBuilder::GetPointsToUnlock(m_UnlockedBoards + 1))
      {
        m_UnlockNotified = TRUE;
        m_Controller->EventRaised(EVENT_NEW_ARENA_UNLOCKED, this);
        stringstream ss;
        ss << STR_ARENA;
        ss << (m_UnlockedBoards + 1);
        m_UnlockOverlays[0] = new TextRenderer(m_View, ss.str(), TextPositionManual, TextAnimationDropBounce, 1.0);
        m_UnlockOverlays[0]->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
        m_UnlockOverlays[0]->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
        m_UnlockOverlays[0]->SetOpacity(0.8);
        m_UnlockOverlays[0]->SetColour(1.0, 1.0, 1.0);
        m_UnlockOverlays[0]->SetPosition(FONT_SMALL_SPRITE_SIZE * 3, m_View->GetViewH() / 2);
        
        m_UnlockOverlays[1] = new TextRenderer(m_View, STR_UNLOCKED, TextPositionManual, TextAnimationDropBounce, 1.0);
        m_UnlockOverlays[1]->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
        m_UnlockOverlays[1]->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
        m_UnlockOverlays[1]->SetOpacity(0.8);
        m_UnlockOverlays[1]->SetColour(1.0, 1.0, 1.0);
        m_UnlockOverlays[1]->SetPosition(FONT_SMALL_SPRITE_SIZE * 2, m_View->GetViewH() / 2);
      }
    }
    
    if (m_UnlockOverlays[0])
    {
      m_UnlockOverlays[0]->Render();
      m_UnlockOverlays[1]->Render();
      m_UnlockDisplayCount++;
      if (m_UnlockDisplayCount > ARENA_UNLOCK_DISPLAY_FRAMES)
      {
        m_UnlockOverlays[0]->RemoveAnimation(TextAnimationDropBounce);
        m_UnlockOverlays[1]->RemoveAnimation(TextAnimationDropBounce);
        m_UnlockOverlays[0]->AddAnimation(TextAnimationDropOff);
        m_UnlockOverlays[1]->AddAnimation(TextAnimationDropOff);
      }
      if (m_UnlockDisplayCount > ARENA_UNLOCK_DISPLAY_FRAMES + FRAMES_PER_SECOND * 2)
      {
        delete m_UnlockOverlays[0];
        m_UnlockOverlays[0] = NULL;
        delete m_UnlockOverlays[1];
        m_UnlockOverlays[1] = NULL;
      }
    }

    if (m_GameState == GameStateEnding)
    {
      m_StateVar++;
      if (m_StateVar > PAUSE_BEFORE_ACCEPT_INPUT)
      {
        m_GameState = GameStateEnded;
        GameEnded();
      }
    }
    
    if (m_TextOverlays[0])
      m_TextOverlays[0]->Render();
    if (m_TextOverlays[1])
      m_TextOverlays[1]->Render();
    if (m_RematchMenu)
      m_RematchMenu->Render();    
  }
}

void Game::RenderRadar()
{
  vector<IGameItem*>::iterator iter = m_GameItems.begin();
  GIFrog* frog;
  for (; iter != m_GameItems.end(); ++iter)
  {
    if ((*iter)->GetGameItemType() == GIFROG)
    {
      frog = dynamic_cast<GIFrog*>(*iter);
      bool pulse = FALSE;
      if (frog->GetFrogType() != FrogTypeNormal)
        pulse = TRUE;
      RenderRadarItem(frog->GetCoords(), FALSE, pulse);
    }
  }      
  RenderRadarItem(m_Opponent->GetCoords(), TRUE, FALSE);
  m_RadarState += RADAR_GLOW_INCREMENT;
  if (m_RadarState > 1.0)
    m_RadarState = 0.0;
}

void Game::RenderRadarItem(Coords c, bool IsSnake, bool Pulse)
{
  if (c.x < 0 || c.y < 0)
    return;
  
  Coords pc = m_Player->GetCoords();
  float curDist = pow(pc.x - c.x, 2);
  curDist += pow(pc.y - c.y, 2);
  curDist = sqrt(curDist);
  
  if (IsSnake)
  {
    if (curDist < SNAKE_RADAR_RADIUS + 20 && curDist > - (SNAKE_RADAR_RADIUS + 20))
      return;
  }
  else
  {
    if (curDist < SNAKE_RADAR_RADIUS && curDist > - SNAKE_RADAR_RADIUS)
      return;
  }
  
  float opp = (c.y - pc.y);
  float oh = opp / curDist;
  int angle = asin(oh) * 180 / PI;
  angle = (angle + 270);
  if (c.x > pc.x)
    angle = (360 - angle) % 360;
  
  if (IsSnake)
  {
    int x = pc.x + sin(angle * PI / 180) * (SNAKE_RADAR_RADIUS + 20);
    int y = pc.y + cos(angle * PI / 180) * (SNAKE_RADAR_RADIUS + 20);
    float g = 0.0;
    if (m_GameType == GameTypeMultiplayer && ! m_SessionManager->IsServer())
      g = 1.0;
    m_View->DrawSprite(GAME_SPRITE_SHEET, 3, 0, x, y, angle, 1.0, 0.6, 1.0, g, 0.0);
  }
  else
  {
    int x = pc.x + sin(angle * PI / 180) * SNAKE_RADAR_RADIUS;
    int y = pc.y + cos(angle * PI / 180) * SNAKE_RADAR_RADIUS;
    if (Pulse)
      m_View->DrawSprite(GAME_SPRITE_SHEET, 3, 0, x, y, angle, 1.0, 0.3, m_RadarState, m_RadarState, m_RadarState);
    else
      m_View->DrawSprite(GAME_SPRITE_SHEET, 3, 0, x, y, angle, 1.0, 0.3, 0.0, 0.0, 0.0);
  }
}

void Game::RenderControls()
{
  if (m_ControlsOpacity <= 0)
    return;
  
  if (m_GameType == GameTypeLocalMultiplayer)
  {
    m_View->DrawSprite(CONTROLS_SPRITE_SHEET, 0, 0, 0, 0, 360 - m_ControlsRotation, 1.0, m_ControlsOpacity);
    m_View->DrawSprite(CONTROLS_SPRITE_SHEET, 1, 0, m_View->GetViewW() - CONTROLS_SPRITE_SIZE, 0, m_ControlsRotation, 1.0, m_ControlsOpacity);
    m_View->DrawSprite(CONTROLS_SPRITE_SHEET, 1, 0, 0, m_View->GetViewH() - CONTROLS_SPRITE_SIZE, m_ControlsRotation, 1.0, m_ControlsOpacity);
    m_View->DrawSprite(CONTROLS_SPRITE_SHEET, 0, 0, m_View->GetViewW() - CONTROLS_SPRITE_SIZE, m_View->GetViewH() - CONTROLS_SPRITE_SIZE, 360 - m_ControlsRotation, 1.0, m_ControlsOpacity);
  }
  else
  {
    m_View->DrawSprite(CONTROLS_SPRITE_SHEET, 1, 0, 0, 0, m_ControlsRotation, 1.0, m_ControlsOpacity);
    m_View->DrawSprite(CONTROLS_SPRITE_SHEET, 0, 0, 0, m_View->GetViewH() - CONTROLS_SPRITE_SIZE, 360 - m_ControlsRotation, 1.0, m_ControlsOpacity);
  }
  
  m_ControlsRotation += 5;
  m_ControlsRotation = m_ControlsRotation % 360;
  m_ControlsDisplayFrames--;
  if (m_ControlsDisplayFrames < 0)
    m_ControlsOpacity -= 0.01;
}

void Game::SendData()
{
  char *data;
  int len;
  bool reliable = FALSE;

  if (m_SessionManager->IsServer())
  {
    BuildStateData(data, len);
  }
  else 
  {
    data = (char*) malloc(2);
    len = 2;
    data[0] = PACKET_USER_INPUT;
    data[1] = m_TouchState;
  }
  
  m_SessionManager->SendData(data, len, reliable);
  
  free(data);
}
 
void Game::BuildStateData(char*& data, int& len)
{
  int size = 1; // 1 for the packet id byte
  vector<IGameItem*>::iterator iter = m_GameItems.begin();
  for (; iter != m_GameItems.end(); ++iter)
  {
    IStateReporter* stateItem = dynamic_cast<IStateReporter*> (*iter);
    if (stateItem)
      size += 1 + stateItem->GetStateDataSize(); // + 1 for the prepended item type identifier
  }
  data = (char*) malloc(size);
  len = size;
  
  data[0] = PACKET_GAME_STATE;
  int pos = 1;
  iter = m_GameItems.begin();
  for (; iter != m_GameItems.end(); ++iter)
  {
    IStateReporter* stateItem = dynamic_cast<IStateReporter*> (*iter);
    if (stateItem)
    {
      data[pos] = (char) (*iter)->GetGameItemType();
      pos++;
      stateItem->GetStateData(data + pos);
      pos += stateItem->GetStateDataSize();
    }
  }
}
               
void Game::ReadData(char* data, int len)
{
  if (m_GameState == GameStateWaitingForSync)
    m_GameState = GameStateStarting;
  switch (data[0])
  {
    case PACKET_USER_INPUT:
      m_OpponentTouchState = data[1];
      break;
    case PACKET_GAME_STATE:
      ReadStateData(data, len);
      break;
    case PACKET_GAME_HIGH_LEVEL_STATE:
      ReadHighLevelStateData(data, len);
      break;
    case PACKET_ARENA_NUMBER:
      {
        m_BoardNo = data[1];
        m_Board = BoardBuilder::GetBoard(m_BoardNo);
      }
      break;
  }
}

void Game::ReadHighLevelStateData(char* data, int len)
{
  switch (data[1])
  { 
    // 0 - Snake death state
    case 0:
      m_Player->SetSnakeState((SnakeState) data[3]);
      m_Opponent->SetSnakeState((SnakeState) data[2]);
      SnakeCollided();
      break;
    case 1:
      GameEnding();
      int pos = 2;
      memcpy(&m_OpponentScore, data + pos, sizeof(int));
      pos += sizeof(int);
      memcpy(&m_OpponentWins, data + pos, sizeof(int));
      pos += sizeof(int);
      memcpy(&m_PlayerScore, data + pos, sizeof(int));
      pos += sizeof(int);
      memcpy(&m_PlayerWins, data + pos, sizeof(int));
      break;
  }
}

void Game::ReadStateData(char* data, int len)
{
  // WARNING: This curently assumes both vectors (client and server) will be in sync order-wise
  // (which they will). This will need revisiting if we start deleting and adding
  // items during gameplay.
  int pos = 1; // Skip packet ID byte
  vector<IGameItem*>::iterator iter = m_GameItems.begin();
  for (; iter != m_GameItems.end(); ++iter)
  {
    IStateReporter* reporter = dynamic_cast<IStateReporter*> (*iter);
    if (reporter)
    {
      pos++; // Skip game item ID byte
      reporter->PutStateData(data + pos);
      pos += reporter->GetStateDataSize();
    }
  }
}

void Game::RenderHUD(BOOL isPlayer)
{
  m_View->SetViewArea(0, 0, m_View->GetViewW(), m_View->GetViewH());

  stringstream ss;
  if (m_GameType == GameTypeLocalMultiplayer)
  {
    if (isPlayer)
      ss << "^" << m_PlayerWins << STR_SCORE_SEPARATOR << m_OpponentWins << "*";
    else 
      ss << "*" << m_OpponentWins << STR_SCORE_SEPARATOR << m_PlayerWins << "^";
  }
  else if (m_GameType == GameTypeMultiplayer)
  {
    if (m_SessionManager->IsServer())
      ss << "*" << m_PlayerWins << STR_SCORE_SEPARATOR << m_OpponentWins << "^  ";
    else
      ss << "^" << m_PlayerWins << STR_SCORE_SEPARATOR << m_OpponentWins << "*  ";
  }

  if (m_GameType == GameTypeSinglePlayer)
  {
    int idx = isPlayer ? 0 : 1;
    int score = isPlayer ? m_Player->GetScore() : m_Opponent->GetScore();
    if (m_DisplayScores[idx] < score)
      m_DisplayScores[idx]++;
    ss << STR_SCORE << " ";
    ss << m_DisplayScores[idx];
    ss << "  ";
  }
  
  string str = ss.str();
  
  int x, y, xinc = 0, yinc = 0, orientation = 90;
  
  if (m_GameType == GameTypeSinglePlayer || m_GameType == GameTypeMultiplayer)
  {
    x = m_View->GetViewW() - FONT_SMALL_SPRITE_SIZE - 1;
    y = (FONT_SMALL_SPRITE_SIZE + 1) * str.length();
    yinc = -FONT_SMALL_SPRITE_SIZE - 1;
  }
  else
  {
    x = m_View->GetViewW() / 2 - str.length() * (FONT_SMALL_SPRITE_SIZE + 1) / 2;
    y = 0;
    xinc = FONT_SMALL_SPRITE_SIZE + 1;
    orientation = 0;
    if (! isPlayer)
    {
      x = m_View->GetViewW() / 2 + str.length() * (FONT_SMALL_SPRITE_SIZE + 1) / 2 - FONT_SMALL_SPRITE_SIZE;
      y = m_View->GetViewH() - FONT_SMALL_SPRITE_SIZE;
      xinc = -xinc;
      orientation = 180;
    }
  }
  
  Coords c;
  for (int i = 0; i < str.length(); i++)
  {
    c = Utils::CharToSpriteCoords(str[i]);
    switch (str[i])
    {
      case '^':
        m_View->DrawSprite(FONT_SMALL_SPRITE_SHEET, c.x, c.y, x, y, orientation, 1.0, 0.8);
        break;
      case '*':
        m_View->DrawSprite(FONT_SMALL_SPRITE_SHEET, c.x, c.y, x, y, orientation, 1.0, 0.8);
        break;
      default:
        m_View->DrawSprite(FONT_SMALL_SPRITE_SHEET, c.x, c.y, x, y, orientation, 1.0, 0.6, 0.0, 0.0, 0.0);
        break;
    }
    x += xinc;
    y += yinc;
  }
}

void Game::GameEnded()
{
  if (m_GameType == GameTypeLocalMultiplayer || m_GameType == GameTypeMultiplayer)
  {
    for (int i = 0; i < 2; i++)
    {
      if (m_TextOverlays[i])
      {
        delete m_TextOverlays[i];
        m_TextOverlays[i] = NULL;
      }
    }
    m_GameState = GameStateAskRematch;
    BOOL isServer = TRUE;
    if (m_SessionManager)
      isServer = m_SessionManager->IsServer();
    m_RematchMenu = new RematchMenu(m_View, m_PlayerWins, m_OpponentWins, isServer, this, m_SessionManager, m_GameType == GameTypeLocalMultiplayer);
  }
}

void Game::TouchEvent(TouchInfo touches[], int count)
{
  // If menu is being shown, nothing else should receive the touches
  if (m_RematchMenu)
  {
    m_RematchMenu->TouchEvent(touches, count);
    return;
  }
  
  // Check for pause
  if (m_GameType == GameTypeSinglePlayer)
  {
    if (touches[0].x > m_View->GetViewW() - FONT_SMALL_SPRITE_SIZE * 2
        && touches[0].y < FONT_SMALL_SPRITE_SIZE * 2)
    {
      m_Controller->EventRaised(EVENT_1P_PAUSED, this);
      return;
    }
  }
  
  if (m_GameState == GameStateEnded)
  {
    if (count > 0)
    {
      if (touches[0].phase == Ended)
      {
        if (m_GameType == GameTypeSinglePlayer && m_Controller)
          m_Controller->EventRaised(EVENT_GAME_OVER, this);
      }
    }
  }
  else 
  {
    // Get the most recent touch and adjust player's snake accordingly
    m_TouchState = None;
    TouchInfo *touch;

    if (count > 0)
    {
      if (m_GameType != GameTypeLocalMultiplayer)
      {
        touch = GetMostRecentTouchInArea(touches, count, 0, 0, m_View->GetViewW(), m_View->GetViewH());
        if (touch)
        {
          if (touch->y < m_View->GetViewH() / 2)
            m_TouchState |= P1Left;
          else 
            m_TouchState |= P1Right;
        }
      }
      else 
      {
        touch = GetMostRecentTouchInArea(touches, count, 0, 0, m_View->GetViewW(), m_View->GetViewH() / 2);
        if (touch)
        {
          if (touch->x < m_View->GetViewW() / 2)
            m_TouchState |= P2Right;
          else 
            m_TouchState |= P2Left;
        }

        touch = GetMostRecentTouchInArea(touches, count, 0, m_View->GetViewH() / 2, m_View->GetViewW(), m_View->GetViewH() / 2);
        if (touch)
        {
          if (touch->x < m_View->GetViewW() / 2)
            m_TouchState |= P1Left;
          else 
            m_TouchState |= P1Right;
        }
      }
    }
  }
}

TouchInfo* Game::GetMostRecentTouchInArea(TouchInfo touches[], int count, int x, int y, int w, int h)
{
  TouchInfo* info = NULL;
  
  TouchPhase phase = Ended;
  for (int i = 0; i < count; i++)
    if (touches[i].phase < phase && 
        touches[i].x >= x && touches[i].x < x + w &&
        touches[i].y >= y && touches[i].y < y + h)
      info = &touches[i];
  
  return info;
}

void Game::EventRaised(int eventType, void* raiser)
{
  switch (eventType)
  {
    case EVENT_DATA_RECEIVED:
      if (m_RematchMenu)
        m_RematchMenu->EventRaised(eventType, raiser);
      int len;
      void* data;
      m_SessionManager->GetData(data, len);
      ReadData((char*) data, len);
      break;
    case EVENT_TEXT_ANIMATE_DONE:
      if (m_GameState == GameStateStarting)
      {
        m_StateVar++;
        if (m_StateVar == 1)
        {
          ShowPlayerText(STR_GO);
        }
        else
        {
          delete m_TextOverlays[0];
          m_TextOverlays[0] = NULL;
          if (m_TextOverlays[1])
          {
            delete m_TextOverlays[1];
            m_TextOverlays[1] = NULL;
          }
          m_GameState = GameStatePlaying;
          m_Player->SetPaused(FALSE);
          m_Opponent->SetPaused(FALSE);
        }
      }
      break;
    case EVENT_MENU_SELECTED:
      if (m_Controller)
        m_Controller->EventRaised(EVENT_GAME_OVER, this);
      break;
    case EVENT_REPLAY_SELECTED:
      delete m_RematchMenu;
      m_RematchMenu = NULL;
      m_Player->GetStats(m_PlayerScore, m_PlayerWins);
      m_Opponent->GetStats(m_OpponentScore, m_OpponentWins);
      // TODO: Set display scores so it doesn't count up at start of new round
      m_DisplayScores[0] = m_Player->GetScore();
      m_DisplayScores[1] = m_Opponent->GetScore();
      CleanUpClass();
      InitClass();
      Initialise(m_BoardNo);
      break;
    case EVENT_FROG_NOMMED:
      if (m_GameType != GameTypeDemo)
      {
        if (m_GameType == GameTypeLocalMultiplayer)
          ALManager::Instance()->PlaySound(SOUND_CHOMP_2);
        else
        {
          if (raiser == m_Player)
            ALManager::Instance()->PlaySound(SOUND_CHOMP_2);
          else
            ALManager::Instance()->PlaySound(SOUND_CHOMP_1);
        }
      }
      break;
  }
  
  if (m_GameType == GameTypeMultiplayer && ! m_SessionManager->IsServer())
    return;
  
  switch (eventType)
  {
    case EVENT_SNAKE_DYING:
      if (m_GameType != GameTypeDemo)
      {
        ALManager::Instance()->PlaySound(SOUND_COLLIDE_1);
        m_GameState = GameStateSnakeDied;
      }
      break;
    case EVENT_SNAKE_DEAD:
      {
        GISnake* snake = (GISnake*) raiser;
        int player = 1;
        if ((snake != m_Player && m_GameType == GameTypeSinglePlayer) || m_GameType == GameTypeDemo)
        {
          if (snake == m_Player)
            player = 0;
          vector<IGameItem*>::iterator iter = m_GameItems.begin();
          
          for (; iter != m_GameItems.end(); ++iter)
          {
            if (*iter == snake)
            {
              break;
            }
          }
          if (iter != m_GameItems.end())
          {
            delete *iter;
            m_GameItems.erase(iter);
          }
          
          int sx = m_Board.width - 84;
          int sy = m_Board.height - 84;
          int sd = 180;
          if (player == 0)
          {
            sx = 64;
            sy = 64;
          }
          
          if (m_GameType == GameTypeSinglePlayer && player == 1)
          {
            // Make snake spawn in corner furthest away from player
            Coords pcoords = m_Player->GetCoords();
            if (pcoords.x > m_Board.width / 2)
              sx = 64;
            if (pcoords.y > m_Board.height / 2)
            {
              sy = 64;
              sd = 0;
            }
          }
          
          GISnake* enemy = new GISnake(sx, sy, sd, 2, player, m_Board.width, m_Board.height, TRUE);
          enemy->SetWaypoints(m_Board.waypoints);
          if (player == 0)
            m_Player = enemy;
          else
            m_Opponent = enemy;
          enemy->SetController(this);
          m_GameItems.push_back(enemy);
        }
        else
        {
          if (m_Opponent->GetSnakeState() != SnakeStateDying && m_Opponent->GetSnakeState() != SnakeStateDead)
            m_Opponent->SetSnakeState(SnakeStateCelebrating);
          m_Opponent->SetPaused(TRUE);
          GameEnding();
        }
      }
      break;
  }
}

void Game::SnakeCollided()
{
  if (m_GameType == GameTypeLocalMultiplayer)
  {
    string msg1;
    string msg2;
    
    if (m_Player->GetSnakeState() == SnakeStateDying && m_Opponent->GetSnakeState() == SnakeStateDying)
    {
      msg1 = STR_ITS_A_TIE;
      msg2 = STR_ITS_A_TIE;
    }
    else if (m_Player->GetSnakeState() != SnakeStateDying)
    {
      msg1 = STR_YOU_WIN;
      msg2 = STR_YOU_LOSE;
      m_Player->AddWin();
      if (! m_Opponent->GetDidSuicide())
        m_Player->AddScore(m_Opponent->GetSnakeLength() * SNAKE_SEGMENT_SCORE);
      m_Player->SetSnakeState(SnakeStateCelebrating);
    }
    else if (m_Player->GetSnakeState() == SnakeStateDying)
    {
      msg1 = STR_YOU_LOSE;
      msg2 = STR_YOU_WIN;
      m_Opponent->AddWin();
      if (! m_Player->GetDidSuicide())
        m_Opponent->AddScore(m_Player->GetSnakeLength() * SNAKE_SEGMENT_SCORE);
      m_Opponent->SetSnakeState(SnakeStateCelebrating);
    }
    
    m_TextOverlays[0] = new TextRenderer(m_View, msg1, TextPositionManual, TextAnimationSplat, m_GameTextScale);
    m_TextOverlays[0]->SetController(this);
    m_TextOverlays[0]->SetPosition(m_View->GetViewW() / 2, m_View->GetViewH() / 4);
    m_TextOverlays[0]->SetOrientation(TextOrientation90);
    m_TextOverlays[0]->SetCharSpacing(0.8);

    m_TextOverlays[1] = new TextRenderer(m_View, msg2, TextPositionManual, TextAnimationSplat, m_GameTextScale);
    m_TextOverlays[1]->SetPosition(m_View->GetViewW() / 2, (m_View->GetViewH() / 4) * 3);
    m_TextOverlays[1]->SetOrientation(TextOrientation270);
    m_TextOverlays[1]->SetCharSpacing(0.8);
    
    m_Opponent->SetPaused(TRUE);
    m_Player->SetPaused(TRUE);
  }
  else if (m_GameType == GameTypeMultiplayer)
  {
    string msg;
    if (m_Player->GetSnakeState() == SnakeStateDying && m_Opponent->GetSnakeState() == SnakeStateDying)
    {
      msg = STR_ITS_A_TIE;
    }
    else if (m_Player->GetSnakeState() != SnakeStateDying)
    {
      msg = STR_YOU_WIN;
      m_Player->AddWin();
      if (! m_Opponent->GetDidSuicide())
        m_Player->AddScore(m_Opponent->GetSnakeLength() * SNAKE_SEGMENT_SCORE);
      m_Player->SetSnakeState(SnakeStateCelebrating);
    }
    else if (m_Player->GetSnakeState() == SnakeStateDying)
    {
      msg = STR_YOU_LOSE;
      m_Opponent->AddWin();
      if (! m_Player->GetDidSuicide())
        m_Opponent->AddScore(m_Player->GetSnakeLength() * SNAKE_SEGMENT_SCORE);
      m_Opponent->SetSnakeState(SnakeStateCelebrating);
    }
    
    m_TextOverlays[0] = new TextRenderer(m_View, msg, TextPositionCentreScreen, TextAnimationSplat, m_GameTextScale);
    m_TextOverlays[0]->SetController(this);
    m_TextOverlays[0]->SetCharSpacing(0.8);
    m_Opponent->SetPaused(TRUE);
    m_Player->SetPaused(TRUE);
    
    if (! m_SessionManager)
      return;
    if (! m_SessionManager->IsServer())
      return;
    
    char data[4];
    data[0] = PACKET_GAME_HIGH_LEVEL_STATE;
    data[1] = 0; // 0 - Snake death state
    data[2] = (char) m_Player->GetSnakeState();
    data[3] = (char) m_Opponent->GetSnakeState();

    m_SessionManager->SendData(data, 4, TRUE);
  }
  else 
  {
    if (m_Player->GetSnakeState() == SnakeStateDying)
    {
      m_TextOverlays[0] = new TextRenderer(m_View, STR_GAME_OVER, TextPositionCentreScreen, TextAnimationSplat, m_GameTextScale);
      m_TextOverlays[0]->SetCharSpacing(0.8);
    }
    else
    {
      if (! m_Opponent->GetDidSuicide())
      {
        m_Player->AddWin();
        m_Player->AddScore(m_Opponent->GetSnakeLength() * SNAKE_SEGMENT_SCORE);
      }
    }
  }
}

void Game::GameEnding()
{
  m_GameState = GameStateEnding;
  m_StateVar = 0;
  m_Player->GetStats(m_PlayerScore, m_PlayerWins);
  m_Opponent->GetStats(m_OpponentScore, m_OpponentWins);

  if (! m_SessionManager)
    return;
  if (! m_SessionManager->IsServer())
    return;

  char* data = (char*) malloc(2 + 4 * sizeof(int));
  data[0] = PACKET_GAME_HIGH_LEVEL_STATE;
  data[1] = 1; // 0 - Snake dying, 1 - Snake dead
  int pos = 2;
  memcpy(data + pos, &m_PlayerScore, sizeof(int));
  pos += sizeof(int);
  memcpy(data + pos, &m_PlayerWins, sizeof(int));
  pos += sizeof(int);
  memcpy(data + pos, &m_OpponentScore, sizeof(int));
  pos += sizeof(int);
  memcpy(data + pos, &m_OpponentWins, sizeof(int));
  
  m_SessionManager->SendData(data, 2 + 4 * sizeof(int), TRUE);

  free(data);
}

void Game::ShowPlayerText(string text)
{
  for (int i = 0; i < 2; i++)
  {
    if (m_TextOverlays[i])
    {
      delete m_TextOverlays[i];
      m_TextOverlays[i] = NULL;
    }
  }
  
  if (m_GameType == GameTypeLocalMultiplayer)
  {
    m_TextOverlays[0] = new TextRenderer(m_View, text, TextPositionManual, TextAnimationZoomFade, m_GameTextScale);
    m_TextOverlays[0]->SetController(this);
    m_TextOverlays[0]->SetPosition(m_View->GetViewW() / 2, m_View->GetViewH() / 4);
    m_TextOverlays[0]->SetOrientation(TextOrientation90);
    m_TextOverlays[0]->SetCharSpacing(0.8);
    m_TextOverlays[1] = new TextRenderer(m_View, text, TextPositionManual, TextAnimationZoomFade, m_GameTextScale);
    m_TextOverlays[1]->SetPosition(m_View->GetViewW() / 2, (m_View->GetViewH() / 4) * 3);
    m_TextOverlays[1]->SetOrientation(TextOrientation270);
    m_TextOverlays[1]->SetCharSpacing(0.8);
  }
  else
  {
    m_TextOverlays[0] = new TextRenderer(m_View, text, TextPositionCentreScreen, TextAnimationZoomFade, m_GameTextScale);
    m_TextOverlays[0]->SetController(this);
    m_TextOverlays[0]->SetCharSpacing(0.8);
    if (Utils::IsiPad())
    {
      m_TextOverlays[0]->SetColour(1.0, 1.0, 0.0);
      if (m_GameType == GameTypeMultiplayer && m_SessionManager->IsServer())
        m_TextOverlays[0]->SetColour(1.0, 0.0, 0.0);
    }
  }
}

void Game::SetController(IGenericEvent* controller)
{
  m_Controller = controller;
}

void Game::SetUnlockedBoards(int unlockedBoards)
{
  m_UnlockedBoards = unlockedBoards;
  if (m_BoardNo < m_UnlockedBoards - 1)
    m_UnlockNotified = TRUE;
}

void Game::SetSessionManager(ISessionManager* manager)
{
  m_SessionManager = manager;
}

void Game::GotNames()
{
  m_GameState = GameStateStarting;
  ShowPlayerText(STR_READY);
}

void Game::CleanUpClass()
{
  if (m_TextOverlays[0])
  {
    delete m_TextOverlays[0];
    m_TextOverlays[0] = NULL;
  }
  if (m_TextOverlays[1])
  {
    delete m_TextOverlays[1];
    m_TextOverlays[1] = NULL;
  }
  if (m_UnlockOverlays[0])
  {
    delete m_UnlockOverlays[0];
    m_UnlockOverlays[0] = NULL;
  }
  if (m_UnlockOverlays[1])
  {
    delete m_UnlockOverlays[1];
    m_UnlockOverlays[1] = NULL;
  }
  
  if (m_RematchMenu)
  {
    delete m_RematchMenu;
    m_RematchMenu = NULL;
  }
  
  vector<IGameItem*>::iterator iter = m_GameItems.begin();
  
  for (; iter != m_GameItems.end(); ++iter)
    delete (*iter);
  
  m_GameItems.clear();
}

GameType Game::GetGameType()
{
  return m_GameType;
}

int Game::GetPlayerScore()
{
  return m_PlayerScore;
}

int Game::GetOpponentScore()
{
  return m_OpponentScore;
}

int Game::GetPlayerWins()
{
  return m_PlayerWins;
}

int Game::GetOpponentWins()
{
  return m_OpponentWins;
}

BOOL Game::GetDidOpponentQuit()
{
  if (m_RematchMenu)
    return m_RematchMenu->GetOpponentAnswer() == 0;
  else
    return FALSE;;
}

int Game::GetBackgroundNo()
{
  return m_BackgroundNo;
}

Game::~Game()
{
  CleanUpClass();
}

