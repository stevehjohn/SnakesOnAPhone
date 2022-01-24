/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "IGameItem.h"

class GIBackground : public IGameItem
{
private:
  int m_ArenaW;
  int m_ArenaH;
  GIBackground();
  vector<BasicSprite> m_BGItems;
  void InitBG(int bgItems);
  int m_SpriteY;
  
public:
  GIBackground(int arenaW, int arenaH, int bgItemCount);
  void Render(GL2DView* view);
  int GetGameItemType();
  int GetBackgroundNumber();
};