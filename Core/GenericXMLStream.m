/*
 Copyright (c) 2011, Verizon.
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
#import "MulticastDelegate.h"
#import "GenericXMLParser.h"
#import "GenericXMLStream.h"
#import "DDLog.h"
#import "NSXMLElement+GenericXML.h"
#import "MARTNSObject.h"

#if TARGET_OS_IPHONE
  // Note: You may need to add the CFNetwork Framework to your project
  #import <CFNetwork/CFNetwork.h>
#endif

#import "DDLog.h"
#import "DDTTYLogger.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_INFO;//LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation GenericXMLStream

@synthesize runtimeGenerator =_runtimeGenerator;
@synthesize generatedClass =_generatedClass;
@synthesize parsedElements=_parsedElements;

/**
 * Shared initialization between the various init methods.
**/
- (void)commonInit
{
	multicastDelegate = (MulticastDelegate <GenericXMLStreamDelegate> *)[[MulticastDelegate alloc] init];
	
	parser = [(GenericXMLParser *)[GenericXMLParser alloc] initWithDelegate:self];
    _parsedElements = [[NSMutableArray alloc] initWithCapacity:0];
}

/**
 * Standard  initialization.
 * The stream is a standard client to server connection.
**/
- (id)init
{
	if ((self = [super init]))
	{
		// Common initialization
		[self commonInit];
	}
	return self;
}

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
- (NSXMLElement *)rootElement
{
    return rootElement;
}


/**
 * Standard deallocation method.
 * Every object variable declared in the header file should be released here.
**/
- (void)dealloc
{
	[multicastDelegate release];
	
	[parser stop];
	[parser release];
	
	[rootElement release];
	
	[super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Configuration
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)addDelegate:(id)delegate
{
	[multicastDelegate addDelegate:delegate];
}

- (void)removeDelegate:(id)delegate
{
	[multicastDelegate removeDelegate:delegate];
}

-(void) parseUTF8XMLData:(NSData *)data
{
    [parser parseData:data];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Parser Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Called when the  parser has read in the entire root element.
**/
- (void)Parser:(GenericXMLParser *)sender didReadRoot:(NSXMLElement *)root
{
//	DDLogInfo(@"Root compactXMLString: %@", [root compactXMLString]);
//	DDLogInfo(@"root prettyXMLString: %@", [root prettyXMLString]);
//    DDLogInfo(@"root: %@", root);
	// At this point we've sent our XML stream header, and we've received the response XML stream header.
	// We save the root element of our stream for future reference.
	// Digest Access authentication requires us to know the ID attribute from the <stream:stream/> element.
	
	[rootElement release];
	rootElement = [root retain];
    
    // Save the root element into the array for later runtime creation
    // Clear the array.Since this being the root element of this parsing
    // Root element must be at 0
    [self.parsedElements removeAllObjects];
    [self.parsedElements addObject:rootElement];
}

- (void)Parser:(GenericXMLParser *)sender didReadElement:(NSXMLElement *)element
{
	DDLogVerbose(@"Read child element = %@",[element compactXMLString]);
    [self.parsedElements addObject:element];
}

- (void)ParserDidEnd:(GenericXMLParser *)sender
{
    [multicastDelegate StreamWillBeginParsing:self Elements:(NSArray*)self.parsedElements];
    _runtimeGenerator = [[objCRuntimeClassGenerator alloc] init];
    [_runtimeGenerator addDelegate:self];
    
    //id rootClass = 
    [self.runtimeGenerator createRuntimeObjectPool:self.parsedElements];

    DDLogVerbose(@"object graph:%@",[self.runtimeGenerator getObjectGraph]);
}

- (void)Parser:(GenericXMLParser *)sender didFail:(NSError *)error
{
	[multicastDelegate Stream:self didReceiveError:error];
}

- (void)Parser:(GenericXMLParser *)sender didParseDataOfLength:(NSUInteger)length
{
	// The chunk we read has now been fully parsed.
	// Continue reading for XML elements.
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -objCRuntimeClassGeneratorDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)generator:(objCRuntimeClassGenerator *)sender didCreateUnregisteredClass:(id)unregisteredClass
{
    
}

- (void)generator:(objCRuntimeClassGenerator *)sender didRegisterClass:(id)unregisteredClass
{
    
}

- (void)generator:(objCRuntimeClassGenerator *)sender didCreateClassInstance:(id)instance forClass:(Class)classObject
{
    [instance retain];
}

- (void)generator:(objCRuntimeClassGenerator *)sender didRetrieveValue:(id)iVarValue foriVar:(id)ivar inClass:(id)classInstance
{
    
}

- (void)generator:(objCRuntimeClassGenerator *)sender didSetValue:(id)iVarValue foriVar:(id)ivar inClass:(id)classInstance path:propertyPath
{

}

- (void)generator:(objCRuntimeClassGenerator *)sender didFinishWithRoot:(id)rootObject RootKeyInObjectGraph:(NSString*)key
{
	DDLogVerbose(@"Root Object:%@", rootObject);
	[multicastDelegate StreamDidFinishParsing:self RootNodeKey:key inObjectGraph:[sender getObjectGraph] runtimeGenerator:sender];
}
@end
