/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <sys/socket.h>
#import <netinet/in.h>
#import <unistd.h>
#import <fcntl.h>

#import "UDPSocket.h"

@implementation UDPSocket

@synthesize port = m_Port, delegate = m_Delegate;

- (id) init
{
  m_LastRevcPacketID = 0;
  m_LastSendPacketID = 0;
  m_Socket = nil;
  m_Source = nil;
  
  return [super init];
}

//static double prev = 0;
//static int count = 0;

- (void) readData
{ 
  /*
  if (prev == 0)
  {
    prev = [NSDate timeIntervalSinceReferenceDate];
  }
  else
  {
    count++;
    double newtime = [NSDate timeIntervalSinceReferenceDate];
    double diff = newtime - prev;
    prev = newtime;
    
    if (diff > 0.2)
    {
      if (count > 1)
      {
        NSLog(@"%i packets RCVD with < 0.2 time delta", count);
      }
      NSLog(@"  This packet time delta: %f", diff);
      count = 0;
    }
  }*/
  
  int sockRef = CFSocketGetNative(m_Socket);
  
  uint8_t tmpbuffer[255];
  uint8_t outbuffer[255];
  
  // Get only the most recent packet
  ssize_t lastread = 0;
  while (TRUE)
  {
    ssize_t read;
    read = recvfrom(sockRef, tmpbuffer, 255, MSG_DONTWAIT, NULL, 0);    
    if (read < 2)
      break;

    uint16_t pid;
    memcpy(&pid, tmpbuffer, sizeof(uint16_t));
    
    // (pid < 10000 && m_LastRevcPacketID > 55000) to cope with wrap arounds
    if (pid > m_LastRevcPacketID || m_LastRevcPacketID == 0 || (pid < 10000 && m_LastRevcPacketID > 55000))
    {
      lastread = read;
      memcpy(&outbuffer, &tmpbuffer, read);
      m_LastRevcPacketID = pid;
    }
  }
    
  if (lastread > 0)
    [self.delegate didReceiveData: &outbuffer[sizeof(uint16_t)]: lastread - sizeof(uint16_t)];
}

static void dataReceived(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
  UDPSocket* inst = (UDPSocket*) info;
  
  [inst readData];
}

- (BOOL) createSocket: (NSData*) address: (uint16_t) port: (int) sendBufferSize : (int) receiveBufferSize
{
  int sockRef = socket(AF_INET, SOCK_DGRAM, 0);
  
  if (sockRef < 0)
    return NO;
  
  sockaddr_in addr;
  memset(&addr, 0, sizeof(sockaddr_in));
  if (address == nil)
  {
    addr.sin_len = sizeof(sockaddr_in);
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    
    if (bind(sockRef, (sockaddr*) &addr, sizeof(sockaddr_in)) < 0)
    {
      close(sockRef);
      return NO;
    }
  }
  else 
  {
    [address getBytes: &addr length: sizeof(sockaddr_in)];
    addr.sin_port = htons(port);
    if (connect(sockRef, (sockaddr*) &addr, sizeof(sockaddr_in)) < 0)
    {
      close(sockRef);
      return NO;
    }
  }
  
  if (receiveBufferSize > 0)  
    setsockopt(sockRef, SOL_SOCKET, SO_RCVBUF, &receiveBufferSize, sizeof(receiveBufferSize));
  if (sendBufferSize > 0)
    setsockopt(sockRef, SOL_SOCKET, SO_SNDBUF, &sendBufferSize, sizeof(sendBufferSize));
  
  const CFSocketContext context = { 0, self, NULL, NULL, NULL };
  m_Socket = CFSocketCreateWithNative(NULL, sockRef, kCFSocketReadCallBack, (CFSocketCallBack) &dataReceived, &context);

  int flags;
  flags = fcntl(sockRef, F_GETFL);
  if (fcntl(sockRef, F_SETFL, flags | O_NONBLOCK))
  {
    close(sockRef);
    return NO;
  }
  
  NSData *actAddr = [(NSData *) CFSocketCopyAddress(m_Socket) autorelease];
  memcpy(&addr, [actAddr bytes], [actAddr length]);
  m_Port = ntohs(addr.sin_port);

  CFRunLoopRef cfrl = CFRunLoopGetCurrent();
  m_Source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, m_Socket, 0);
  CFRunLoopAddSource(cfrl, m_Source, kCFRunLoopCommonModes);

  return YES;
}

- (BOOL) createListener: (int) sendBufferSize : (int) receiveBufferSize
{
  return [self createSocket: nil: 0: sendBufferSize: receiveBufferSize];
}

- (BOOL) createConnected: (NSData*) address: (uint16_t) port: (int) sendBufferSize : (int) receiveBufferSize
{
  return [self createSocket: address: port: sendBufferSize: receiveBufferSize];
}

//static double prevsent = 0;
//static int countsent = 0;

- (void) sendData: (NSData*) data
{
  /*
  if (prevsent == 0)
  {
    prevsent = [NSDate timeIntervalSinceReferenceDate];
  }
  else
  {
    countsent++;
    double newtime = [NSDate timeIntervalSinceReferenceDate];
    double diff = newtime - prevsent;
    prevsent = newtime;
    
    if (diff > 0.2)
    {
      if (countsent > 1)
      {
        NSLog(@"%i packets SENT with < 0.2 time delta", countsent);
      }
      NSLog(@"  This packet time delta: %f", diff);
      countsent = 0;
    }
  }*/

  int sockRef = CFSocketGetNative(m_Socket);
  
  if (m_LastSendPacketID < 65535)
    m_LastSendPacketID++;
  else
    m_LastSendPacketID = 1;

  int len = [data length] + sizeof(uint16_t);
  char* buf = (char*) malloc(len);
  memcpy(buf, &m_LastSendPacketID, sizeof(m_LastSendPacketID));
  memcpy(&buf[sizeof(uint16_t)], [data bytes], [data length]);
  
  sendto(sockRef, buf, len, MSG_DONTWAIT, NULL, 0);
}

- (void) close
{
  if (m_Source != nil)
  {
    CFRunLoopSourceInvalidate(m_Source);
    CFRunLoopRef cfrl = CFRunLoopGetCurrent();
    CFRunLoopRemoveSource(cfrl, m_Source, kCFRunLoopCommonModes);
    CFRelease(m_Source);
    m_Source = nil;
  }
  if (m_Socket != nil)
  {
    CFSocketInvalidate(m_Socket);
    CFRelease(m_Socket);
    m_Socket = nil;
  }
}

- (void) dealloc
{
  [self close];
  
  [super dealloc];
}

@end