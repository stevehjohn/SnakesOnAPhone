/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <vector>

#import "IGLViewConsumer.h"
#import "ITouchReceiver.h"
#import "GL2DView.h"

using namespace std;

class ScrollingView : public IGLViewConsumer, public ITouchReceiver
{
private:
  vector<IGLViewConsumer*> m_Items;
  int m_Offset;
  bool m_Fingering;
  int m_LastPos;
  bool m_Moved;
  int m_Height;
  float m_Delta;
  int m_Top;
  
  ScrollingView();
public:
  ScrollingView(GL2DView* view, int height, int top);

  void AddItem(IGLViewConsumer* item);

  void Render();
  
  void TouchEvent(TouchInfo touches[], int count);
  
  IGLViewConsumer* GetItem(int idx);
  
  void SetOffset(int offset);
};