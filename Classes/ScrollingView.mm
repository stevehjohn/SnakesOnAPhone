/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "ScrollingView.h"
#import "Constants.h"
#import "IScrollingViewItem.h"

ScrollingView::ScrollingView(GL2DView* view, int height, int top) : IGLViewConsumer(view)
{
  m_Offset = 0;
  m_Fingering = FALSE;
  m_LastPos = 0;
  m_Moved = FALSE;
  m_Height = height;
  m_Top = top;
}

void ScrollingView::AddItem(IGLViewConsumer* item)
{
  m_Items.push_back(item);
}

void ScrollingView::Render()
{
  m_View->PushViewArea();
  Coords c = m_View->GetViewAreaCoords();
  
  m_View->SetViewArea(-m_Offset, c.y, m_View->GetViewW(), m_View->GetViewH());

  vector<IGLViewConsumer*>::iterator iter = m_Items.begin();
  
  for (; iter != m_Items.end(); ++iter)
  {
    IScrollingViewItem* item = dynamic_cast<IScrollingViewItem*>(*iter);
    
    Coords c = item->GetCoords();
    
    if (c.x + m_Offset > m_Top)
    {
      float opacity = m_Top + 50 - (c.x + m_Offset);
      if (opacity >= 0)
      {
        opacity = 1 / (50 / opacity);
      }
      else
        opacity = 0;
      item->SetOpacity(opacity);
    }
    else
      item->SetOpacity(1.0);
    
    (*iter)->Render();
  }
  
  m_View->PopViewArea();
  
  if (m_Height < m_Top)
    return;

  if (m_Delta != 0 && ! m_Moved)
  {
    if (m_Delta > 0)
      m_Delta -= SCROLLVIEW_INERTIA_DECREMENT;
    else
      m_Delta += SCROLLVIEW_INERTIA_DECREMENT;

    m_Offset += m_Delta;

    if (m_Offset < 0)
    {
      m_Offset = 0;
      m_Delta = 0;
    }
    if (m_Offset > m_Height - m_Top)
    {
      m_Offset = m_Height - m_Top;
      m_Delta = 0;
    }
  }
}

void ScrollingView::TouchEvent(TouchInfo touches[], int count)
{
  if (m_Height < m_Top)
    return;
  
  if (count == 1)
  {
    if (! m_Fingering)
    {
      if (touches[0].phase == Began)
      {
        m_Fingering = TRUE;
        m_Moved = FALSE;
        m_LastPos = touches[0].x;
      }
    }
    else if (touches[0].phase == Moved)
    {
      m_Moved = TRUE;
      m_Delta = touches[0].x - m_LastPos;
      m_Offset += m_Delta;
      m_LastPos = touches[0].x;      
      
      if (m_Offset < 0)
        m_Offset = 0;
      if (m_Offset > m_Height - m_Top)
        m_Offset = m_Height - m_Top;
    }
    else if (touches[0].phase == Ended)
    {
      m_Fingering = FALSE;
      m_Moved = FALSE;
    }
  }
}

IGLViewConsumer* ScrollingView::GetItem(int idx)
{
  return m_Items[idx];
}

void ScrollingView::SetOffset(int offset)
{
  m_Offset = offset;
}
