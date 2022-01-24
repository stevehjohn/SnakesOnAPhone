/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "SpriteSheetInfo.h"

SpriteSheetInfo::SpriteSheetInfo(int UserRef, GLuint SheetNumber, int SpriteW, int SpriteH, GLfloat TexSpriteWf, GLfloat TexSpriteHf, GLfloat TexSpriteWs, GLfloat TexSpriteHs, int SpriteCount, int BorderWidth)
{
  m_SheetNumber = SheetNumber;
  m_SpriteW = SpriteW;
  m_SpriteH = SpriteH;
  m_TexSpriteWf = TexSpriteWf;
  m_TexSpriteHf = TexSpriteHf;
  m_TexSpriteWs = TexSpriteWs;
  m_TexSpriteHs = TexSpriteHs;
  m_SpriteCount = SpriteCount;
  m_BorderWidth = BorderWidth;
}

GLuint SpriteSheetInfo::GetSheetNumber()
{
  return m_SheetNumber;
}

int SpriteSheetInfo::GetSpriteW()
{
  return m_SpriteW;
}

int SpriteSheetInfo::GetSpriteH()
{
  return m_SpriteH;
}

GLfloat SpriteSheetInfo::GetSpriteTexWf()
{
  return m_TexSpriteWf;
}

GLfloat SpriteSheetInfo::GetSpriteTexHf()
{
  return m_TexSpriteHf;
}

GLfloat SpriteSheetInfo::GetSpriteTexWs()
{
  return m_TexSpriteWs;
}

GLfloat SpriteSheetInfo::GetSpriteTexHs()
{
  return m_TexSpriteHs;
}

int SpriteSheetInfo::GetBorderWidth()
{
  return m_BorderWidth;
}
