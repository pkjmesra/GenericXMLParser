//
//  objCRuntimeClassGenerator.m
//  GenericXMLParser
//
//  Created by Praveen Jha on 16/03/12.
//  Copyright (c) 2012 Praveen Jha. All rights reserved.
//
/*
 Copyright (c) 2011, Praveen K Jha.
 All rights reserved.
 
 Redistribution and use in source is NOT permitted. Redistribution and use in binary forms, without modification,
 are permitted provided that the following conditions are met:
 
 
 Redistributions in binary form must reproduce the above copyright notice, this
 list of conditions and the following disclaimer in the documentation and/or other
 materials provided with the distribution.
 Neither the name of the Praveen K Jha. nor the names of its contributors may be
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
#import "objCRuntimeClassGenerator.h"
#import "GenericXMLMessage.h"
#import "DDXML.h"
#import "DDXMLNode.h"
#import "GenericXMLStream.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_INFO;//LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@implementation objCRuntimeClassGenerator
@synthesize rootInstance =_rootInstance;
@synthesize allObjectsGraph=_allObjectsGraph;

NSString *MyObjectWillDeallocateNotification = @"MyObjectWillDeallocateNotification";
static NSMutableDictionary *gSubclassesDict;
static NSMutableSet *gSubclasses;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark runtime static methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

static RTUnregisteredClass* unregisteredClassFromClassName(NSString * className)
{
    Class xmlMesssage = NSClassFromString(@"GenericXMLMessage");
    if(!xmlMesssage)
        return nil;
    
    RTUnregisteredClass *unregClass = [xmlMesssage rt_createUnregisteredSubclassNamed:className];
    
    return unregClass;
}

// encapsulate code needed to override an existing method
static void Override(Class c, SEL sel, void *fptr)
{
    RTMethod *superMethod = [[c superclass] rt_methodForSelector: sel]; //NSClassFromString(@"GenericXMLMessage")
    RTMethod *newMethod = [RTMethod methodWithSelector: sel implementation: fptr signature: [superMethod signature]];
    [c rt_addMethod: newMethod];
}

static NSString* parseClassNameFromXMLElement(NSString* xmlElement)
{
    NSString *newString=@"";
    NSArray *possibleElementNames = [xmlElement componentsSeparatedByCharactersInSet:
                                     [[NSCharacterSet alphanumericCharacterSet] invertedSet]];
    for (NSString *name in possibleElementNames) {
        newString = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([newString length] >0)
        {
            break;
        }
        else
        {
            newString =@"";
        }
    }
    
    if ([newString length]<=0)
    {
        newString = [[xmlElement componentsSeparatedByCharactersInSet:
                      [[NSCharacterSet alphanumericCharacterSet] invertedSet]]componentsJoinedByString:@""];
    }
    return newString;
}

static NSString *Description(id self, SEL _cmd)
{
//    return [NSString stringWithFormat: @"<%@ %p: iVarCount=%d iVars:%@ >", [self class], self,[[[self class] rt_ivars] count],[[self class] rt_ivars]];
	return [NSString stringWithFormat: @"<%@ %p: iVarCount=%d >", [self class], self,[[[self class] rt_ivars] count]];
}

static void Dealloc(id self, SEL _cmd)
{

    [[NSNotificationCenter defaultCenter] postNotificationName: MyObjectWillDeallocateNotification object: self];
    Class c = [self rt_class];
    NSLog(@"%@ deallocated",NSStringFromClass(c));
//    while(c && ![gSubclassesDict objectForKey: c])
        c = [c superclass];
    
    // if it wasn't found, something went horribly wrong
    assert(c);
    // Release all instance variables
//    NSArray *ivars = [c rt_ivars];
//    for (RTIvar* instanceObj in ivars) {
//        id currentValue;
//        object_getInstanceVariable(self, [instanceObj name], &currentValue);
//        [currentValue release];
//    }
    id (*superIMP)(id, SEL,...) = [c instanceMethodForSelector:@selector(dealloc)];
    superIMP(self, _cmd);

}

static Class CreateSubclassForClass(Class c)
{
    // give the subclass a sensible name
    NSString *name = [NSString stringWithFormat: @"%@_MyDeallocNotifying", NSStringFromClass(c)];
    Class subclass = [c rt_createSubclassNamed: name];
    
    // use the Override function from above
    Override(c, @selector(dealloc), Dealloc);
    
    return subclass;
}

static Class GetSubclassForClass(Class c)
{
    Class subclass = [gSubclassesDict objectForKey: c];
    if(!subclass)
    {
        subclass = CreateSubclassForClass(c);
        [gSubclassesDict setObject: subclass forKey: (id<NSCopying>)c];
        [gSubclasses addObject: subclass];
    }
    return subclass;
}

void MakeObjectPostDeallocNotification(id obj)
{
    Class c = [obj rt_class];
    while(c && ![gSubclasses containsObject: c])
        c = [c superclass];
    // if we found one, then nothing else to do
    if(c)
        return;
    
    // not yet set, grab the subclass
    c = GetSubclassForClass([obj rt_class]);
    // set the class of the object to the subclass
    [obj rt_setClass: c];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark overridden super class methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//! Creates a mew receipt message with element "received"
static GenericXMLMessage* GenerateReceiptResponse (id self, SEL _cmd)
{
    // Override and create a serialized string
    return nil;
}

static NSXMLElement* Serialize (id self, SEL _cmd)
{
    // Example:
	// 
	// <message to="juliet">
	//   <received xmlns="urn:GenericXML:receipts" id="ABC-123"/>
	// </message>
	
    // RootNode and other serialization code goes here
    NSXMLElement *message = [NSXMLElement elementWithName:NSStringFromClass([self class])];
    
    // add all attributes to the node
    NSMutableDictionary *attributesDict = [self attributesAsDictionary];
    NSArray *keys = [attributesDict allKeys];
    for (NSString* key in keys) 
    {
        [message addAttributeWithName:key stringValue:[attributesDict objectForKey:key]];
    }
	NSXMLElement *received = [NSXMLElement elementWithName:@"received"];
	
	[message addChild:received];
	
	return message;
}

static void DeSerialize(id self, SEL _cmd, NSXMLElement* xmlData, objCRuntimeClassGenerator* rtGenerator, NSString *propertyPath,NSString* childClassName)
{
    DDLogVerbose(@"deserializing:%@",[xmlData compactXMLString]);
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    // Create root class
    RTUnregisteredClass *unreg = [rtGenerator createRootClass:xmlData Named:childClassName];
    
    //for (NSXMLElement *child in [xmlData children]) 
    {
        [rtGenerator createRuntimeChildObjectPool:[xmlData children]
                                      forNewClass:unreg
                                        forParent:self
                                             root:xmlData
                                             path:propertyPath 
								   childClassName:childClassName];
    }
	//    GenericXMLStream *stream = [[GenericXMLStream alloc] init];
	//    NSData * data = [[xmlData compactXMLString] dataUsingEncoding:NSUTF8StringEncoding];
	//    stream.parentElement = self;
	//    [stream parseUTF8XMLData:data];
    [pool release];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark public objCRuntimeClassGenerator methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(GenericXMLMessage*)createRuntimeObjectPool:(NSMutableArray *)parsedElements 
{
    // Create root class
    NSXMLElement *rootElement = [parsedElements objectAtIndex:0];
    RTUnregisteredClass *unreg = [self createRootClass:rootElement Named:@""];
    
    // create children classes' iVar in root class
	NSMutableDictionary *ivars = [[NSMutableDictionary alloc] initWithCapacity:0];
    for (int position=1;position <[parsedElements count];position++) 
    {
        NSXMLElement *child = [parsedElements objectAtIndex:position];
        if ([[child description] hasPrefix:@"<"])
        {
            NSString *newiVar = parseClassNameFromXMLElement([[parsedElements objectAtIndex:position] compactXMLString]);
			newiVar =[self getNextAvailableIvar:newiVar inDictionary:ivars Index:0];
			[ivars setObject:child forKey:newiVar];
        }
    }

    for (int position=0;position <[ivars count];position++) 
    {
        [self addiVar:[[ivars allKeys] objectAtIndex:position] toUnregisteredClass:unreg];
    }

	if ([ivars count]==0)
	{
		// Always add the innerValue iVar to all classes
		// <accountId>inner value will be here</accountId>
		[self addiVar:INNER_VALUE_IVAR_KEY toUnregisteredClass:unreg];
	}
	
    // Now register the class so we can use it
    id rootClass = [self registerUnregisteredClass:unreg];
    // Now create an instance of the class
    id instance = [[rootClass alloc] init];
    
    //NSString* propertyPath = [NSString stringWithFormat:@"%@.attributes",NSStringFromClass(rootClass)];
    //Set root element attributes' values
    [self setAttributediVars:[rootElement attributesAsDictionary] forClass:instance path:NSStringFromClass(rootClass)];
    
    [multicastDelegate generator:self didCreateClassInstance:instance forClass:rootClass];
    
    self.rootInstance = instance;
    // Now set the child element iVar values since the iVars are already created
    for (int position=0;position <[ivars count];position++) 
    {
        if ([instance respondsToSelector:@selector(deSerialize:runtimeGenerator:path:childClassName:)])
        {
			NSString *name = [[ivars allKeys] objectAtIndex:position];
            [instance deSerialize:[ivars objectForKey:name] runtimeGenerator:self path:NSStringFromClass(rootClass) childClassName:name];
        }
    }
	
	NSString *rootNodeKeyName = [NSString stringWithFormat:@"%@.%@.parentInstance",NSStringFromClass(rootClass),[[ivars allKeys] objectAtIndex:0]];
    [ivars release];
	
	DDLogVerbose(@"rootNodeKeyName for object graph is:%@",rootNodeKeyName);
	[multicastDelegate generator:self didFinishWithRoot:[self getObjectForFullyQualifiedKey:rootNodeKeyName] RootKeyInObjectGraph:rootNodeKeyName];
	
    [instance release];
    return self.rootInstance;
}

-(id)fetchValueObjectForiVar:(NSString *)key 
         inContainerInstance:(id)instanceOfClass
{
    NSArray *ivars = [[instanceOfClass class] rt_ivars];
    BOOL containsiVar = [[ivars valueForKey: @"name"] containsObject:key];
    DDLogVerbose(@"%@ class instance contains ivar %@:%d",
                 NSStringFromClass([instanceOfClass class]),key,
                 containsiVar);
    if (!containsiVar)
        return nil;
    // We found the iVar in the class declaration.
    // Now let's try finding the value for iVar
    id iVarValue = objc_getAssociatedObject(instanceOfClass,key);
    if ([iVarValue isKindOfClass:[GenericXMLMessage class]])
    {
		//        id typecasted;
		//        object_getInstanceVariable(instanceOfNewClass, key, (void*)&typecasted);
        DDLogVerbose(@"Retrieved value:%@ for iVar:%@",NSStringFromClass([iVarValue class]),key);//NSStringFromClass([setvalue class])
    }
    else
        DDLogVerbose(@"Retrieved value:%@ for iVar:%@",iVarValue,key);
	
    if (!iVarValue)
    {
        Ivar ivar = class_getInstanceVariable([instanceOfClass class],"MessageHeader");
        //const char* typeEncoding = ivar_getTypeEncoding(ivar);
        id returnedValue = object_getIvar(instanceOfClass, ivar);
        iVarValue = returnedValue;
    }
    
    [multicastDelegate generator:self didRetrieveValue:iVarValue foriVar:key inClass:instanceOfClass];
    
    return iVarValue;
}

-(NSDictionary *)getObjectGraph
{
    return self.allObjectsGraph;
}

-(id)getObjectForFullyQualifiedKey:(NSString*)fqKey
{
    return [self.allObjectsGraph objectForKey:fqKey];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark objCRuntimeClassGeneratorDelegate Configuration
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)addDelegate:(id)delegate
{
    [self removeDelegate:delegate];
	[multicastDelegate addDelegate:delegate];
}

- (void)removeDelegate:(id)delegate
{
	[multicastDelegate removeDelegate:delegate];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark private methods for objCRuntimeClassGenerator
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)createRuntimeChildObjectPool:(NSArray *)parsedElements 
                     forNewClass:(RTUnregisteredClass*) unreg
                          forParent:(GenericXMLMessage *)parent
                               root:(NSXMLElement*)rootElement
                               path:propertyPath 
					 childClassName:(NSString*)childClassName
{
    DDLogVerbose(@"parsedElements from which children will be created:%@",parsedElements);
    // create children classes' iVar in root class
	NSMutableDictionary *ivars = [[NSMutableDictionary alloc] initWithCapacity:0];
    for (int position=0;position <[parsedElements count];position++) 
    {
        NSXMLElement *child = [parsedElements objectAtIndex:position];
        if ([[child description] hasPrefix:@"<"])
        {
            NSString *newiVar = parseClassNameFromXMLElement([child name]);
			newiVar =[self getNextAvailableIvar:newiVar inDictionary:ivars Index:0];
			[ivars setObject:child forKey:newiVar];
        }
    }
	
	for (int position=0;position <[ivars count];position++) 
    {
		[self addiVar:[[ivars allKeys] objectAtIndex:position] toUnregisteredClass:unreg];
    }
	if ([ivars count]==0)
	{
		// Always add the innerValue iVar to all classes
		// <accountId>inner value will be here</accountId>
		[self addiVar:INNER_VALUE_IVAR_KEY toUnregisteredClass:unreg];
	}
	
	id rootClass;
	if (unreg)
	{
		[self addiVar:@"parentInstance" toUnregisteredClass:unreg];
		
		// Now register the class so we can use it
		 rootClass= [self registerUnregisteredClass:unreg];
	}
	else
	{
		// Do we already have a registered class by that name?
		rootClass = NSClassFromString(childClassName);
	}
    // Now create an instance of the class
    GenericXMLMessage* instance = [[rootClass alloc] init];
    NSString* propertyPathNew = [NSString stringWithFormat:@"%@.%@",propertyPath,NSStringFromClass([instance class])];
    
    //Set root element attributes' values
    [self setAttributediVars:[rootElement attributesAsDictionary] forClass:instance path:propertyPathNew];
    
    // Set parent for the child class
    [self setiVarValue:parent 
               foriVar:@"parentInstance" 
            inRegisteredClassInstance:instance path:propertyPathNew];
    
    // Now set the child element iVar values since the iVars are already created
    for (int position=0;position <[ivars count];position++) 
    {
        if ([instance respondsToSelector:@selector(deSerialize:runtimeGenerator:path:childClassName:)])
        {
			NSString* name=[[ivars allKeys] objectAtIndex:position];
            NSXMLElement *child = [ivars objectForKey:name];
			[instance deSerialize:child 
				 runtimeGenerator:self
							 path:propertyPathNew 
				   childClassName:name];
        }
    }
    
	[ivars release];
	
    if (parent)
    {
		// Set the parent value 
		// topLevelRoot.NextLevel=NextLevel; // chilClassName and instance class name would be the same
		[self setiVarValue:instance foriVar:childClassName inRegisteredClassInstance:parent path:propertyPath];
        
        // check to see if this was the bottommost element that was being parsed
        // If so, set the innervalue
        if ([parsedElements count] <=1) // last element
        {
            NSString* innerValue = [parsedElements componentsJoinedByString:@""];
            [self setiVarValue:innerValue foriVar:INNER_VALUE_IVAR_KEY inRegisteredClassInstance:instance path:propertyPathNew];
            
            // Test if set correctly
            DDLogVerbose(@"innerValue for instance:%@ is:%@",NSStringFromClass([instance class]), [self fetchValueObjectForiVar:INNER_VALUE_IVAR_KEY inContainerInstance:instance]);
        }
    }
    
    [multicastDelegate generator:self didCreateClassInstance:instance forClass:[instance class]];
    if (!self.rootInstance)
        self.rootInstance = parent;
    [instance release];
}

-(RTUnregisteredClass *) createClass:(NSString *)className WithAttributeDictionary:(NSDictionary *)attributesDict
{
    //    static dispatch_once_t pred;
    //    dispatch_once(&pred, ^{
    RTUnregisteredClass *unreg = unregisteredClassFromClassName(className);
    // Must add ivars here itself before registering
    
    NSArray *keys = [attributesDict allKeys];
    for (NSString* key in keys) 
    {
        [self addiVar:key toUnregisteredClass:unreg];
    }
    //    });
    
    return unreg; 
}

-(void)addiVar:(NSString *)key toUnregisteredClass:(RTUnregisteredClass *)unreg
{
    [unreg addIvar:[RTIvar ivarWithName:key encode: @encode(id)]];
}

-(RTUnregisteredClass *) createRootClass:(NSXMLElement *)rootElement Named:(NSString*)className
{
	if ([className length]<=0)
	{
		className = parseClassNameFromXMLElement([rootElement compactXMLString]);
	}
    DDLogVerbose(@"Root class name being created:%@", className);
    RTUnregisteredClass * newClass = [self createClass:className WithAttributeDictionary:[rootElement attributesAsDictionary]];
    
    [multicastDelegate generator:self didCreateUnregisteredClass:newClass];
    
    return newClass;
}

-(Class) registerUnregisteredClass:(RTUnregisteredClass *)unreg
{
    // Make sure all iVars are already added before calling this method
    // You would be able to add methods but you cannot add iVars after this point.
    static Class c = nil;
    c = [unreg registerClass];
    // use the Override function from above
    Override(c, @selector(dealloc), Dealloc);
    Override(c, @selector(generateReceiptResponse), GenerateReceiptResponse);
    Override(c, @selector(serialize), Serialize);
    Override(c, @selector(deSerialize:runtimeGenerator:path:childClassName:), DeSerialize);
    
    // grab NSObject's description signature so we can borrow it
    Method description = class_getInstanceMethod([NSObject class],
                                                 @selector(description));
    const char *types = method_getTypeEncoding(description);
    
    // now add
    class_addMethod(c, @selector(description), (IMP)Description, types);
    
    [multicastDelegate generator:self didRegisterClass:c];
    
    return c;
}

-(void)setAttributediVars:(NSMutableDictionary *)attributesDict 
                 forClass:(id)instanceOfNewClass 
                     path:(NSString*)propertyPath
{
    // Set all attributes key/value pairs here,
    //assuming that all ivars are already added
    NSArray *keys = [attributesDict allKeys];
    propertyPath = [NSString stringWithFormat:@"%@.attributes",propertyPath];
    for (NSString* key in keys) 
    {
                [self setiVarValue:[attributesDict objectForKey:key] 
                           foriVar:key 
         inRegisteredClassInstance:instanceOfNewClass 
                              path:propertyPath];
    }
}

-(void) setiVarValue:(id)value 
             foriVar:(id)key 
inRegisteredClassInstance:(id)instanceOfNewClass
                path:(NSString*)propertyPath
{
	if(!instanceOfNewClass) return;
	if(!key) return;
	if(!value) return;
    //Accessing this newly-added variable is not as easy as it normally would be. You can't just write foo in your code, because the compiler has no idea that this thing even exists.
    //The runtime provides two functions for accessing instance variables: object_setInstanceVariable and object_getInstanceVariable. They take an object and a name, and either a value to set, or a place to put the current value. Here's an example of getting and setting the instance variable constructed while creating the class:
    // Settings an ivar value
    //            id currentValue;
    //            object_getInstanceVariable(unreg, key, &currentValue);
    //            // it will be replaced, so autorelease
    //            [currentValue autorelease];
    
    //            id newValue = [attributesDict objectForKey:key];
    //            [newValue retain]; // runtime won't retain for us
    //            object_setInstanceVariable(unreg, key, newValue);
    //If you need per-instance storage, consider using the associated object API (objc_setAssociatedObject and objc_getAssociatedObject) instead of instance variables. It takes care of memory management for you.
    NSArray *ivars = [[instanceOfNewClass class] rt_ivars];
    BOOL containsiVar = [[ivars valueForKey: @"name"] containsObject:key];
    DDLogVerbose(@"%@ class instance contains ivar %@:%d",
                 NSStringFromClass([instanceOfNewClass class]),key,
                 containsiVar);
    DDLogVerbose(@"Setting value:%@ for iVar:%@ in class instance:%@",
                 NSStringFromClass([value class]),key,
                 NSStringFromClass([instanceOfNewClass class]));
//    RTIvar *ivar = [[instanceOfNewClass class] rt_ivarForName:key];
    if (containsiVar)
    {
        propertyPath = [NSString stringWithFormat:@"%@.%@",propertyPath,key];
        objc_setAssociatedObject(instanceOfNewClass,key,value,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [self.allObjectsGraph setObject:value forKey:propertyPath];
        [multicastDelegate generator:self didSetValue:value foriVar:key inClass:instanceOfNewClass path:propertyPath];
    }
	else
	{
		DDLogVerbose(@"iVar %@ in class %@ not found!", key,NSStringFromClass([instanceOfNewClass class]));
	}
}

-(NSString*)getNextAvailableIvar:(NSString*)ivarKey 
					inDictionary:(NSDictionary*)iVarDictionary 
						   Index:(int)index
{
	BOOL containsiVar = [iVarDictionary objectForKey:ivarKey]!=nil;
	if (!containsiVar) 
		return ivarKey;
	else
	{
		index++;
		NSString* newiVar =[NSString stringWithFormat:@"%@%d",ivarKey,index];
		return [self getNextAvailableIvar:newiVar inDictionary:iVarDictionary Index:index];
	}
}

/**
 * Standard  initialization.
 **/
- (id)init
{
	if ((self = [super init]))
	{
		multicastDelegate = (MulticastDelegate <objCRuntimeClassGeneratorDelegate> *)[[MulticastDelegate alloc] init];
        _allObjectsGraph =[[NSMutableDictionary alloc] initWithCapacity:0];
	}
	return self;
}

/**
 * Standard deallocation method.
 * Every object variable declared in the header file should be released here.
 **/
- (void)dealloc
{
	[multicastDelegate release];
	[_allObjectsGraph release];
	[super dealloc];
}

@end
