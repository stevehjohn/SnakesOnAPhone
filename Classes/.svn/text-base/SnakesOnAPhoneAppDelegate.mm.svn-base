/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <QuartzCore/CAEAGLLayer.h>

#import "SnakesOnAPhoneAppDelegate.h"
#import "GL2DView.h"

@implementation SnakesOnAPhoneAppDelegate

@synthesize window;

-(void) applicationDidFinishLaunching: (UIApplication *) application {
	
  [application setStatusBarOrientation: UIInterfaceOrientationLandscapeRight];
  [application setStatusBarHidden: TRUE];
  
  // Create the application's window
  window = [[UIWindow alloc] init];
  // Get the size of the device's screen
  CGRect bounds = [[UIScreen mainScreen] bounds];
  [window setFrame: bounds];

  // Create a new view object, the size of the window
  view = [[UIViewGL alloc] init];
  [view setFrame: bounds];
  [window addSubview: view];
  
  [window makeKeyAndVisible];
  
  [view setMultipleTouchEnabled: TRUE];  
  
  // Set the EAGLContext
  // This should not change, so we set it here and can hopefully use just OpenGLES
  // functions without any Objective-C required 
  CAEAGLLayer* layer = (CAEAGLLayer *) view.layer;
  layer.opaque = TRUE;
  // Do not retain contents after displaying them
  // Set colour format (32bit)
  layer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys: 
                              [NSNumber numberWithBool: TRUE], kEAGLDrawablePropertyRetainedBacking,
                              kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
  
  // Get the context for OpenGL ES
  context = [EAGLContext alloc];
  // Request Open GL ES v1 for most compatibility
  [context initWithAPI:kEAGLRenderingAPIOpenGLES1];
  // Ensure the EAGLContext is the one we've just created
  [EAGLContext setCurrentContext: context];
  
  // Create the 2D renderer
  renderer = new GL2DView(context, layer);
  Colour c = {0.0, 0.0, 0.0, 1.0};
  renderer->SetBGColour(c);
  
  // Start the app!
  app = new AppController(renderer);
  // Register app for touches
  [view addTouchReceiver: app];
  app->Start();
}

// Started up or resumed from interruption
- (void) applicationDidBecomeActive: (UIApplication*) application
{
  app->Resumed();
}

// Temporary iterruption (phone call, SMS etc.)
// Just pause the game
- (void) applicationWillResignActive: (UIApplication*) application
{
  app->Interrupted();
}

// More permanent interruption (user switched to other app or pressed home button)
// Pause the game or quit if multiplayer (to release the sockets)
- (void) applicationDidEnterBackground: (UIApplication*) application
{
  app->Backgrounded();
}

// What it says on the tin
- (void) applicationWillTerminate: (UIApplication*) application
{
  // Just let nature take its course
}

- (void)dealloc {
  delete app;
  delete renderer;
  [context release];
  [view release];
  [window release];
  [super dealloc];
}

@end
