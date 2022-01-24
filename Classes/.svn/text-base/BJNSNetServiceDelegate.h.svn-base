/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "Foundation/NSNetServices.h"
#import "ISessionManager.h"
#import "UITableAlertView.h"
#import "IBJNSNetServiceDelegateWrapper.h"
#import "TCPSocket.h"
#import "UDPSocket.h"

// Use in Terminal to monitor Bonjour comings and goings:
//   dns-sd -B _snakesoap
// Use in Terminal to view port information (sudo it)
//   lsof -i 

// tcpdump is useful too

// Note: only supports packets up to 255 bytes at the moment
// Note: never send data beginning with 0 - this packet id is reserved for internal use
// Note: UDP bufferes tuned for snakes. See didReceiveData and didConnect for values

@interface BJNSNetServiceDelegate : NSObject<NSNetServiceDelegate, NSNetServiceBrowserDelegate, UITableAlertViewDelegate, TCPSocketDelegate, UDPSocketDelegate>
{
@private
  NSNetService* m_Service;
  NSNetServiceBrowser* m_Browser;
  UITableAlertView* m_Picker;
  NSMutableArray* m_Games;
  IBJNSNetServiceDelegateWrapper* m_Wrapper;
  NSNetService* m_Resolver;
  
  TCPSocket* m_TCPSocket;
  UDPSocket* m_Sender;
  UDPSocket* m_Receiver;
  
  BOOL m_IsServer;
}

- (id) initWithWrapper: (IBJNSNetServiceDelegateWrapper*) wrapper;
- (BOOL) createServer;
- (BOOL) advertise;
- (void) stopAdvertising;
- (BOOL) search;
- (void) stopSearching;
- (void) endSession;
- (void) updateUI;
- (void) sendData: (NSData*) data: (BOOL) reliable;

@property (nonatomic, retain) NSNetService* service;
@property (nonatomic, retain) NSNetServiceBrowser* browser;
@property (nonatomic, retain) UITableAlertView* picker;
@property (nonatomic, retain) NSMutableArray* games;
@property (nonatomic, retain) TCPSocket* tcpSocket;
@property (nonatomic, retain) UDPSocket* udpSender;
@property (nonatomic, retain) UDPSocket* udpReceiver;
@property (nonatomic, retain) NSNetService* resolver;

@end