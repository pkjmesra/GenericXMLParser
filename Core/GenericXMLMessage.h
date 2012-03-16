//
//  GenericXMLMessage.h
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
#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import "DDXML.h"
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
@class objCRuntimeClassGenerator;
@interface GenericXMLMessage : NSXMLElement <NSCoding>

//! Converts an NSXMLElement to an GenericXMLMessage element in place 
//! (no memory allocations or copying)
+ (GenericXMLMessage *)messageFromElement:(NSXMLElement *)element;

//! Creates a mew receipt message with element "received"
- (GenericXMLMessage *)generateReceiptResponse;

-(void) deSerialize:(NSXMLElement *)xmlData 
   runtimeGenerator:(objCRuntimeClassGenerator*)rtGenerator
;
@end
