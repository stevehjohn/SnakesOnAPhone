/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <OpenGLES/ES1/gl.h>

class SpriteSheetInfo
{
private:
  int m_UserRef;
  GLuint m_SheetNumber;
  // Original sprite size (on the source bitmap)
  int m_SpriteW;
  int m_SpriteH;
  // Sprite size in pixels scaled to the containing texture
  GLfloat m_TexSpriteWs;
  GLfloat m_TexSpriteHs;
  // Sprite dimensions as a fraction of the texture
  GLfloat m_TexSpriteWf;
  GLfloat m_TexSpriteHf;
  int m_SpriteCount;
  int m_BorderWidth;
  
  SpriteSheetInfo();
  
public:
  SpriteSheetInfo(int UserRef, GLuint SheetNumber, int SpriteW, int SpriteH, GLfloat TexSpriteWf, GLfloat TexSpriteHf, GLfloat TexSpriteWs, GLfloat TexSpriteHs, int SpriteCount, int BorderWidth);
  
  GLuint GetSheetNumber();
  int GetSpriteW();
  int GetSpriteH();
  GLfloat GetSpriteTexWf();
  GLfloat GetSpriteTexHf();
  GLfloat GetSpriteTexWs();
  GLfloat GetSpriteTexHs();
  int GetBorderWidth();
};
