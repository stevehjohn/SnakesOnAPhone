/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <string>
#import <OpenGLES/ES1/gl.h>

#import "General.h"

using namespace std;

typedef struct
{
  float dX;
  float dY;
} AngleDelta;

class Utils
{
private:
  static AngleDelta* m_Angles;
  static int m_IsiPad;
  
public:
  static NSString* StdStringToNSString(string src);
  static string NSStringToStdString(NSString* src);
  
  static string StdStringToUppercase(string str);
  
  static GLubyte* LoadResourceImgBytesRGBA(string name, size_t* imgWidth, size_t* imgHeight, size_t* bufferWidth, size_t* bufferHeight);
  
  static AngleDelta GetAngleDelta(int Angle);
  static void TurnInDirection(int& curAngle, int targetAngle);
  static float CalculateDistance(Coords c1, Coords c2);
  
  static void TextToSpriteCoords(string text, vector<Coords>& coords);
  static Coords CharToSpriteCoords(char c);
  
  static bool IsiPad();
};