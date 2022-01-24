/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "BJSessionManager.h"
#import "Constants.h"

BJSessionManager::BJSessionManager()
{
  m_Manager = NULL;
  m_Controller = NULL;
  m_LastDataLen = 0;
  m_LastData = NULL;
}

BJSessionManager::~BJSessionManager()
{
  if (m_LastData)
  {
    free(m_LastData);
    m_LastData = NULL;    
  }
}

#pragma mark IBJNSNetServiceDelegateWrapper Methods  

void BJSessionManager::Error(SessionError error)
{
  [m_Manager endSession];
  
  m_LastError = error;
  
  if (error == SessionErrorConnectionClosed)
    m_Controller->EventRaised(EVENT_CONNECTION_LOST, this);
  else
    m_Controller->EventRaised(EVENT_SESSION_ERROR, this);
}

void BJSessionManager::SessionStarted()
{
  m_Controller->EventRaised(EVENT_SESSION_STARTED, this);
}

void BJSessionManager::SearchCancelled()
{
  m_Controller->EventRaised(EVENT_SEARCH_CANCELLED, this);
}

void BJSessionManager::DataReceived(const void* data, int length)
{
  if (m_LastData)
  {
    free(m_LastData);
    m_LastData = NULL;
  }
  
  m_LastData = malloc(length);
  memcpy(m_LastData, data, length);
  m_LastDataLen = length;
  
  m_Controller->EventRaised(EVENT_DATA_RECEIVED, this);
}

void BJSessionManager::ServerSelected()
{
  m_Controller->EventRaised(EVENT_CONNECTING, this);
}

#pragma mark ISessionManager Methods

bool BJSessionManager::StartSession(IGenericEvent* receiver, SessionMode mode)
{
  m_Controller = receiver;
  
  m_Manager = [[BJNSNetServiceDelegate alloc] initWithWrapper: this];
  m_Mode = mode;
  
  switch (mode)
  {
    case SessionModeServer:
      return [m_Manager advertise] == YES;
      break;
    case SessionModeClient:
      return [m_Manager search] == YES;
      break;
    default:
      return FALSE;
  }
}

void BJSessionManager::SendData(void* data, int length, bool reliable)
{
  NSData* nsData = [NSData dataWithBytes: data length: length];
  
  [m_Manager sendData: nsData: reliable];
}

void BJSessionManager::GetData(void*& data, int& length)
{
  data = m_LastData;
  length = m_LastDataLen;
}

void BJSessionManager::EndSession()
{
  if (m_LastData)
  {
    free(m_LastData);
    m_LastData = NULL;
  }

  if (m_Manager)
  {
    [m_Manager endSession];
    [m_Manager release];
    m_Manager = NULL;
  }  
}

bool BJSessionManager::IsServer()
{
  return m_Mode == SessionModeServer;
}
