/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <AudioToolbox/AudioToolbox.h>

#import "ALManager.h"
#import "Utils.h"
#import "Constants.h"

ALManager* ALManager::m_Inst = NULL;

ALManager* ALManager::Instance()
{
  if (m_Inst == NULL)
    m_Inst = new ALManager();
  
  return m_Inst;
}

ALManager::ALManager()
{
  m_SoundsOn = TRUE;
  InitAL();
}

ALManager::~ALManager()
{
  alcDestroyContext(m_Context);
  alcCloseDevice(m_Device);
}

void ALManager::InitAL()
{
  m_Device = alcOpenDevice(NULL);
  m_Context = alcCreateContext(m_Device, NULL);
  alcMakeContextCurrent(m_Context);
  
  for (int i = 0; i < NUMBER_OF_SOUND_SOURCES; i++)
  {
    ALuint sid;
    alGenSources(1, &sid);
    m_Sources.insert(pair<int, int>(i, sid));
  }
}

void ALManager::LoadSound(int UserRef, string SoundName, int Frequency)
{
  NSString* path = [[NSBundle mainBundle] pathForResource: Utils::StdStringToNSString(SoundName) ofType: @"caf"];
  
  NSURL* url = [NSURL fileURLWithPath: path];
  
  AudioFileID afid;
  OSStatus res = AudioFileOpenURL((CFURLRef) url, kAudioFileReadPermission, 0, &afid);
  
  UInt64 fileSize;
  UInt32 fileSizeSize = sizeof(UInt64);
  res = AudioFileGetProperty(afid, kAudioFilePropertyAudioDataByteCount, &fileSizeSize, &fileSize);
  
  unsigned char* temp = (unsigned char*) malloc(fileSize);
  res = AudioFileReadBytes(afid, FALSE, 0, (UInt32*) &fileSize, temp);
  AudioFileClose(afid);
  
  ALuint soundRef;
  alGenBuffers(1, &soundRef);
  
  alBufferData(soundRef, AL_FORMAT_STEREO16, temp, fileSize, Frequency);
  free(temp);
  
  m_Sounds.insert(pair<int, int>(UserRef, soundRef));
}

void ALManager::PlaySound(int UserRef)
{
  if (! m_SoundsOn)
    return;
  
  ALint state = AL_PLAYING;
  ALint source;
  for (int i = 0; i < NUMBER_OF_SOUND_SOURCES; i++)
  {
    source = m_Sources[i];
    alGetSourcei(source, AL_SOURCE_STATE, &state);
    if (state != AL_PLAYING)
      break;
  }

  // Just don't play the sound if no sources are available
  if (state == AL_PLAYING)
    return;
  
  alSourcei(source, AL_BUFFER, 0);
  alSourcei(source, AL_BUFFER, m_Sounds[UserRef]);
  alSourcei(source, AL_LOOPING, AL_FALSE);
  
  alSourcePlay(source);
}

void ALManager::SetSoundStatus(bool soundsOn)
{
  m_SoundsOn = soundsOn;
}

