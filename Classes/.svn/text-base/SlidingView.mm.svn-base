/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "SlidingView.h"
#import "Constants.h"

SlidingView::SlidingView(GL2DView* view) : IGLViewConsumer(view)
{
  m_Offset = 0;
  m_Fingering = FALSE;
  m_LastPos = 0;
  m_Moved = FALSE;
  m_Locked = FALSE;
  m_SlideTo = -1;
}

void SlidingView::AddItem(IGLViewConsumer* item, int page)
{
  while (page >= m_Items.size())
  {
    m_Items.push_back(new vector<IGLViewConsumer*>);
  }
  m_Items[page]->push_back(item);
}

SlidingView::~SlidingView()
{
}

void SlidingView::Render()
{
  vector<vector<IGLViewConsumer*>*>::iterator pageIter = m_Items.begin();
  
  int y = m_Offset;
  for (; pageIter != m_Items.end(); ++pageIter)
  {
    m_View->SetViewArea(0, y, m_View->GetViewW(), m_View->GetViewH());
    
    vector<IGLViewConsumer*>::iterator itemIter = (*pageIter)->begin();
    for (; itemIter != (*pageIter)->end(); ++ itemIter)
    {
      (*itemIter)->Render();
    }
    
    y += m_View->GetViewH();
  }
  
  if (m_SlideTo >= 0)
  {
    if (m_Offset > -m_View->GetViewH() * m_SlideTo + SLIDEVIEW_AUTO_SCROLL_DELTA)
      m_Offset -= SLIDEVIEW_AUTO_SCROLL_DELTA;
    else if (m_Offset < -m_View->GetViewH() * m_SlideTo - SLIDEVIEW_AUTO_SCROLL_DELTA)
      m_Offset += SLIDEVIEW_AUTO_SCROLL_DELTA;
    else 
      m_SlideTo = -1;
  }
  else if (! m_Fingering)
  {
    if (m_Offset > 0)
    {
      m_Offset -= SLIDEVIEW_AUTO_SCROLL_DELTA;
    }
    else
    {
      int mod = abs(m_Offset) % m_View->GetViewH();
      if (mod != 0)
      {
        if (mod < SLIDEVIEW_AUTO_SCROLL_DELTA)
          m_Offset += mod;
        else if (mod >= m_View->GetViewH() - SLIDEVIEW_AUTO_SCROLL_DELTA)
          m_Offset += mod - m_View->GetViewH();
        else if (mod < m_View->GetViewH() / 2)
          m_Offset += SLIDEVIEW_AUTO_SCROLL_DELTA;
        else
          m_Offset -= SLIDEVIEW_AUTO_SCROLL_DELTA;      
      }
    }
  }
}

void SlidingView::TouchEvent(TouchInfo touches[], int count)
{
  if (m_SlideTo >= 0)
    return;
  
  if (count == 1 && ! m_Locked)
  {
    if (! m_Fingering)
    {
      if (touches[0].phase == Began)
      {
        m_Fingering = TRUE;
        m_Moved = FALSE;
        m_LastPos = touches[0].y;
      }
    }
    else if (touches[0].phase == Moved)
    {
      if (abs(touches[0].y - m_LastPos) > SLIDEVIEW_LOCK_PIXELS || m_Moved)
      {
        m_Moved = TRUE;
        m_Offset += touches[0].y - m_LastPos;
        m_LastPos = touches[0].y;
        
        if (m_Offset > m_View->GetViewH() / 3)
          m_Offset = m_View->GetViewH() / 3;
        else if (m_Offset < (int) -(m_View->GetViewH() * (m_Items.size() - 1) + m_View->GetViewH() / 3))
          m_Offset = -(m_View->GetViewH() * (m_Items.size() - 1) + m_View->GetViewH() / 3);
      }
    }
    else if (touches[0].phase == Ended)
    {
      m_Fingering = FALSE;
      m_Moved = FALSE;
    }
  }
  
  // Pass touches on (not if we are sliding though)
  int mod = abs(m_Offset) % m_View->GetViewH();
  if (mod <= SLIDEVIEW_LOCK_PIXELS || mod >= m_View->GetViewH() - SLIDEVIEW_LOCK_PIXELS)
  {
    int page = abs(m_Offset / m_View->GetViewH());
    vector<IGLViewConsumer*>::iterator itemIter = m_Items[page]->begin();
    for (; itemIter != m_Items[page]->end(); ++ itemIter)
    {
      ITouchReceiver* receiver = dynamic_cast<ITouchReceiver*> (*itemIter);
      if (receiver)
        receiver->TouchEvent(touches, count);
    }      
  }
}

void SlidingView::SetLocked(bool locked)
{
  m_Locked = locked;
}

void SlidingView::SetStartPage(int page)
{
  m_Offset = -m_View->GetViewH() * page;
}

int SlidingView::GetOffset()
{
  return m_Offset;
}

void SlidingView::SlideTo(int page)
{
  m_SlideTo = page;
}

void SlidingView::SlideToNext()
{
  SlideTo(abs(m_Offset / m_View->GetViewH()) + 1);
}

void SlidingView::SlideToPrev()
{
  SlideTo(abs(m_Offset / m_View->GetViewH()) - 1);
}

