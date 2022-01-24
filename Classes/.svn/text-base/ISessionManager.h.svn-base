/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "IGenericEvent.h"

typedef enum
{
  SessionModeServer = 0,
  SessionModeClient
} SessionMode;

class ISessionManager
{
public:
  virtual bool StartSession(IGenericEvent* receiver, SessionMode mode) = 0;
  virtual void SendData(void* data, int length, bool reliable) = 0;
  virtual void GetData(void*& data, int& length) = 0;
  virtual void EndSession() = 0;
  virtual bool IsServer() = 0;  
};