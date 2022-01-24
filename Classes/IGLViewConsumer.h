/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "GL2DView.h"
#import "Constants.h"

class IGLViewConsumer
{
private:  
  IGLViewConsumer();

protected:
  GL2DView* m_View;
  
public:
  IGLViewConsumer(GL2DView* view);
  
  virtual void Render() = 0;
};