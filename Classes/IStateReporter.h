/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

class IStateReporter
{
public:
  virtual int GetStateDataSize() = 0;
  virtual void GetStateData(char* buffer) = 0;
  virtual void PutStateData(char* buffer) = 0;
};