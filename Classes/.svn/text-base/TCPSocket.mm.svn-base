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

#import "TCPSocket.h"

@implementation TCPSocket

@synthesize port = m_Port, delegate = m_Delegate, peerAddress = m_PeerAddress,
            inputStream = m_InputStream, outputStream = m_OutputStream;

- (id) init
{
  m_Socket = nil;
  m_Source = nil;
  m_InPacketSize = 0;
  m_InBytesRead = 0;
  m_OutPacketSize = 0;
  m_OutBytesWritten = 0;
  m_OutStreamReady = NO;
  m_InputStream = nil;
  m_OutputStream = nil;
  m_PeerAddress = nil;
  m_ClientSocket = nil;
  
  return [super init];
}

static void newClientConnection(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
  if (type == kCFSocketAcceptCallBack)
  {
    // TODO: Move to member variable and close on end of session
    CFSocketNativeHandle snh = *(CFSocketNativeHandle*) data;
    
    CFReadStreamRef read = NULL;
    CFWriteStreamRef write = NULL;
    
    TCPSocket* inst = (TCPSocket*) info;
    CFStreamCreatePairWithSocket(kCFAllocatorDefault, snh, &read, &write);
    if (read && write)
    {
      inst.peerAddress = (NSData*) address;

      [inst setStreams: snh: (NSInputStream*) read: (NSOutputStream*) write];
      [inst openStreams];
      
      [inst.delegate didConnectWithClient];
    }
    else
    {
      [inst.delegate didError: TCPSocketErrorClientConnectionFailue];
      close(snh);
    }
    if (read) CFRelease(read);
    if (write) CFRelease(write);
  }
}

- (BOOL) createListener
{
  CFSocketContext ctxSocket = {0, self, NULL, NULL, NULL};
  
  m_Socket = NULL;
  m_Socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, (CFSocketCallBack) &newClientConnection, &ctxSocket);
  
  if (! m_Socket)
  {
    return NO;
  }
  
  int yes = 1;
  setsockopt(CFSocketGetNative(m_Socket), SOL_SOCKET, SO_REUSEADDR, (void*) &yes, sizeof(int));
  
  sockaddr_in addr;
  
  memset(&addr, 0, sizeof(sockaddr_in));
  addr.sin_len = sizeof(sockaddr_in);
  addr.sin_family = AF_INET;
  addr.sin_port = 0; // Kernel will assign a free port
  addr.sin_addr.s_addr = htonl(INADDR_ANY);
  NSData *nsAddr = [NSData dataWithBytes: &addr length: sizeof(sockaddr_in)];
  
  if (CFSocketSetAddress(m_Socket, (CFDataRef) nsAddr) != kCFSocketSuccess)
  {
    if (m_Socket)
      CFRelease(m_Socket);
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

- (BOOL) createFromNetService: (NSNetService*) service
{
  sockaddr_storage s;
  int idx = -1;
  for (int i = 0; i < [[service addresses] count]; i++)
  {
    memcpy(&s, [[[service addresses] objectAtIndex: i] bytes], [[[service addresses] objectAtIndex: i] length]);
    if (s.ss_family == AF_INET)
    {
      idx = i;
      break;
    }
  }
  if (idx < 0)
    return NO;
  
  if (! [service getInputStream: &m_InputStream outputStream: &m_OutputStream])
    return NO;
  
  [self openStreams];
  
  [self setPeerAddress: [service.addresses objectAtIndex: idx]];
  
  return YES;
}

- (void) close
{
  [self closeStreams];
  
  if (m_ClientSocket)
  {
    close(m_ClientSocket);
    m_ClientSocket = nil;
  }
  
  if (m_Socket != nil)
  {
    CFSocketInvalidate(m_Socket);
    CFRelease(m_Socket);
    m_Socket = nil;
  }
   
  if (m_Source != nil)
  {
    CFRunLoopSourceInvalidate(m_Source);
    CFRunLoopRef cfrl = CFRunLoopGetCurrent();
    CFRunLoopRemoveSource(cfrl, m_Source, kCFRunLoopCommonModes);
    CFRelease(m_Source);
    m_Source = nil;
  }
  
  if (m_PeerAddress != nil)
  {
    [m_PeerAddress release];
    m_PeerAddress = nil;
  }
}

- (BOOL) openStreams
{
  int i = [self.inputStream retainCount];
	m_InputStream.delegate = self;
  i = [self.inputStream retainCount];
	[m_InputStream scheduleInRunLoop: [NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
  i = [self.inputStream retainCount];
	[m_InputStream open];
  i = [self.inputStream retainCount];
	m_OutputStream.delegate = self;
	[m_OutputStream scheduleInRunLoop: [NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
	[m_OutputStream open];
  
  m_InPacketSize = 0;
  m_InBytesRead = 0;
  m_OutPacketSize = 0;
  m_OutBytesWritten = 0;
    
  return YES;
}

- (void) closeStreams
{
  if (self.inputStream != nil)
  {
    [self.inputStream close];
    self.inputStream = nil;
  }
  if (self.outputStream != nil)
  {
    [self.outputStream close]; 
    self.outputStream = nil;
  }
}

- (BOOL) sendData: (NSData *) data
{
  if (data.length > 255)
  {
    return NO;
  }
  if (m_OutPacketSize != 0)
  {
    return NO;
  }
  //if (! [m_OutputStream hasSpaceAvailable])
  //  NSLog(@"No space");
  
  m_OutPacketSize = data.length;
  m_OutPacketBuf[0] = m_OutPacketSize;
  memcpy(&m_OutPacketBuf[1], data.bytes, m_OutPacketSize);
  m_OutPacketSize++;
  
  int written;
  
  written = [m_OutputStream write: (uint8_t*) &m_OutPacketBuf maxLength: m_OutPacketSize];
  if (written == m_OutPacketSize)
  {
    m_OutPacketSize = 0;
    return YES;
  }
  else
  {
    m_OutBytesWritten = written;
  }
  
  return YES;
}

- (void) setStreams: (CFSocketNativeHandle) clientSocket: (NSInputStream*) inputStream: (NSOutputStream*) outputStream
{
  m_ClientSocket = clientSocket;
  self.inputStream = inputStream;
  self.outputStream = outputStream;
}

- (void) dealloc
{
  [self close];
  
  [super dealloc];
}

#pragma mark NSStreamDelegate Methods

- (void) stream: (NSStream*) stream handleEvent: (NSStreamEvent) eventCode
{
  if (eventCode == NSStreamEventHasBytesAvailable)
  {
    int read;
    
    while (TRUE)
    {
      if (m_InPacketSize == 0)
      {
        m_InBytesRead = 0;
        read = [m_InputStream read: (uint8_t*) &m_InPacketSize maxLength: 1];
        if (read < 1)
          return;
      }
      
      int read = [m_InputStream read: (uint8_t*) &m_InPacketBuf[m_InBytesRead] maxLength: m_InPacketSize - m_InBytesRead];
      if (read < 1)
        return;
      if (read == m_InPacketSize - m_InBytesRead)
      {
        [self.delegate didReceiveData: &m_InPacketBuf: m_InPacketSize];
        m_InPacketSize = 0;
        return;
      }
      else if (read < m_InPacketSize - m_InBytesRead)
      {
        m_InBytesRead += read;
        return;
      }
      else
      {
        return;
      }
    }
  }
  else if (eventCode == NSStreamEventHasSpaceAvailable)
  {
    if (stream == m_OutputStream)
    {
      if (! m_OutStreamReady)
      {
        m_OutStreamReady = YES;
        [self.delegate didConnect];
      }
      if (m_OutPacketSize > 0)
      {
        int written = [m_OutputStream write: (uint8_t*) &m_OutPacketBuf[m_OutBytesWritten] maxLength: m_OutPacketSize - m_OutBytesWritten];
        if (written == m_OutPacketSize - m_OutBytesWritten)
        {
          m_OutPacketSize = 0;
          return;
        }
        else
          m_OutBytesWritten += written;
      }
    }
  }
  else if (eventCode == NSStreamEventErrorOccurred)
  {
    [self.delegate didError: TCPSocketErrorStreamError];
  }
  else if (eventCode == NSStreamEventOpenCompleted)
  {
    if (m_InputStream.streamStatus == NSStreamStatusOpen && m_OutputStream.streamStatus == NSStreamStatusOpen)
    {
      //NSLog(@"Both connected");
    }
  }
  else if (eventCode == NSStreamEventEndEncountered)
  {
    [self.delegate didError: TCPSocketErrorClosedByPeer];
  }
}

@end