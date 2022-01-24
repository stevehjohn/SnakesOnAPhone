/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <string>
#import <map>
#import <QuartzCore/CAEAGLLayer.h>

#import "SpriteSheetInfo.h"
#import "UIViewGL.h"
#import "General.h"

using namespace std;

class GL2DView
{
private:
  EAGLContext* m_Context;
  CALayer* m_Layer;
  GLuint m_frameBuffer;
  GLuint m_renderBuffer;
  map<int, SpriteSheetInfo*> m_SpriteSheets;
  
  int m_ViewW;
  int m_ViewH;
  
  int m_SpriteCurrSheet;
  GLfloat m_SpriteVertices[12];
  GLfloat m_SpriteW;
  GLfloat m_SpriteH;
  GLfloat m_TexSpriteW;
  GLfloat m_TexSpriteH;
  GLfloat m_TexSpriteWPx;
  GLfloat m_TexSpriteHPx;
  int m_SpriteCurrX;
  int m_SpriteCurrY;
  GLfloat m_SpriteCurrCoords[8];
  Colour m_BGCol;
  int m_SpriteBorder;
  
  Coords m_CameraPos;
  Dimensions m_CameraSize;
  float m_BaseXScale;
  float m_BaseYScale;
  
  float m_BaseOpacity;
  
  vector<Bounds> m_ViewStack;
  
  void ReleaseSpriteSheets();
  void CreateBuffers();
  void InitGL();
  SpriteSheetInfo* LoadSpriteSheetInfo(int UserRef);
  GL2DView();
  void CalcSpriteVerticies();
public:
  GL2DView(EAGLContext* context, CALayer* layer);
  
  SpriteSheetInfo* LoadSpriteSheet(int UserRef, string SheetName, int SpriteWidth, int SpriteHeight, int BorderWidth); 
  
  void SetBGColour(Colour bgCol);
  void BeginFrame(bool clearBuffer);
  void DrawSprite(int UserRef, int spriteX, int spriteY, int x, int y, int rotation, float scale, float opacity);
  void DrawSprite(int UserRef, int spriteX, int spriteY, int x, int y, int rotation, float scale, float opacity, float r, float g, float b);
  void DrawShape(float vertices[], int verticesCount, float opacity, float r, float g, float b);
  void SetViewArea(int x, int y, int w, int h);
  void PushViewArea();
  void PopViewArea();
  Coords GetViewAreaCoords();
  void EndFrame();
  void SetAlphaBlendState(bool enable);
  
  int GetViewW();
  int GetViewH();
  
  void SetBaseOpacity(float opacity);
  
  ~GL2DView();
};
