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

class MultiplayerHighScore
{
private:
  int m_P1Score;
  int m_P2Score;
  string m_P1Name;
  string m_P2Name;
  
public:
  MultiplayerHighScore(int p1Score, string p1Name, int p2Score, string p2Name);
  MultiplayerHighScore(string data);

  bool operator>(const MultiplayerHighScore &rhs);
  bool operator==(const int &rhs);

  int GetP1Score();
  string GetP1Name();
  int GetP2Score();
  string GetP2Name();
  
  string Serialise();
};