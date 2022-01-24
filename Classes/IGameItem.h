/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "GL2DView.h"

class IGameItem
{
public:
  virtual void Render(GL2DView* view) = 0;
  virtual void Update(vector<IGameItem*>* items, bool isClient);
  virtual void CheckInteractions(vector<IGameItem*>* items);
  // Implement to identify the class type
  // Can use a simple switch then rather than have to try and
  // dynamic_cast against each possible type
  virtual int GetGameItemType() = 0;
};