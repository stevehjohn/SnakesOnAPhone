/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "GL2DView.h"
#import "Utils.h"

GL2DView::GL2DView(EAGLContext* context, CALayer* layer)
{
  m_Context = context;
  m_Layer = layer;
  m_SpriteCurrSheet = -1;
  m_SpriteCurrX = -1;
  m_SpriteCurrY = -1;
  m_ViewW = layer.bounds.size.width;
  m_ViewH = layer.bounds.size.height;
  m_BaseOpacity = 1.0;
  CreateBuffers();
  InitGL();
}

void GL2DView::CreateBuffers()
{
  glGenFramebuffersOES(1, &m_frameBuffer);
  glGenRenderbuffersOES(1, &m_renderBuffer);
  
  glBindFramebufferOES(GL_FRAMEBUFFER_OES, m_frameBuffer);
  glBindRenderbufferOES(GL_RENDERBUFFER_OES, m_renderBuffer);
  
 	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, m_renderBuffer);
	
  GLint width = m_Layer.bounds.size.width;
  GLint height = m_Layer.bounds.size.height;
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &width);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &height);
  
  [m_Context renderbufferStorage: GL_RENDERBUFFER_OES fromDrawable: (id<EAGLDrawable>) m_Layer];  
}

void GL2DView::InitGL()
{
  glMatrixMode(GL_PROJECTION);
  GLint width = m_Layer.bounds.size.width;
  GLint height = m_Layer.bounds.size.height;  
  glLoadIdentity();
  glOrthof(0, width, 0, height, 1, -1);
  CGRect rect = m_Layer.bounds;
  glViewport(0, 0, rect.size.width, rect.size.height);
  glMatrixMode(GL_MODELVIEW);
  
  glEnable(GL_TEXTURE_2D);
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);  

  // Default to a viewed area the size of the display
  m_CameraPos.x = 0;
  m_CameraPos.y = 0;
  m_CameraSize.w = width;
  m_CameraSize.h = height;
  m_BaseXScale = 1.0;
  m_BaseYScale = 1.0;

  [EAGLContext setCurrentContext: m_Context];
}

SpriteSheetInfo* GL2DView::LoadSpriteSheet(int UserRef, string SheetName, int SpriteWidth, int SpriteHeight, int BorderWidth)
{
  size_t imgW, imgH, bufW, bufH;
  
  GLubyte* data = Utils::LoadResourceImgBytesRGBA(SheetName, &imgW, &imgH, &bufW, &bufH);
  
  GLuint sheetRef;
  
  glGenTextures(1, &sheetRef);
  glBindTexture(GL_TEXTURE_2D, sheetRef);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, bufW, bufH, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
  
  free(data);
  
  GLfloat txw, txh;
  txw = 1.0 / imgW;
  txh = 1.0 / imgH;
  SpriteWidth += BorderWidth * 2;
  SpriteHeight += BorderWidth * 2;
  SpriteSheetInfo* info = new SpriteSheetInfo(UserRef,
                                              sheetRef, 
                                              SpriteWidth, 
                                              SpriteHeight, 
                                              txw,
                                              txh,
                                              txw * SpriteWidth, 
                                              txh * SpriteHeight, 
                                              (imgW / SpriteWidth) * (imgH / SpriteHeight),
                                              BorderWidth);
  
  m_SpriteSheets.insert(pair<int, SpriteSheetInfo*>(UserRef, info));
  
  return info;
}

void GL2DView::SetBGColour(Colour bgCol)
{
  m_BGCol = bgCol;
}

void GL2DView::BeginFrame(bool clearBuffer)
{
  
  glBindFramebufferOES(GL_FRAMEBUFFER_OES, m_frameBuffer);
  if (clearBuffer)
  {
    glClearColor(m_BGCol.r, m_BGCol.g, m_BGCol.b, m_BGCol.alpha);
    glClear(GL_COLOR_BUFFER_BIT);
  }
  glEnableClientState(GL_VERTEX_ARRAY);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);
  
  glLoadIdentity();
}

SpriteSheetInfo* GL2DView::LoadSpriteSheetInfo(int UserRef)
{  
  SpriteSheetInfo* info = m_SpriteSheets[UserRef];
  
  m_SpriteW = info->GetSpriteW();
  m_SpriteH = info->GetSpriteH();
  m_SpriteBorder = info->GetBorderWidth();
  
  m_SpriteW -= m_SpriteBorder * 2;
  m_SpriteH -= m_SpriteBorder * 2;
  
  CalcSpriteVerticies();

  m_TexSpriteW = info->GetSpriteTexWs();
  m_TexSpriteH = info->GetSpriteTexHs();
  m_TexSpriteWPx = info->GetSpriteTexWf();
  m_TexSpriteHPx = info->GetSpriteTexHf();
  
  m_SpriteCurrX = -1;
  m_SpriteCurrY = -1;

  m_SpriteCurrSheet = UserRef;
  
  return info;
}

void GL2DView::CalcSpriteVerticies()
{
  m_SpriteVertices[0] = -(m_SpriteW * m_BaseXScale / 2);
  m_SpriteVertices[1] = ((m_SpriteH + 1) * m_BaseYScale / 2);
  m_SpriteVertices[2] = 0.0;
  m_SpriteVertices[3] = ((m_SpriteW + 1) * m_BaseXScale / 2);
  m_SpriteVertices[4] = ((m_SpriteH + 1) * m_BaseYScale / 2);
  m_SpriteVertices[5] = 0.0;
  m_SpriteVertices[6] = -(m_SpriteW * m_BaseXScale / 2);
  m_SpriteVertices[7] = -(m_SpriteH * m_BaseYScale / 2);
  m_SpriteVertices[8] = 0.0;
  m_SpriteVertices[9] = ((m_SpriteW + 1) * m_BaseXScale / 2);
  m_SpriteVertices[10] = -(m_SpriteH * m_BaseYScale / 2);
  m_SpriteVertices[11] = 0.0;
}

void GL2DView::DrawSprite(int UserRef, int spriteX, int spriteY, int x, int y, int rotation, float scale, float opacity)
{
  DrawSprite(UserRef, spriteX, spriteY, x, y, rotation, scale, opacity, 1.0, 1.0, 1.0);
}

void GL2DView::DrawSprite(int UserRef, int spriteX, int spriteY, int x, int y, int rotation, float scale, float opacity, float r, float g, float b)
{  
  if (m_SpriteCurrSheet != UserRef)
  {
    SpriteSheetInfo* info = LoadSpriteSheetInfo(UserRef);
    glBindTexture(GL_TEXTURE_2D, info->GetSheetNumber());
  }

  // Is the sprite within the current camera view?
  if (! ((x >= m_CameraPos.x - m_SpriteW && x <= m_CameraPos.x + m_CameraSize.w) && 
         (y >= m_CameraPos.y - m_SpriteH && y <= m_CameraPos.y + m_CameraSize.h)))
    return;
  
  // Now do the sprite drawing
  if (spriteX != m_SpriteCurrX || spriteY != m_SpriteCurrY)
  {
    if (m_SpriteBorder > 0)
    {
      m_SpriteCurrCoords[0] = m_TexSpriteW * spriteX + m_TexSpriteWPx * m_SpriteBorder;
      m_SpriteCurrCoords[1] = m_TexSpriteH * spriteY + m_TexSpriteHPx * m_SpriteBorder;
      m_SpriteCurrCoords[2] = m_TexSpriteW * (spriteX + 1) - m_TexSpriteWPx * (m_SpriteBorder - 1) - m_TexSpriteWPx;
      m_SpriteCurrCoords[3] = m_TexSpriteH * spriteY + m_TexSpriteHPx * m_SpriteBorder;
      m_SpriteCurrCoords[4] = m_TexSpriteW * spriteX + m_TexSpriteWPx * m_SpriteBorder;
      m_SpriteCurrCoords[5] = m_TexSpriteH * (spriteY + 1) - m_TexSpriteHPx * (m_SpriteBorder - 1) - m_TexSpriteHPx;
      m_SpriteCurrCoords[6] = m_TexSpriteW * (spriteX + 1) - m_TexSpriteWPx * (m_SpriteBorder - 1) - m_TexSpriteWPx;
      m_SpriteCurrCoords[7] = m_TexSpriteH * (spriteY + 1) - m_TexSpriteHPx * (m_SpriteBorder - 1) - m_TexSpriteHPx;
    }
    else
    {
      m_SpriteCurrCoords[0] = m_TexSpriteW * spriteX;
      m_SpriteCurrCoords[1] = m_TexSpriteH * spriteY;
      m_SpriteCurrCoords[2] = m_TexSpriteW * (spriteX + 1) - m_TexSpriteWPx;
      m_SpriteCurrCoords[3] = m_TexSpriteH * spriteY;
      m_SpriteCurrCoords[4] = m_TexSpriteW * spriteX;
      m_SpriteCurrCoords[5] = m_TexSpriteH * (spriteY + 1) - m_TexSpriteHPx;
      m_SpriteCurrCoords[6] = m_TexSpriteW * (spriteX + 1) - m_TexSpriteWPx;
      m_SpriteCurrCoords[7] = m_TexSpriteH * (spriteY + 1) - m_TexSpriteHPx;
    }
    m_SpriteCurrX = spriteX;
    m_SpriteCurrY = spriteY;
  }
    
  glPushMatrix();
  
  float tx = ((x - m_CameraPos.x + m_SpriteW / 2) * m_BaseXScale);
  float ty = ((y - m_CameraPos.y + m_SpriteH / 2) * m_BaseYScale);

  glTranslatef(tx, ty, 0);
  if (rotation != 0) 
    glRotatef(360 - rotation, 0.0, 0.0, 1.0);
  if (scale != 1.0)
    glScalef(scale, scale, 1.0);
   
  glColor4f(r, g, b, opacity * m_BaseOpacity);
	glTexCoordPointer(2, GL_FLOAT, 0, m_SpriteCurrCoords);
  glVertexPointer(3, GL_FLOAT, 0, m_SpriteVertices);

	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
  glPopMatrix();
}

void GL2DView::DrawShape(float vertices[], int verticesCount, float opacity, float r, float g, float b)
{
  glDisable(GL_TEXTURE_2D);
  
  glPushMatrix();
  
  float tx = -m_CameraPos.x * m_BaseXScale;
  float ty = -m_CameraPos.y * m_BaseYScale;
  
  glTranslatef(tx, ty, 0);
  glColor4f(r, g, b, opacity * m_BaseOpacity);
  glVertexPointer(3, GL_FLOAT, 0, vertices);
	glDrawArrays(GL_TRIANGLES, 0, verticesCount);
  
  glPopMatrix();

  glEnable(GL_TEXTURE_2D);
}

void GL2DView::SetViewArea(int x, int y, int w, int h)
{
  m_CameraPos.x = x;
  m_CameraPos.y = y;
  m_CameraSize.w = w;
  m_CameraSize.h = h;
  m_BaseXScale = (float) m_ViewW / w;
  m_BaseYScale = (float) m_ViewH / h;
  
  CalcSpriteVerticies();
}

void GL2DView::PushViewArea()
{
  Bounds b;
  b.coords = m_CameraPos;
  b.dimensions = m_CameraSize;
  
  m_ViewStack.push_back(b);
}

void GL2DView::PopViewArea()
{
  Bounds b;
  
  b = m_ViewStack.back();

  SetViewArea(b.coords.x, b.coords.y, b.dimensions.w, b.dimensions.h);
  
  m_ViewStack.pop_back();
}

Coords GL2DView::GetViewAreaCoords()
{
  return m_CameraPos;
}

void GL2DView::EndFrame()
{
  [m_Context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

void GL2DView::ReleaseSpriteSheets()
{
  map<int, SpriteSheetInfo*>::iterator i = m_SpriteSheets.begin();
  
  for (; i != m_SpriteSheets.end(); ++i)
  {
    GLuint sheet = (*i).second->GetSheetNumber();
    glDeleteTextures(1, &sheet);
    delete (*i).second;
  }
  
  m_SpriteSheets.clear();
}

void GL2DView::SetAlphaBlendState(bool enable)
{
  if (enable)
  {
    glEnable(GL_BLEND);
  }
  else 
  {
    glDisable(GL_BLEND);
  }
}

int GL2DView::GetViewW()
{
  return m_ViewW;
}

int GL2DView::GetViewH()
{
  return m_ViewH;
}

void GL2DView::SetBaseOpacity(float opacity)
{
  m_BaseOpacity = opacity;
}

GL2DView::~GL2DView()
{
  ReleaseSpriteSheets();
}
