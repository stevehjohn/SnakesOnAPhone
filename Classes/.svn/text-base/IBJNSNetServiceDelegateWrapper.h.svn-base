/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

typedef enum
{
  SessionErrorDidNotAdvertise = 0,
  SessionErrorDidNotSearch,
  SessionErrorDidNotResolve,
  SessionErrorDidNotConnect,
  SessionErrorConnectionError,
  SessionErrorConnectionClosed
} SessionError;

class IBJNSNetServiceDelegateWrapper
{
public:
  virtual void Error(SessionError error) = 0;  
  virtual void SessionStarted() = 0;
  virtual void SearchCancelled() = 0;
  virtual void DataReceived(const void* data, int length) = 0;
  virtual void ServerSelected() = 0;
};