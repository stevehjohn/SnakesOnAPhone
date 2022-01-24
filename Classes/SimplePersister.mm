/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "SimplePersister.h"
#import "Utils.h"

SimplePersister::SimplePersister(string fileName)
{
  m_FileName = fileName;
  m_FileBuf = NULL;
  m_HasPath = FALSE;
}

SimplePersister::SimplePersister(string fileName, bool hasPath)
{
  m_FileName = fileName;
  m_FileBuf = NULL;
  m_HasPath = hasPath;
}

void SimplePersister::Open(PersisterMode mode)
{
  m_Mode = mode;
  if (m_Mode == PersisterModeWrite)
    m_FileBuf = [NSMutableData dataWithCapacity: 500];
  else
  {
    m_Pos = 0;
    if (m_HasPath)
      m_FileBuf = [NSData dataWithContentsOfFile: Utils::StdStringToNSString(m_FileName)];
    else
      m_FileBuf = [NSData dataWithContentsOfFile: GetFilePath()];
  }
}

void SimplePersister::WriteLine(string data)
{
  data += '\n';
  NSData* nsData = [NSData dataWithBytes: data.c_str() length: data.length()];
  [m_FileBuf appendData: nsData];
}

bool SimplePersister::ReadLine(string& data)
{
  if (m_Pos >= [m_FileBuf length])
    return FALSE;
  
  char* bytes = (char*) [m_FileBuf bytes];
  
  int curPos = m_Pos;
  while (m_Pos < [m_FileBuf length] && bytes[m_Pos] != '\n')
    m_Pos++;
  
  data.resize(m_Pos - curPos, '\0');
  for (int i = curPos; i < m_Pos; i++)
    data[i - curPos] = bytes[i];
  
  if (m_Pos < [m_FileBuf length])
    m_Pos++;
    
  return TRUE;
}

void SimplePersister::Close()
{
  if (m_Mode == PersisterModeWrite)
  {
    if (m_HasPath)
      [m_FileBuf writeToFile: Utils::StdStringToNSString(m_FileName) atomically: FALSE];
    else
      [m_FileBuf writeToFile: GetFilePath() atomically: FALSE];
  }

  // TODO: Release?
  m_FileBuf = NULL;
}

NSString* SimplePersister::GetFilePath()
{
  NSArray* paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
  
  NSMutableString* path = [NSMutableString stringWithString: [paths objectAtIndex: 0]];
  [path appendString: @"/"];
  NSString* fileName = Utils::StdStringToNSString(m_FileName);
  [path appendString: fileName];
  
  return path;
}