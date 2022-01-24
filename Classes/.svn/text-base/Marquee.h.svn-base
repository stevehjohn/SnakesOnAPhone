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

#import "IGLViewConsumer.h"
#import "TextRenderer.h"

class Marquee : public IGLViewConsumer
{
private:
  Coords m_Coords;
  vector<string> m_Items;
  TextRenderer* m_Text;
  int m_Frame;
  int m_ItemNo;
  
public:
  Marquee(GL2DView* view);
  ~Marquee();
  void SetPosition(int x, int y);
  void AddText(string text);
  
  void Render();
};