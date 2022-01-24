/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

typedef enum
{
  Began = 0,
  Moved,
  Stationary,
  Ended,
  Cancelled
} TouchPhase;

typedef struct
{
  int x;
  int y;
  TouchPhase phase;
} TouchInfo;

class ITouchReceiver
{
public:
  virtual void TouchEvent(TouchInfo touches[], int count) = 0;
};