//
//  GenericXMLParser.h
//  GenericXMLParser
//	Abstract: A class to parse the GenericXML stream and provide convenience methods for parsing.
//  users.
//	Version: 1.0

/*
 Copyright (c) 2011, Research2Development.org Inc.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list
 of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this
 list of conditions and the following disclaimer in the documentation and/or other
 materials provided with the distribution.
 Neither the name of the Research2Development.org Inc. nor the names of its contributors may be
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
#import <libxml2/libxml/parser.h>
#import "DDXMLElement.h"
#import "GenericXMLMessage.h"

#if TARGET_OS_IPHONE
  #import "DDXML.h"
#endif

//! A class to parse the GenericXML stream and provide convenience methods for parsing
@interface GenericXMLParser : NSObject
{
	id delegate;
	
	BOOL hasReportedRoot;
	unsigned depth;
	
	xmlParserCtxt *parserCtxt;
	
	BOOL stopped;
	
	NSThread *streamThread;
	NSThread *parsingThread;
}

- (id)initWithDelegate:(id)delegate;

/**
 * Asynchronously parses the given data.
 * The delegate methods will be called as elements are fully read and parsed.
**/
- (void)parseData:(NSData *)data;

/**
 * You must call this method before releasing the parser.
 * This will stop any asynchronous parsing, and ensure that no further delegate methods are invoked.
 * 
 * Failure to call this method will also leak the parser object.
**/
- (void)stop;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol GenericXMLParserDelegate
@optional

- (void)Parser:(GenericXMLParser *)sender didReadRoot:(NSXMLElement *)root;

- (void)Parser:(GenericXMLParser *)sender didReadElement:(NSXMLElement *)element;

- (void)ParserDidEnd:(GenericXMLParser *)sender;

- (void)Parser:(GenericXMLParser *)sender didFail:(NSError *)error;

- (void)Parser:(GenericXMLParser *)sender didParseDataOfLength:(NSUInteger)length;

@end
