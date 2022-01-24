/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <sstream>

#import "MultiplayerHighScore.h"

MultiplayerHighScore::MultiplayerHighScore(int p1Score, string p1Name, int p2Score, string p2Name)
{
  m_P1Score = p1Score;
  m_P1Name = p1Name;
  m_P2Score = p2Score;
  m_P2Name = p2Name;
}

MultiplayerHighScore::MultiplayerHighScore(string data)
{
  stringstream ss;
  
  size_t pos = data.find('\t');

  m_P1Name = data.substr(0, pos);
  data = data.substr(pos + 1);
    
  pos = data.find('\t');
  ss.str(data.substr(0, pos));
  ss >> m_P1Score;
  data = data.substr(pos + 1);
  
  pos = data.find('\t');
  m_P2Name = data.substr(0, pos);
  data = data.substr(pos + 1);
  
  ss.clear();
  ss.str(data);
  ss >> m_P2Score;
}

bool MultiplayerHighScore::operator>(const MultiplayerHighScore &rhs)
{
  int ldiff = abs(m_P1Score - m_P2Score);
  int rdiff = abs(rhs.m_P1Score - rhs.m_P2Score);
  
  if (ldiff != rdiff)
    return abs(m_P1Score - m_P2Score) > abs(rhs.m_P1Score - rhs.m_P2Score);
  
  // If score difference is the same, compare on number of games played
  return (m_P1Score + m_P2Score) > (rhs.m_P1Score + rhs.m_P2Score);
}

bool MultiplayerHighScore::operator==(const int &rhs)
{
  return (rhs == 0 && m_P1Score == 0 && m_P2Score == 0);
}

int MultiplayerHighScore::GetP1Score()
{
  return m_P1Score;
}

string MultiplayerHighScore::GetP1Name()
{
  return m_P1Name;
}

int MultiplayerHighScore::GetP2Score()
{
  return m_P2Score;
}

string MultiplayerHighScore::GetP2Name()
{
  return m_P2Name;
}

string MultiplayerHighScore::MultiplayerHighScore::Serialise()
{
  stringstream ss;
  
  ss << m_P1Name;
  ss << '\t';
  ss << m_P1Score;
  ss << '\t';
  ss << m_P2Name;
  ss << '\t';
  ss << m_P2Score;
  
  return ss.str();
  
}
