/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <string>

using namespace std;

typedef enum
{
  PersisterModeRead = 0,
  PersisterModeWrite
} PersisterMode;

class IPersister
{
public:
  virtual void Open(PersisterMode mode) = 0;
  virtual void WriteLine(string data) = 0;
  virtual bool ReadLine(string& data) = 0;
  virtual void Close() = 0;
};