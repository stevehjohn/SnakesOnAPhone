/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

@protocol UDPSocketDelegate

- (void) didReceiveData: (void*) data: (int) length;

@end

// Note: Automatically discards older packets arriving after newer ones

@interface UDPSocket : NSObject
{
@private
  uint16_t m_Port;
  CFSocketRef m_Socket;
  CFRunLoopSourceRef m_Source;
  
  id <UDPSocketDelegate> m_Delegate;
  
  uint16_t m_LastRevcPacketID;
  uint16_t m_LastSendPacketID;
}

- (BOOL) createListener: (int) sendBufferSize : (int) receiveBufferSize;
- (BOOL) createConnected: (NSData*) address: (uint16_t) port: (int) sendBufferSize : (int) receiveBufferSize;
- (void) sendData: (NSData*) data;
- (void) close;

@property (readonly) uint16_t port;
@property (nonatomic, assign) id <UDPSocketDelegate> delegate;

@end