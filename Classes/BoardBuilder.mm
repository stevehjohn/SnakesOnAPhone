/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <sstream>

#import "BoardBuilder.h"
#import "Constants.h"
#import "Utils.h"
#import "SimplePersister.h"

int BoardBuilder::GetBoardCount()
{
  return 10;
}

BoardInfo BoardBuilder::GetBoard(int number)
{
  BoardInfo board;
  
  if (number == -1)
  {
    // Demo board (behind menus)
    if (Utils::IsiPad())
    {
      board.width = 768;
      board.height = 1024;
    }
    else 
    {
      board.width = 320;
      board.height = 480;
    }
  }
  else
  {
    board.width = 768;
    board.height = 1024;
    LoadBoard(board.board, number, FALSE, &board.waypoints);
  }
  
  return board;
}

void BoardBuilder::LoadBoard(vector<BasicSprite>& items, int number, bool preview, vector<Coords>* waypoints)
{
  stringstream ss;
  ss << number;
  NSString* path;
  if (preview)
    path = [[NSBundle mainBundle] pathForResource: Utils::StdStringToNSString(ss.str()) ofType: @"preview"];
  else
    path = [[NSBundle mainBundle] pathForResource: Utils::StdStringToNSString(ss.str()) ofType: @"level"];
  
  IPersister* file = new SimplePersister(Utils::NSStringToStdString(path), TRUE);
  
  file->Open(PersisterModeRead);

  int x, sy;
  if (preview)
  {
    x = 320;
    sy = 512;
  }
  else 
  {
    x = 768;
    sy = 1024;
  }
  x -= OBSTACLE_SPRITE_SIZE;
  sy -= OBSTACLE_SPRITE_SIZE;
  
  string data;
  int y;
  BasicSprite sprite;
  int spriteno;
  Coords c;
  while (file->ReadLine(data))
  {
    y = sy;
    sprite.angle = 0;
    for (int i = 0; i < data.length(); i++)
    {
      sprite.x = x;
      sprite.y = y;
      
      if (data[i] >= 'A' && data[i] <= 'Z')
      {
        spriteno = data[i] - 'A';
        sprite.spriteX = spriteno % 4;
        sprite.spriteY = spriteno / 4;
        
        items.push_back(sprite);
      }
      else if (data[i] == '*' && waypoints)
      {
        c.x = x;
        c.y = y;
        waypoints->push_back(c);
      }
      
      y -= OBSTACLE_SPRITE_SIZE;
    }
    x -= OBSTACLE_SPRITE_SIZE;
  }
  
  file->Close();
  delete file;
}

BoardInfo BoardBuilder::GetBoardPreview(int number)
{
  BoardInfo board;
  if (Utils::IsiPad())
  {
    board.width = 768;
    board.height = 1024;
  }
  else
  {
    board.width = 320;
    board.height = 512;
  }
  LoadBoard(board.board, number, ! Utils::IsiPad(), NULL);
  return board;
}

int BoardBuilder::GetPointsToUnlock(int boardToUnlock)
{
  switch (boardToUnlock)
  {
    case 0:
    case 1:
    case 2:
    case 3:
      return 500;
    case 4:
      return 750;
    case 5:
    case 6:
    case 7:
    case 8:
    case 9:
      return 1000;
    case 10:
      return 750;
    default:
      return 1000;
  }
}
