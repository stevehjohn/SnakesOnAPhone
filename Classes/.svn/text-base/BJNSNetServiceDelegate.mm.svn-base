/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "Constants.h"

#import "BJNSNetServiceDelegate.h"

@implementation BJNSNetServiceDelegate

@synthesize service = m_Service, browser = m_Browser, picker = m_Picker, games = m_Games, resolver = m_Resolver,
            tcpSocket = m_TCPSocket, udpSender = m_Sender, udpReceiver = m_Receiver;

- (id) initWithWrapper: (IBJNSNetServiceDelegateWrapper*) wrapper
{
  m_Service = nil;
  m_Browser = nil;
  m_Picker = nil;
  m_Games = nil;
  m_Sender = nil;
  m_Receiver = nil;
  m_Resolver = nil;
  
  m_Wrapper = wrapper;
  
  return [super init];
}

- (BOOL) createServer
{
  self.tcpSocket = [[TCPSocket alloc] init];
  [self.tcpSocket release];
  self.tcpSocket.delegate = self;
  
  return [self.tcpSocket createListener];
}

- (BOOL) advertise
{
  m_IsServer = YES;
  
  if (! [self createServer])
    return NO;
  
  self.service = [[NSNetService alloc] initWithDomain: @"" type: @NET_SERVICE_TYPE name: @"" port: self.tcpSocket.port];
  if (self.service == nil)
  {
    [self.tcpSocket close];
    return NO;
  }
  [self.service release];

	[self.service setDelegate: self];
	[self.service scheduleInRunLoop: [NSRunLoop currentRunLoop] forMode: NSRunLoopCommonModes];
	[self.service publish];
  
  return YES;
}

- (void) stopAdvertising
{
  if (self.service != nil)
  {
    [self.service stop];
    [self.service removeFromRunLoop: [NSRunLoop currentRunLoop] forMode: NSRunLoopCommonModes];
    self.service = nil;
  }
}

- (BOOL) search
{
  m_IsServer = NO;
  
  self.games = [NSMutableArray arrayWithCapacity: 5];
  
  self.browser = [[NSNetServiceBrowser alloc] init];
  [self.browser release];
  if (! self.browser)
    return NO;
  
  [self.browser setDelegate: self];
	[self.browser scheduleInRunLoop: [NSRunLoop currentRunLoop] forMode: NSRunLoopCommonModes];
  [self.browser searchForServicesOfType: @NET_SERVICE_TYPE inDomain: @""];
  
  self.picker = [[UITableAlertView alloc] init];
  [self.picker release];
  self.picker.delegate = self;
  
  [self.picker show];
  
  return YES;
}

- (void) stopSearching
{
  if (self.browser != nil)
  {
    [self.browser stop];
    [self.browser removeFromRunLoop: [NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.browser = nil;
  }
  
  if (self.games != nil)
  {
    [self.games removeAllObjects];
    self.games = nil;
  }

  if (self.picker != nil)
  {
    [self.picker dismissWithClickedButtonIndex: 0 animated: YES];
    self.picker = nil;
  }
}

- (void) endSession
{
  [self stopAdvertising];
  [self stopSearching];
  
  [self.tcpSocket close];
  self.tcpSocket = nil;
  [self.udpSender close];
  self.udpSender = nil;
  [self.udpReceiver close];
  self.udpReceiver = nil;
  
  if (self.resolver != nil)
  {
    [self.resolver stop];
    self.resolver = nil;
  }
}

- (void) updateUI
{
  [self.picker clearItems];
  
  for (int i = 0; i < self.games.count; i++)
  {
    NSNetService* svc = [self.games objectAtIndex: i];
    [self.picker addItem: svc.name: svc.name];
  }
  
  [self.picker refresh];
}

- (void) sendData: (NSData*) data: (BOOL) reliable
{
  if (reliable)
    [self.tcpSocket sendData: data];
  else
  {
    [self.udpSender sendData: data];
  }
}

#pragma mark UITableAlertViewDelegate Methods

- (void) didCancel
{
  [self stopSearching];
  m_Wrapper->SearchCancelled();
}

- (void) didSelectItem: (id) key
{  
  NSNetService* game = nil;
  for (int i = 0; i < self.games.count; i++)
  {
    game = [self.games objectAtIndex: i];
    if (game.name == key)
    {
      game = [self.games objectAtIndex: i];
      break;
    }
    game = nil;
  }
  if (game != nil)
  {
    self.resolver = game;
    [self.resolver setDelegate: self];
    [self.resolver resolveWithTimeout: BONJOUR_RESOLVE_TIMEOUT];
  }
  
  [self stopSearching];

  m_Wrapper->ServerSelected();
}

#pragma mark TCPSocketDelegate Methods

- (void) didReceiveData: (void*) data: (int) length
{
  char* cdata = (char*) data;
  if (length == 3 && cdata[0] == 0)
  {
    // First transmission from other party - set up our UDP sender
    self.udpSender = [[UDPSocket alloc] init];
    [self.udpSender release];
    self.udpSender.delegate = self;
    uint16_t port;
    memcpy(&port, &cdata[1], 2);
        
    int sendbuf = 20; // 20
    int recvbuf = 0;
    if (m_IsServer)
    {
      sendbuf = 255; // 255
      recvbuf = 0;
    }
    [m_Sender createConnected: [m_TCPSocket peerAddress] : port : sendbuf : recvbuf];
    
    m_Wrapper->SessionStarted();
  }
  else
  {
    m_Wrapper->DataReceived(data, length);
  }
}

- (void) didConnect
{
  self.udpReceiver = [[UDPSocket alloc] init];
  [self.udpReceiver release];
  self.udpReceiver.delegate = self;
  
  int sendbuf = 0;
  int recvbuf = 255; // 255
  if (m_IsServer)
  {
    sendbuf = 0;
    recvbuf = 20; // 20
  }
  [m_Receiver createListener: sendbuf: recvbuf];
  
  char data[3];
  data[0] = 0;
  uint16_t port = [m_Receiver port];
  memcpy(&data[1], &port, 2);
  [m_TCPSocket sendData: [NSData dataWithBytes: data length: 3]];  
}

- (void) didError: (TCPSocketError) error
{
  switch (error)
  {
    case TCPSocketErrorClientConnectionFailue:
      m_Wrapper->Error(SessionErrorDidNotConnect);
      break;
    case TCPSocketErrorStreamError:
      m_Wrapper->Error(SessionErrorConnectionError);
      break;
    case TCPSocketErrorClosedByPeer:
      m_Wrapper->Error(SessionErrorConnectionClosed);
      break;
  }
}

- (void) didConnectWithClient
{
  [self stopAdvertising];
}

#pragma mark NSNetServiceDelegate Methods

- (void) netServiceDidPublish: (NSNetService *) sender
{
}

- (void) netService: (NSNetService *) sender didNotPublish: (NSDictionary *) errorDict
{
  m_Wrapper->Error(SessionErrorDidNotAdvertise);
  [self stopAdvertising];
}

- (void) netServiceDidResolveAddress: (NSNetService*) sender
{
  [sender stop];
  
  self.tcpSocket = [[TCPSocket alloc] init];
  [self.tcpSocket release];
  self.tcpSocket.delegate = self;
  if (! [self.tcpSocket createFromNetService: sender])
  {
    m_Wrapper->Error(SessionErrorDidNotConnect);
  }
}

- (void) netService: (NSNetService*) sender didNotResolve: (NSDictionary *) errorDict
{
  [sender stop];
  m_Wrapper->Error(SessionErrorDidNotResolve);
}

#pragma mark NSNetServiceBrowser Methods

- (void) netServiceBrowser: (NSNetServiceBrowser*) netServiceBrowser didFindService: (NSNetService*) service moreComing: (BOOL) moreComing
{
  [self.games addObject: service];
  
  if (! moreComing)
    [self updateUI];
}

- (void) netServiceBrowser: (NSNetServiceBrowser*) netServiceBrowser didRemoveService: (NSNetService*) netService moreComing: (BOOL) moreServicesComing
{
  [self.games removeObject: netService];
  
  if (! moreServicesComing)
    [self updateUI];
}

- (void) netServiceBrowser: (NSNetServiceBrowser*) netServiceBrowser didNotSearch: (NSDictionary*) errorInfo
{
  m_Wrapper->Error(SessionErrorDidNotSearch);
  [self stopSearching];
}
  
@end