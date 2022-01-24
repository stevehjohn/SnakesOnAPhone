/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <sstream>

#import "SinglePlayerHighScore.h"

SinglePlayerHighScore::SinglePlayerHighScore(int score)
{
  m_Score = score;
}

SinglePlayerHighScore::SinglePlayerHighScore(int score, string name)
{
  m_Score = score;
  m_Name = name;
}

SinglePlayerHighScore::SinglePlayerHighScore(string data)
{
  size_t pos = data.find('\t');
  if (pos != string::npos)
  {
    m_Name = data.substr(0, pos);
    stringstream ss(data.substr(pos + 1));
    ss >> m_Score;
  }
}

bool SinglePlayerHighScore::operator>(const SinglePlayerHighScore &rhs)
{
  return m_Score > rhs.m_Score;
}

bool SinglePlayerHighScore::operator==(const int &rhs)
{
  return m_Score == rhs;
}

int SinglePlayerHighScore::GetScore()
{
  return m_Score;
}

string SinglePlayerHighScore::GetName()
{
  return m_Name;
}

string SinglePlayerHighScore::Serialise()
{
  stringstream ss;
  
  ss << m_Name;
  ss << '\t';
  ss << m_Score;
  
  return ss.str();
}
