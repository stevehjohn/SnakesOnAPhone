/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <string>

#import "IGLViewConsumer.h"
#import "ITouchReceiver.h"
#import "IGenericEvent.h"
#import "ISessionManager.h"
#import "TextRenderer.h"
#import "IGenericEvent.h"
#import "TouchableTextRenderer.h"

class RematchMenu : public IGLViewConsumer, public ITouchReceiver, public IGenericEvent
{
private:
  IGenericEvent* m_Controller;
  int m_PlayerWins;
  int m_OpponentWins;
  bool m_PlayerIsServer;
  ISessionManager* m_Session;
  bool m_IsLocal;
  vector<IGLViewConsumer*> m_Items[2];
  TouchableTextRenderer* m_ReplayButton[2];
  TouchableTextRenderer* m_MenuButton[2];
  int m_PlayerAnswer; // -1 no response yet, 0 no rematch, 1 yes please
  int m_OpponentAnswer; // -1 no response yet, 0 no rematch, 1 yes please
  bool m_Quitting;
  int m_PauseCount;
  int m_NewTextTarget;
  string m_NewText;
  bool m_ClearBoth;
  int m_NewEvent;
  
  void InitMenu();
  void AddMenuItems(Coords centre, float scale, TextOrientation orientation, int score1, int score2, int idx);
  void ReadData();
  void ClearItems(int idx);
  Coords GetCoordsForOrientation(Coords centre, int x, int y, TextOrientation orientation);
  
public:
  RematchMenu(GL2DView* view, int playerWins, int opponentWins, bool playerIsServer, IGenericEvent* controller, ISessionManager* session, bool isLocal);
  ~RematchMenu();  

  void Render();
  
  void TouchEvent(TouchInfo touches[], int count);
  
  void EventRaised(int eventType, void* raiser);
  
  int GetOpponentAnswer();
};