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

class SinglePlayerHighScore
{
private:
  string m_Name;
  int m_Score;
  
public:
  SinglePlayerHighScore(int score);
  SinglePlayerHighScore(int score, string name);
  SinglePlayerHighScore(string data);
  
  bool operator>(const SinglePlayerHighScore &rhs);
  bool operator==(const int &rhs);
  
  int GetScore();
  string GetName();
  
  string Serialise();
};