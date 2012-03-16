//
//  GenericXMLMessage.m
//  AuroraPhone
//	Abstract: represents a <message> element.
//  users.
//	Version: 1.0

/*
 Copyright (c) 2011, Verizon Inc.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list
 of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this
 list of conditions and the following disclaimer in the documentation and/or other
 materials provided with the distribution.
 Neither the name of the Verizon Inc. nor the names of its contributors may be
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
#import "GenericXMLMessage.h"
#import "DDLog.h"
#import "NSXMLElement+GenericXML.h"

#import <objc/runtime.h>

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

/**
 * The GenericXMLMessage class represents a <message> element.
 * It extends GenericXMLElement, which in turn extends NSXMLElement.
 * All <message> elements that go in and out of the
 * GenericXML stream will automatically be converted to GenericXMLMessage objects.
 * 
 * This class exists to provide developers an easy way to add functionality to message processing.
 * Simply add your own category to GenericXMLMessage to extend it with your own custom methods.
 **/
@implementation GenericXMLMessage

/*
+ (void)initialize
{
	// We use the object_setClass method below to dynamically change the class from a standard NSXMLElement.
	// The size of the two classes is expected to be the same.
	// 
	// If a developer adds instance methods to this class, bad things happen at runtime that are very hard to debug.
	// This check is here to aid future developers who may make this mistake.
	// 
	// For Fearless And Experienced Objective-C Developers:
	// It may be possible to support adding instance variables to this class if you seriously need it.
	// To do so, try realloc'ing self after altering the class, and then initialize your variables.
	
	size_t superSize = class_getInstanceSize([NSXMLElement class]);
	size_t ourSize   = class_getInstanceSize([GenericXMLMessage class]);
	
	if (superSize != ourSize)
	{
		DDLogVerbose(@"Adding instance variables to GenericXMLMessage is not currently supported!");
		exit(15);
	}
}
 */

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Encoding, Decoding
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if ! TARGET_OS_IPHONE
- (id)replacementObjectForPortCoder:(NSPortCoder *)encoder
{
	if([encoder isBycopy])
		return self;
	else
		return [NSDistantObject proxyWithLocal:self connection:[encoder connection]];
}
#endif

- (id)initWithCoder:(NSCoder *)coder
{
	NSString *xmlString;
	if([coder allowsKeyedCoding])
	{
		xmlString = [coder decodeObjectForKey:@"xmlString"];
	}
	else
	{
		xmlString = [coder decodeObject];
	}
	
	return [super initWithXMLString:xmlString error:nil];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	NSString *xmlString = [self XMLString];
	
	if([coder allowsKeyedCoding])
	{
		[coder encodeObject:xmlString forKey:@"xmlString"];
	}
	else
	{
		[coder encodeObject:xmlString];
	}
}

//! Converts an NSXMLElement to an GenericXMLMessage element in place 
//! (no memory allocations or copying)
+ (GenericXMLMessage *)messageFromElement:(NSXMLElement *)element
{
	object_setClass(element, [GenericXMLMessage class]);
	
	return (GenericXMLMessage *)element;
}

//! Creates a mew receipt message with element "received"
- (GenericXMLMessage *)generateReceiptResponse
{
	// Example:
	// 
	// <message to="juliet">
	//   <received xmlns="urn:GenericXML:receipts" id="ABC-123"/>
	// </message>
	
	NSXMLElement *received = [NSXMLElement elementWithName:@"received" xmlns:@"urn:GenericXML:receipts"];
	
	NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
	
	[message addChild:received];
	
	return [[self class] messageFromElement:message];
}

-(NSXMLElement *) serialize
{
    // Example:
	// 
	// <message to="juliet">
	//   <received xmlns="urn:GenericXML:receipts" id="ABC-123"/>
	// </message>
	
	NSXMLElement *received = [NSXMLElement elementWithName:@"received" xmlns:@"urn:GenericXML:receipts"];
	
	NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
	
	[message addChild:received];
	
	return message;
}

-(void) deSerialize:(NSXMLElement *)xmlData runtimeGenerator:(objCRuntimeClassGenerator*)rtGenerator
{
	// DO nothing
}

@end
