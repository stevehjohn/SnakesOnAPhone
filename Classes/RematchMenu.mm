/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <sstream>

#import "RematchMenu.h"
#import "Utils.h"
#import "Constants.h"
#import "TouchableTextRenderer.h"

RematchMenu::RematchMenu(GL2DView* view, int playerWins, int opponentWins, bool playerIsServer, IGenericEvent* controller, ISessionManager* session, bool isLocal)
  : IGLViewConsumer(view)
{
  m_Controller = controller;
  m_PlayerWins = playerWins;
  m_OpponentWins = opponentWins;
  m_PlayerIsServer = playerIsServer;
  m_Session = session;
  m_IsLocal = isLocal;
  m_NewEvent = NULL;
  
  m_PlayerAnswer = -1;
  m_OpponentAnswer = -1;
  m_Quitting = FALSE;
  m_PauseCount = 0;
  m_NewText = "";
  m_NewEvent = NULL;
  m_ClearBoth = FALSE;
  m_NewTextTarget = 0;
  
  InitMenu();
}

RematchMenu::~RematchMenu()
{
  ClearItems(0);
  ClearItems(1);
}

void RematchMenu::ClearItems(int idx)
{
  vector<IGLViewConsumer*>::iterator iter = m_Items[idx].begin();
  
  for (; iter != m_Items[idx].end(); ++iter)
  {
    delete (*iter);
  }
  m_Items[idx].clear();
}

void RematchMenu::InitMenu()
{
  bool ipad = Utils::IsiPad();
  Coords c;
  
  if (! m_IsLocal)
  {
    c.x = 160;
    c.y = 240;
    int scale = 1;
    if (ipad)
    {
      scale = 2;
      c.x = 384;
      c.y = 512;
    }
    AddMenuItems(c, scale, TextOrientationHorizontal, m_PlayerWins, m_OpponentWins, 0);
  }
  else 
  {
    c.x = 384;
    c.y = 256;
    AddMenuItems(c, 1, TextOrientation90, m_PlayerWins, m_OpponentWins, 0);    
    c.x = 384;
    c.y = 768;
    AddMenuItems(c, 1, TextOrientation270, m_OpponentWins, m_PlayerWins, 1);    
  }

}

void RematchMenu::AddMenuItems(Coords centre, float scale, TextOrientation orientation, int score1, int score2, int idx)
{
  string str;
  if (score1 > score2)
    str = STR_WINNING;
  else if (score1 < score2)
    str = STR_LOSING;
  else
    str = STR_ITS_A_TIE;

  TextRenderer* text = new TextRenderer(m_View, str, TextPositionManual, TextAnimationSplat, 1.0);
  if (scale == 1)
  {
    text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
  }
  text->SetPosition(GetCoordsForOrientation(centre, 100 * scale, 0, orientation));
  text->SetOrientation(orientation);
  m_Items[idx].push_back(text);
  
  stringstream ss;
  if ((orientation == TextOrientation270 && m_IsLocal) || (m_PlayerIsServer && ! m_IsLocal))
    ss << "*" << score1 << STR_SCORE_SEPARATOR << score2 << "^";
  else
    ss << "^" << score1 << STR_SCORE_SEPARATOR << score2 << "*";
  text = new TextRenderer(m_View, ss.str(), TextPositionManual, TextAnimationSplat, 1.0);
  if (scale == 1)
  {
    text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
  }
  text->SetPosition(GetCoordsForOrientation(centre, 50 * scale, 0, orientation));
  text->SetOrientation(orientation);
  m_Items[idx].push_back(text);

  TouchableTextRenderer* touchText;
  if (scale == 1)
  {
    touchText = new TouchableTextRenderer(m_View, STR_PLAY_AGAIN, TextPositionManual, TextAnimationSplat, 1.0);
    touchText->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    touchText->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
  }
  else
  {
    touchText = new TouchableTextRenderer(m_View, STR_PLAY_AGAIN, TextPositionManual, TextAnimationSplat, 0.5);
  }
  touchText->SetPosition(GetCoordsForOrientation(centre, -25 * scale, 0, orientation));
  touchText->SetController(this);
  touchText->SetOrientation(orientation);
  m_Items[idx].push_back(touchText);
  m_ReplayButton[idx] = touchText;

  if (scale == 1)
  {
    touchText = new TouchableTextRenderer(m_View, STR_MAIN_MENU, TextPositionManual, TextAnimationSplat, 1.0);
    touchText->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
    touchText->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
  }
  else
  {
    touchText = new TouchableTextRenderer(m_View, STR_MAIN_MENU, TextPositionManual, TextAnimationSplat, 0.5);
  }
  touchText->SetPosition(GetCoordsForOrientation(centre, -100 * scale, 0, orientation));
  touchText->SetController(this);
  touchText->SetOrientation(orientation);
  m_Items[idx].push_back(touchText);
  m_MenuButton[idx] = touchText;
}

Coords RematchMenu::GetCoordsForOrientation(Coords centre, int x, int y, TextOrientation orientation)
{
  Coords c = centre;

  switch (orientation) 
  {
    case TextOrientation90:
      c.x += y;
      c.y += x;
      break;
    case TextOrientation270:
      c.x += y;
      c.y -= x;
      break;
    default:
      c.x += x;
      c.y += y;
      break;
  }
  
  return c;
}

void RematchMenu::EventRaised(int eventType, void* raiser)
{
  if (eventType == EVENT_TEXT_TOUCHED)
  {
    if (! m_IsLocal)
    {
      if (raiser == m_ReplayButton[0])
      {
        m_PlayerAnswer = 1;
        
        if (m_OpponentAnswer == -1)
        {
          char data[2];
          data[0] = PACKET_REMATCH_ACCEPT;
          data[1] = TRUE;
          m_Session->SendData((void*) data, 2, TRUE);
          
          m_NewTextTarget = 0;
          m_NewText = STR_WAITING_ANSWER;
        }
        else if (m_OpponentAnswer == 1)
        {
          m_NewEvent = EVENT_REPLAY_SELECTED;
          
          char data[2];
          data[0] = PACKET_REMATCH_ACCEPT;
          data[1] = TRUE;
          m_Session->SendData((void*) data, 2, TRUE);
        }
      } 
      else if (raiser == m_MenuButton[0])
      {
        char data[2];
        data[0] = PACKET_REMATCH_ACCEPT;
        data[1] = FALSE;
        m_Session->SendData((void*) data, 2, TRUE);
        m_NewEvent = EVENT_MENU_SELECTED;
      }
    }
    else 
    {
      if (raiser == m_ReplayButton[0] || raiser == m_ReplayButton[1])
      {
        int idx = (raiser == m_ReplayButton[0] ? 0 : 1);
        if (idx == 1)
          m_OpponentAnswer = 1;
        else
          m_PlayerAnswer = 1;
        if (m_OpponentAnswer == 1 && m_PlayerAnswer == 1)
          m_NewEvent = EVENT_REPLAY_SELECTED;
        else
        {
          m_NewTextTarget = idx;
          m_NewText = STR_WAITING_ANSWER;
        }
      }
      else if (raiser == m_MenuButton[0] || raiser == m_MenuButton[1])
      {
        int idx = (raiser == m_MenuButton[0] ? 0 : 1);
        if (idx == 1)
          m_OpponentAnswer = 0;
        else
          m_PlayerAnswer = 0;
        m_NewTextTarget = 1 - idx;
        m_ClearBoth = TRUE;
        m_NewText = STR_OPPONENT_CHICKEN;
        m_Quitting = TRUE;
        m_PauseCount = 0;
      }
    }
  }
  else if (eventType == EVENT_DATA_RECEIVED)
  {
    ReadData();
  }
}

int RematchMenu::GetOpponentAnswer()
{
  return m_OpponentAnswer;
}

void RematchMenu::ReadData()
{
  void* pdata;
  int len;
  m_Session->GetData(pdata, len);
  
  char* data = (char*) pdata;
  
  if (data[0] == PACKET_REMATCH_ACCEPT)
  {
    m_OpponentAnswer = data[1];
    
    if (! data[1])
    {
      m_Quitting = TRUE;
      m_PauseCount = 0;
      ClearItems(0);
      
      TextRenderer* text = new TextRenderer(m_View, STR_OPPONENT_CHICKEN, TextPositionCentreScreen, TextAnimationSplat, 1.0);
      if (! Utils::IsiPad())
      {
        text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
        text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
      }
      m_Items[0].push_back(text);
    }
    else 
    {
      if (m_PlayerAnswer == 1)
        m_Controller->EventRaised(EVENT_REPLAY_SELECTED, this);
    }
  }
}

void RematchMenu::Render()
{
  if (m_Quitting)
  {
    m_PauseCount++;
    if (m_PauseCount >= PAUSE_BEFORE_ACCEPT_INPUT)
      m_PauseCount = PAUSE_BEFORE_ACCEPT_INPUT;
  }
  
  m_View->SetViewArea(0, 0, m_View->GetViewW(), m_View->GetViewH());
  
  for (int i = 0; i < 2; i++)
  {
    vector<IGLViewConsumer*>::iterator iter = m_Items[i].begin();
    for (; iter != m_Items[i].end(); ++iter)
    {
      (*iter)->Render();
    }
  }
  
  if (m_NewText.length() > 0)
  {
    ClearItems(m_NewTextTarget);
    if (m_ClearBoth)
      ClearItems(1 - m_NewTextTarget);
    
    TextRenderer* text;
    if (! m_IsLocal)
    {
      if (Utils::IsiPad())
      {
        text = new TextRenderer(m_View, m_NewText, TextPositionCentreScreen, TextAnimationSplat, 1.0);
        text->SetCharSpacing(0.75);
      }
      else
      {
        text = new TextRenderer(m_View, m_NewText, TextPositionCentreScreen, TextAnimationSplat, 1.0);
        text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
        text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
      }
    }
    else
    {
      text = new TextRenderer(m_View, m_NewText, TextPositionManual, TextAnimationSplat, 1.0);
      text->SetFontSheet(FONT_SMALL_SPRITE_SHEET);
      text->SetFontSpriteSize(FONT_SMALL_SPRITE_SIZE);
      if (m_NewTextTarget == 0)
      {
        text->SetPosition(384, 256);
        text->SetOrientation(TextOrientation90);
      }
      else
      {
        text->SetPosition(384, 768);
        text->SetOrientation(TextOrientation270);
      }
    }
    m_Items[0].push_back(text);
    m_NewText.clear();
    m_NewTextTarget = 0;
  }
  
  // This is a bit of a hack because events get raised during rendering,
  // and they can cause it to crap out.
  // Maybe revisit even though this works. Certainly implement a better model in next project
  if (m_NewEvent)
  {
    m_Controller->EventRaised(m_NewEvent, this);
    m_NewEvent = NULL;
  }
}

void RematchMenu::TouchEvent(TouchInfo touches[], int count)
{
  if (m_Quitting)
  {
    if (m_PauseCount >= PAUSE_BEFORE_ACCEPT_INPUT)
    {
      if (count > 0)
      {
        if (touches[0].phase == Ended)
          m_Controller->EventRaised(EVENT_MENU_SELECTED, this);
      }
    }
    return;
  }
  
  for (int i = 0; i < 2; i++)
  {
    vector<IGLViewConsumer*>::iterator iter = m_Items[i].begin();
    for (; iter != m_Items[i].end(); ++iter)
    {
      ITouchReceiver* receiver = dynamic_cast<ITouchReceiver*> (*iter);
      if (receiver)
        receiver->TouchEvent(touches, count);
    }
  }
}
