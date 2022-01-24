/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <string>

#import "IPersister.h"

using namespace std;

class SimplePersister : public IPersister
{
private:
  string m_FileName;
  NSMutableData* m_FileBuf;
  PersisterMode m_Mode;
  int m_Pos;
  bool m_HasPath;
  
  SimplePersister();
  
  NSString* GetFilePath();
public:
  SimplePersister(string fileName);
  SimplePersister(string fileName, bool hasPath);
  
  void Open(PersisterMode mode);
  void WriteLine(string data);
  bool ReadLine(string& data);
  void Close();  
};