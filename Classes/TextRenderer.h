/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <string>

#import "IGLViewConsumer.h"
#import "General.h"
#import "IGenericEvent.h"
#import "IScrollingViewItem.h"

using namespace std;

typedef enum
{
  TextPositionManual = 0,
  TextPositionCentreScreen
} TextPosition;

// These are from the POV of gameplay - i.e. device with home button to user's right
typedef enum
{
  TextOrientationHorizontal = 0,
  TextOrientation90,
  TextOrientation270
} TextOrientation;

typedef enum 
{
  TextAnchorCentre = 0,
  TextAnchorLeft,
  TextAnchorRight
} TextAnchor;

typedef enum 
{
  TextAnimationNone = 0,
  TextAnimationSplat = 1,
  TextAnimationSplatRepeat = 2,
  TextAnimationZoomFade = 4,
  TextAnimationDropBounce = 8,
  TextAnimationJiggleLeft = 16,
  TextAnimationJiggleRight = 32,
  TextAnimationDropOff = 64
} TextAnimation;

class TextRenderer : public IGLViewConsumer, public IScrollingViewItem
{
protected:
  bool m_Visible;
  int m_X;
  int m_Y;
  int m_Animation;
  TextPosition m_Position;
  vector<Coords> m_FontSprites;
  int m_TextSize;
  int m_TextLen;
  int m_StateVar;
  float m_Scale;
  float m_R, m_G, m_B;
  float m_CharSpacing;
  float m_Opacity;
  vector<float> m_DropOffsets;
  vector<float> m_DropAccelVals;
  int m_FireEventWhenDone;
  IGenericEvent* m_Controller;
  TextOrientation m_Orientation;
  TextAnchor m_Anchor;
  float m_JiggleVar;
  int m_FontSheetRef;
  int m_FontSpriteSize;
  
  void RenderSplat();
  void RenderDropBounce();
  void DrawText(float scale, float opacity);
  
  TextRenderer();
public:
  TextRenderer(GL2DView* view, string text, TextPosition position, TextAnimation animation, float scale);

  void SetColour(float r, float g, float b);
  void SetPosition(int x, int y);
  void SetPosition(Coords x);
  void SetCharSpacing(float spacing);
  void SetOrientation(TextOrientation orientation);
  void SetAnchor(TextAnchor anchor);
  void AddAnimation(TextAnimation animation);
  void RemoveAnimation(TextAnimation animation);
  void SetVisible(bool visible);
  void SetFontSheet(int fontSheetRef);
  void SetFontSpriteSize(int fontSpriteSize);

  void SetController(IGenericEvent* controller);

  virtual void Render();

  Coords GetCoords();
  void SetOpacity(float opacity);
};