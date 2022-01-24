/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <OpenGLES/ES1/gl.h>
#import <cmath>

#import "Utils.h"
#import "Constants.h"

AngleDelta* Utils::m_Angles = 0;
int Utils::m_IsiPad = -1;

NSString* Utils::StdStringToNSString(string src)
{
  return [NSString stringWithCString:src.c_str() encoding:[NSString defaultCStringEncoding]];
}

string Utils::NSStringToStdString(NSString* src)
{
  return string([src cStringUsingEncoding: NSASCIIStringEncoding]);
}

string Utils::StdStringToUppercase(string str)
{
  string tmp = str;
  for (int i = 0; i < tmp.length(); i++)
  {
    if (tmp[i] >= 'a' && tmp[i] <= 'z')
      tmp[i] -= 32;
  }
  return tmp;
}

GLubyte* Utils::LoadResourceImgBytesRGBA(string name, size_t* imgWidth, size_t* imgHeight, size_t* bufferWidth, size_t* bufferHeight)
{
  NSString* ocName = Utils::StdStringToNSString(name);
  
  CGImageRef image = [UIImage imageNamed:ocName].CGImage;
  
  *imgWidth = CGImageGetWidth(image);
  *imgHeight = CGImageGetHeight(image);
  // Dimensions of texture buffer must be a power of 2, so find the next power of 2
  size_t w, h;
  for (w = 2; w < *imgWidth; w <<= 1);
  for (h = 2; h < *imgHeight; h <<= 1);
  *bufferWidth = w;
  *bufferHeight = h;
  
  GLubyte* data = (GLubyte *) calloc(w * h * 4, sizeof(GLubyte));
  CGContextRef ctx;
  ctx = CGBitmapContextCreate(data, w, h, 8, w * 4, CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
  CGContextDrawImage(ctx, CGRectMake(0, 0, w, h), image);
  CGContextRelease(ctx);
  
  return data;
}

AngleDelta Utils::GetAngleDelta(int angle)
{
  if (! m_Angles)
  {
    // This will only be malloc-ed once, so just let it live until process ends
    m_Angles = (AngleDelta*) malloc(sizeof(AngleDelta) * (360 / TURN_DELTA));

    int angle = 0;
    int i = 0;
    while (angle < 360)
    {
      m_Angles[i].dX = sin(angle * (PI / 180.0));
      m_Angles[i].dY = cos(angle * (PI / 180.0));
      i++;
      angle += TURN_DELTA;
    }
  }
  
  return m_Angles[angle / TURN_DELTA];
}

void Utils::TurnInDirection(int& curAngle, int targetAngle)
{
  if (curAngle != targetAngle)
  {
    float diff = targetAngle - curAngle;
    while (diff < -180) diff += 360;
    while (diff > 180) diff -= 360;
    if (diff < 0)
      curAngle -= TURN_DELTA;
    else 
      curAngle += TURN_DELTA;
    curAngle = (curAngle + 360) % 360;
  }
}

float Utils::CalculateDistance(Coords c1, Coords c2)
{
  float dist;
  
  dist = pow(abs(c1.x - c2.x), 2);
  dist += pow(abs(c1.y - c2.y), 2);
  dist = sqrt(dist);

  return dist;
}

void Utils::TextToSpriteCoords(string text, vector<Coords>& coords)
{
  int len = text.length();
  
  for (int i = 0; i < len; i++)
  {
    coords.push_back(CharToSpriteCoords(text[i]));
  }
}

Coords Utils::CharToSpriteCoords(char c)
{
  Coords coords = { 0, 7 }; // Empty font slot (i.e. space)
  if (c >= 'A' && c <= 'Z')
  {
    coords.x = (c - 'A') % 8;
    coords.y = (c - 'A') / 8;
  }
  else if (c >= '0' && c <= '9')
  {
    coords.x = (c - '0' + 7) % 8;
    coords.y = 3 + (c - '0' + 7) / 8;
  }
  else 
  {
    switch (c)
    {
      case '<':
        coords.x = 2;
        coords.y = 5;
        break;
      case '>':
        coords.x = 1;
        coords.y = 5;
        break;
      case '~': // 1 player sign
        coords.x = 4;
        coords.y = 5;
        break;
      case '`': // 2 player sign
        coords.x = 5;
        coords.y = 5;
        break;
      case '!':
        coords.x = 2;
        coords.y = 3;
        break;
      case '-':
        coords.x = 1;
        coords.y = 6;
        break;
      case '\'':
        coords.x = 0;
        coords.y = 6;
        break;
      case '#': // Restart symbol
        coords.x = 7;
        coords.y = 5;
        break;
      case '@': // Back symbol
        coords.x = 2;
        coords.y = 6;
        break;
      case '^': // Yellow snake head
        coords.x = 4;
        coords.y = 6;
        break;
      case '*': // Red snake head
        coords.x = 3;
        coords.y = 6;
        break;
      case '%': // Copyright symbol
        coords.x = 5;
        coords.y = 6;
        break;
      case '.':
        coords.x = 4;
        coords.y = 3;
        break;
      case '&':
        coords.x = 6;
        coords.y = 6;
        break;
      case ',':
        coords.x = 5;
        coords.y = 3;
        break;
      case ':':
        coords.x = 3;
        coords.y = 5;
        break;
      case '+': // Pause button
        coords.x = 7;
        coords.y = 6;
        break;
    }
  }
  return coords;
}

bool Utils::IsiPad()
{
  if (m_IsiPad == -1)
  {
    NSString* model = [[UIDevice currentDevice] model];
    
    m_IsiPad = [model compare: @"iPad"] == NSOrderedSame ? 1 : 0;
    m_IsiPad |= [model compare: @"iPad Simulator"] == NSOrderedSame ? 1 : 0;
  }
  
  return m_IsiPad == 1;
}

/*
void Utils::TurnInDirection(int& curAngle, int targetAngle)
{
  if (curAngle != targetAngle)
  {
    // Not sure this is correct - will do for now - revisit.
    if (curAngle - targetAngle < 0)
      curAngle += TURN_DELTA;
    else 
      curAngle -= TURN_DELTA;
    if (curAngle >= 360)
      curAngle -= 360;
    else if (curAngle < 0)
      curAngle += 360;
  }
}
*/