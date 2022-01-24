/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <string>

#import "AVAudioPlayerDelegate.h"

using namespace std;

class AVAPManager
{
private:
  static AVAPManager* m_Inst;
  AVAudioPlayerDelegate* m_Player;
  
  AVAPManager();
  
public:
  static AVAPManager* Instance();
  ~AVAPManager();
  
  void PlayMusic(string fileName, string fileType);
  void Pause();
  void Resume();
  void Stop();
};