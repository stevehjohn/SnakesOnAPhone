/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <vector>
#import <string>

#import "General.h"

using namespace std;

class BoardBuilder
{
private:
  static void LoadBoard(vector<BasicSprite>& items, int number, bool preview, vector<Coords>* waypoints);
  
public:
  static int GetBoardCount();
  static BoardInfo GetBoardPreview(int number);
  static BoardInfo GetBoard(int number);
  static int GetPointsToUnlock(int boardToUnlock);
};