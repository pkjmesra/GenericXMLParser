/*
 Copyright (c) 2011, Research2Development Inc.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list
 of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this
 list of conditions and the following disclaimer in the documentation and/or other
 materials provided with the distribution.
 Neither the name of the Research2Development Inc. nor the names of its contributors may be
 used to endorse or promote products derived from this software without specific
 prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 OF THE POSSIBILITY OF SUCH DAMAGE."
 */
#import <Foundation/Foundation.h>
#import "MulticastDelegate.h"
#if TARGET_OS_IPHONE
  #import "DDXML.h"
#endif

@class GenericXMLParser;
@class GenericXMLMessage;
@class objCRuntimeClassGenerator;
@protocol GenericXMLStreamDelegate;

@interface GenericXMLStream : NSObject
{
	MulticastDelegate <GenericXMLStreamDelegate> *multicastDelegate;
	
	NSXMLElement *rootElement;
	GenericXMLParser *_parser;
    objCRuntimeClassGenerator * _runtimeGenerator;
    id _generatedClass;
    NSMutableArray * _parsedElements;
}

@property (nonatomic,retain) objCRuntimeClassGenerator * runtimeGenerator;
@property (nonatomic,retain) id generatedClass;
@property (nonatomic,retain) GenericXMLParser *parser;
@property (nonatomic,retain) NSMutableArray * parsedElements;
/**
 Parses the UTF8 encoded xml data
 */
-(void) parseUTF8XMLData:(NSData *)data;

/**
 * Standard  initialization.
 * The stream is a standard client to server connection.
 * 
 * P2P streams using XEP-0174 are also supported.
 * See the P2P section below.
**/
- (id)init;

/**
 * Stream uses a multicast delegate.
 * This allows one to add multiple delegates to a single Stream instance,
 * which makes it easier to separate various components and extensions.
 * 
 * For example, if you were implementing two different custom extensions on top of ,
 * you could put them in separate classes, and simply add each as a delegate.
**/
- (void)addDelegate:(id)delegate;
- (void)removeDelegate:(id)delegate;


/**
 * This method will return the root element of the document.
 * This element contains the opening <stream:stream/> and <stream:features/> tags received from the server.
 * 
 * If multiple <stream:features/> have been received during the course of stream negotiation,
 * the root element contains only the most recent (current) version.
 * 
 * Note: The rootElement is "empty", in so much as it does not contain all the XML elements the stream has
 * received during it's connection. This is done for performance reasons and for the obvious benefit
 * of being more memory efficient.
**/
- (NSXMLElement *)rootElement;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol GenericXMLStreamDelegate
@optional

/**
 * There are two types of errors: TCP errors and  errors.
 * If a TCP error is encountered (failure to connect, broken connection, etc) a standard NSError object is passed.
 * If an  error is encountered (<stream:error> for example) an NSXMLElement object is passed.
 * 
 * Note that standard errors (<iq type='error'/> for example) are delivered normally,
 * via the other didReceive...: methods.
**/
- (void)Stream:(GenericXMLStream *)sender didReceiveError:(id)error;

/**
 * This method is called for every sendElement:andNotifyMe: method.
**/
- (void)Stream:(GenericXMLStream *)sender didSendElementWithTag:(UInt16)tag;

/**
 * This method is called if the disconnect method is called.
 * It may be used to determine if a disconnection was purposeful, or due to an error.
**/
- (void)StreamWasToldToDisconnect:(GenericXMLStream *)sender;

/**
 * This method is called after the stream is closed.
**/
- (void)StreamDidDisconnect:(GenericXMLStream *)sender;

/**
 * This method is called after the stream is finished parsing the data.
 **/
- (void)StreamDidFinishParsing:(GenericXMLStream *)sender 
				   RootNodeKey:(NSString*)rootKey 
				 inObjectGraph:(NSDictionary*)graph 
			  runtimeGenerator:(objCRuntimeClassGenerator *)rtGenerator;

- (void)StreamWillBeginParsing:(GenericXMLStream *)sender 
				   Elements:(NSArray*)nsXMLElements;
/**
 * These methods are called as  modules are registered and unregistered with the stream.
 * This generally corresponds to  modules being initailzed and deallocated.
 * 
 * The methods may be useful, for example, if a more precise auto delegation mechanism is needed
 * than what is available with the autoAddDelegate:toModulesOfClass: method.
**/
- (void)Stream:(GenericXMLStream *)sender didRegisterModule:(id)module;
- (void)Stream:(GenericXMLStream *)sender willUnregisterModule:(id)module;

@end
