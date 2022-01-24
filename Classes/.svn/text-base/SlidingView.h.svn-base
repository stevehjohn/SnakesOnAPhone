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
#import "GL2DView.h"
#import "ITouchReceiver.h"
#import "IGenericEvent.h"

class SlidingView : public IGLViewConsumer, public ITouchReceiver
{
private:
  vector<vector<IGLViewConsumer*>*> m_Items;
  SlidingView();
  int m_Offset;
  bool m_Fingering;
  int m_LastPos;
  bool m_Moved;
  bool m_Locked;
  int m_SlideTo;
  
public:
  SlidingView(GL2DView* view);
  ~SlidingView();
  
  void AddItem(IGLViewConsumer* item, int page);
  
  void Render();

  void TouchEvent(TouchInfo touches[], int count);
  
  void SetLocked(bool locked);
  
  void SetStartPage(int page);
  
  int GetOffset();
  
  void SlideTo(int page);
  void SlideToNext();
  void SlideToPrev();
};