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

using namespace std;

typedef struct
{
  float x;
  float y;
} Coords;

typedef struct
{
  float w;
  float h;
} Dimensions;

typedef struct
{
  Coords coords;
  Dimensions dimensions;
} Bounds;

typedef struct
{
  float r;
  float g;
  float b;
  float alpha;
} Colour;

typedef struct
{
  float x;
  float y;
  int angle;
  int spriteX;
  int spriteY;
} BasicSprite;

typedef struct
{
  vector<BasicSprite> board;
  vector<Coords> waypoints;
  string name;
  int width;
  int height;
} BoardInfo;
