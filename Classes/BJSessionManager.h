/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "ISessionManager.h"
#import "IBJNSNetServiceDelegateWrapper.h"
#import "BJNSNetServiceDelegate.h"

class BJSessionManager : public IBJNSNetServiceDelegateWrapper, public ISessionManager
{
private:
  IGenericEvent* m_Controller;
  BJNSNetServiceDelegate* m_Manager;
  SessionMode m_Mode;
  int m_LastDataLen;
  void* m_LastData;
  SessionError m_LastError;
  
public:
  BJSessionManager();
  ~BJSessionManager();
  
#pragma mark IBJNSNetServiceDelegateWrapper Methods  
  void Error(SessionError error);
  void SessionStarted();
  void SearchCancelled();
  void DataReceived(const void* data, int length);
  void ServerSelected();
  
#pragma mark ISessionManager Methods
  
  bool StartSession(IGenericEvent* receiver, SessionMode mode);
  void SendData(void* data, int length, bool reliable);
  void GetData(void*& data, int& length);
  void EndSession();
  void PeerDisconnected();
  bool IsServer();
};