/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

typedef enum
{
  TCPSocketErrorClientConnectionFailue = 0,
  TCPSocketErrorStreamError,
  TCPSocketErrorClosedByPeer,
} TCPSocketError;

@protocol TCPSocketDelegate

- (void) didReceiveData: (void*) data: (int) length;
- (void) didConnect;
- (void) didError: (TCPSocketError) error;
- (void) didConnectWithClient;

@end

@interface TCPSocket : NSObject<NSStreamDelegate>
{
@private
  CFSocketRef m_Socket;
  CFRunLoopSourceRef m_Source;
  uint16_t m_Port;
  CFSocketNativeHandle m_ClientSocket;

  NSInputStream* m_InputStream;
  NSOutputStream* m_OutputStream;

  char m_InPacketBuf[255];
  char m_InPacketSize;
  char m_InBytesRead;
  char m_OutPacketBuf[255];
  char m_OutPacketSize;
  char m_OutBytesWritten;
  
  BOOL m_OutStreamReady;
  
  id <TCPSocketDelegate> m_Delegate;
  
  NSData* m_PeerAddress;
}

- (BOOL) createListener;
- (BOOL) createFromNetService: (NSNetService*) service;
- (void) close;
- (BOOL) openStreams;
- (void) closeStreams;
- (BOOL) sendData: (NSData*) data;
- (void) setStreams: (CFSocketNativeHandle) clientSocket: (NSInputStream*) inputStream: (NSOutputStream*) outputStream;

@property (readonly, assign) uint16_t port;
@property (nonatomic, assign) id <TCPSocketDelegate> delegate;
@property (nonatomic, retain) NSData* peerAddress;
@property (nonatomic, retain) NSInputStream* inputStream;
@property (nonatomic, retain) NSOutputStream* outputStream;

@end