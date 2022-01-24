/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "IGameItem.h"
#import "GL2DView.h"

class GIWalls : public IGameItem
{
private:
  vector<BasicSprite>* m_Blocks;
public:
  GIWalls(vector<BasicSprite>* walls);
  void Render(GL2DView* view);
  int GetGameItemType();
  bool CheckCollision(Coords coords, int size);
  bool CheckLineOfSight(Coords c1, Coords c2);
};