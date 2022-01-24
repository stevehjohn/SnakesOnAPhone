/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "AVAPManager.h"
#import "Utils.h"

AVAPManager* AVAPManager::m_Inst = NULL;

AVAPManager* AVAPManager::Instance()
{
  if (m_Inst == NULL)
    m_Inst = new AVAPManager();
  
  return m_Inst;
}

AVAPManager::AVAPManager()
{
  m_Player = [[AVAudioPlayerDelegate alloc] init];
}

AVAPManager::~AVAPManager()
{
  [m_Player release];
}

void AVAPManager::PlayMusic(string fileName, string fileType)
{
  [m_Player PlayBGMusic: Utils::StdStringToNSString(fileName): Utils::StdStringToNSString(fileType)];
}

void AVAPManager::Pause()
{
  [m_Player Pause];
}

void AVAPManager::Resume()
{
  [m_Player Resume];
}

void AVAPManager::Stop()
{
  [m_Player Stop];
}
