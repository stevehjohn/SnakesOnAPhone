/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <map>
#import <string>

// NOTE:
// Use the following to convert sounds:
//   afconvert -f caff -d LEI16@22050 -c 2 <infile> <outfile>
// Where 22050 is the frequency and 2 is the # of channels

using namespace std;

// Singleton - no locking now as we are single threaded
class ALManager
{
private:
  static ALManager* m_Inst;
  ALCdevice* m_Device;
  ALCcontext* m_Context;
  map<int, int> m_Sounds;
  map<int, int> m_Sources;
  bool m_SoundsOn;

  ALManager();
  void InitAL();
  
public:
  static ALManager* Instance();
  ~ALManager();
  
  void LoadSound(int UserRef, string SoundName, int Frequncy);
  void PlaySound(int UserRef);
  void SetSoundStatus(bool soundsOn);
};