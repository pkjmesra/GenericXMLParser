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
    _runtimeGenerator = [[objCRuntimeClassGenerator alloc] init];
    [_runtimeGenerator addDelegate:self];
    
    //id rootClass = 
    [self.runtimeGenerator createRuntimeObjectPool:self.parsedElements];
////    Ivar ivar = class_getInstanceVariable([rootClass class], @"MessageHeader");
////    const char* typeEncoding = ivar_getTypeEncoding(ivar);
////    id returnedValue = object_getIvar(rootClass, ivar);
////    NSLog(@"Class: %@", [returnedValue class]);
////    
////    NSLog(@"%@",[[rootClass class] rt_instanceSize]);
////    void *ptr_to_result;
////    object_getInstanceVariable(rootClass, "MessageHeader", &ptr_to_result);
//    
//    Ivar ivar = class_getInstanceVariable([rootClass class],"setting");
//    const char* typeEncoding = ivar_getTypeEncoding(ivar);
//    id msgHeader = [self.runtimeGenerator.rootInstance valueForKey:@"setting"];//object_getIvar(self.runtimeGenerator.rootInstance, ivar);
//    id lockObject = *(id*)(((char*)rootClass)+ivar_getOffset(ivar));
//    
//    ivar = class_getInstanceVariable([msgHeader class],"transactionId");
//    typeEncoding = ivar_getTypeEncoding(ivar);
//    id tranId = object_getIvar(msgHeader, ivar);
//    
//    ivar = class_getInstanceVariable([msgHeader class],"innerValue");
//    typeEncoding = ivar_getTypeEncoding(ivar);
//    id tranValue = object_getIvar(tranId, ivar);
//    
////    id msgHeader = [self.runtimeGenerator fetchValueObjectForiVar:@"MessageHeader" inContainerInstance:self.runtimeGenerator.rootInstance];
////    id tranId = [self.runtimeGenerator fetchValueObjectForiVar:@"transactionId" inContainerInstance:msgHeader];
////    id tranValue = [self.runtimeGenerator fetchValueObjectForiVar:INNER_VALUE_IVAR_KEY inContainerInstance:tranId];
//    NSLog(@"%@ %@ is %@",msgHeader,tranId,tranValue);
//    [self.parsedElements removeAllObjects];
    
    NSLog(@"object graph:%@",[self.runtimeGenerator getObjectGraph]);
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
//    NSLog(@"propertyPath:%@",propertyPath);
//    if ([NSStringFromClass([classInstance class]) isEqualToString:@"transactionId"])
//    {
//        if ([ivar isEqualToString:@"innerValue"])
//        {
//            id tranValue = [sender fetchValueObjectForiVar:@"innerValue" inContainerInstance:classInstance];
//            NSLog(@"tranvalue:%@, from fetch:%@",iVarValue, tranValue);
//            NSLog(@"Parent is:%@",[sender fetchValueObjectForiVar:@"parentInstance" inContainerInstance:classInstance]);
//        }
//    }
}

@end
