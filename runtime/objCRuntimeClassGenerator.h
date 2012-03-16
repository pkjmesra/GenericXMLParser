//
//  objCRuntimeClassGenerator.h
//  GenericXMLParser
//
//  Created by Praveen Jha on 16/03/12.
//  Copyright (c) 2012 Praveen Jha. All rights reserved.
//
/*
 Copyright (c) 2011, Research2Development.org.
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
#import "objc/runtime.h"
#import "MARTNSObject.h"
#import "RTProtocol.h"
#import "RTIvar.h"
#import "RTProperty.h"
#import "RTMethod.h"
#import "RTUnregisteredClass.h"
#import "NSXMLElement+GenericXML.h"
#import "DDLog.h"
#import "MulticastDelegate.h"

#define INNER_VALUE_IVAR_KEY @"innerValue"

@class GenericXMLMessage;
@protocol objCRuntimeClassGeneratorDelegate;

@interface objCRuntimeClassGenerator : NSObject
{
    MulticastDelegate <objCRuntimeClassGeneratorDelegate> *multicastDelegate;
    GenericXMLMessage* _rootInstance;
    NSMutableDictionary *_allObjectsGraph;
}
@property (nonatomic,retain) GenericXMLMessage* rootInstance;
@property (nonatomic,retain) NSMutableDictionary *allObjectsGraph;
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
 Creating a Class
 The act of creating a class is accomplished using the objc_allocateClassPair function in objc/runtime.h. You pass it a superclass, a name, and a size for per-class storage (generally best left at 0), and it returns a class to you.
 All Objective-C classes are also Objective-C objects. You can put them in variables, send them messages, add them to arrays, etc. just like you would with any other object. All objects have a class, and the class of a class is called the metaclass. Each class has a unique metaclass, and thus the pair: objc_allocateClassPair allocates both the class and the metaclass together.
 
 A full discussion of what the metaclass is and how it works is beyond the scope of this post, but Greg Parker has a good discussion of metaclasses if you're interested in reading more.
 */

/*
 Adding Methods
 You know how to create a class, but it won't do anything interesting unless you actually put things in it.
 
 Methods are the most obvious things to add to a newly created class. You add methods to a class using the class_addMethod function in objc/runtime.h. This function takes four parameters.
 
 The first two parameters are the class you want to manipulate, and the selector of the method that you want to add. Both of these should be pretty obvious.
 
 The next parameter is an IMP. This type is a special Objective-C typedef for a function pointer. It's defined as:
 
 typedef id (*IMP)(id, SEL, ...);
 Objective-C methods take two implicit parameters, self and _cmd, which are the first two parameters listed here. The other parameters are not listed, and are up to you.
 To create the IMP that you pass to this function, implement a function that takes id self and SEL _cmd as its first two parameters. The rest of the parameters are the parameters that the method will take, and the return type is the method return type.
 
 For example, let's say you wanted to write an IMP with this signature:
 
 - (NSUInteger)countOfObject: (id)obj;
 You'd write the function like this:
 static NSUInteger CountOfObject(id self, SEL _cmd, id obj)
 Unfortunately, the type of this function doesn't match the IMP typedef, so you have to cast it when passing it to class_addMethod.
 The last parameter is a type encoding string which describes the type signature of the method. This is the string that the runtime uses to generate the NSMethodSignature that's returned from methodSignatureForSelector:, among other uses.
 
 The best way to generate this type encoding string is to retrieve it from an existing class which has a method with the same signature. This way you can just trust the compiler to get it right and don't have to worry about the details of how these strings are put together. For example, the method above has the same signature as -[NSArray indexOfObject:], so you can retrieve that type encoding string:
 
 Method indexOfObject = class_getInstanceMethod([NSArray class],
 @selector(indexOfObject:));
 const char *types = method_getTypeEncoding(indexOfObject);
 If no existing class has a matching method, consider writing a small dummy class that does, and then querying it.
 If you absolutely must build your own type encoding string (not recommended), then you can do it using the @encode directive to generate strings for the individual components, then combine them. Compiler-generated strings also have numeric stack offset information embedded in them, which means that your string won't completely match its output, but it's often good enough.
 
 The components of a method's type encoding string are simply the @encode representation of the return type, followed by the argument types, including the two implicit parameters at the beginning:
 
 NSString *typesNS = [NSString stringWithFormat: @"%s%s%s%s",
 @encode(NSUInteger),
 @encode(id), @encode(SEL),
 @encode(id)];
 const char *types C = [typesNS UTF8String];
 But again, avoid this if it's at all possible.
 Here's a full example of adding a description method to a newly created class:
 
 static NSString *Description(id self, SEL _cmd)
 {
 return [NSString stringWithFormat: @"<%@ %p: foo=%@>", [self class], self, [self foo]];
 }
 
 // add Description to mySubclass
 
 // grab NSObject's description signature so we can borrow it
 Method description = class_getInstanceMethod([NSObject class],
 @selector(description));
 const char *types = method_getTypeEncoding(description);
 
 // now add
 class_addMethod(mySubclass, @selector(description), (IMP)Description, types);
 A bit verbose, but not too difficult at all.
 */

/**
 Adding Instance Variables
 You can add instance variables to a class using the class_addIvar method.
 
 The first two parameters to this function are the class to manipulate and the name of the instance variable you want to add. Both are straightforward.
 
 The next parameter is the size of the instance variable. If you're using a plain C type as the instance variable, then you can simply use sizeof to get the size.
 
 Next is the alignment of the instance variable. This indicates how the instance variable's storage needs to be aligned in memory, potentially with padding in between it and the end of the previous instance variable. A trick to this parameter is that it's the log2 of the alignment rather than the alignment itself. Passing 1 means aligning it to a 2-byte boundary, passing 4 means 16-byte alignment, etc. Since most types want to be aligned to their size, you can simply use rint(log2(sizeof(type))) to generate the value of this parameter.
 
 The last parameter is a type encoding string for the parameter. This can be generated using the @encode directive and giving it the type of the variable that you're adding.
 
 Here's a full example of adding an id instance variable:
 
 class_addIvar(mySubclass, "foo", sizeof(id), rint(log2(sizeof(id))), @encode(id));
 Accessing Added Instance Variables
 Accessing this newly-added variable is not as easy as it normally would be. You can't just write foo in your code, because the compiler has no idea that this thing even exists.
 The runtime provides two functions for accessing instance variables: object_setInstanceVariable and object_getInstanceVariable. They take an object and a name, and either a value to set, or a place to put the current value. Here's an example of getting and setting the foo variable constructed above:
 
 id currentValue;
 object_getInstanceVariable(obj, "foo", &currentValue);
 // it will be replaced, so autorelease
 [currentValue autorelease];
 
 id newValue = ...;
 [newValue retain]; // runtime won't retain for us
 object_setInstanceVariable(obj, "foo", newValue);
 Another way is to simply use key-value coding to read and write the instance variable. As long as you don't have a method with the same name, it will directly access the variable's contents. It will also do proper memory management on object-type variables. As a potential downside, it will box primitive values in NSValue or NSNumber objects, which could add complication.
 With either technique, don't forget to add a dealloc method to release your object instance variables.
 
 If you need per-instance storage, consider using the associated object API (objc_setAssociatedObject and objc_getAssociatedObject) instead of instance variables. It takes care of memory management for you.
 
 Adding Protocols
 You can add a protocol to a class using class_addProtocol. This is not usually very useful, so I won't go into how to use it. Keep in mind that this function only declares the class as conforming to the protocol in question, but it doesn't actually add any code. If you want the class to actually implement the methods in a protocol, you have to implement and add those methods yourself.
 
 Adding Properties
 Although there are plenty of functions for querying the properties of a class, Apple apparently forgot to provide any way to add a property to a class. Fortunately, like protocols, it's not usually very useful to add a property to a class at runtime, so this is not a big loss.
 
 Registering the Class
 After you're done setting up the class, you have to register it before you can use it. You do this with the objc_registerClassPair function:
 
 objc_registerClassPair(mySubclass);
 It's now ready to use.
 Note that you must register a class before you use it, and you can't add any instance variables to a class after you register it. You can add methods to a class after registration, however.
 
 Using the Class
 Once you've registered the class, you can message it just like you would any other class:
 
 id myInstance = [[mySubclass alloc] init];
 NSLog(@"%@", myInstance);
 You can access the class using NSClassFromString as well, and in general it behaves just like any other class at this point.
 */
-(GenericXMLMessage*)createRuntimeObjectPool:(NSMutableArray *)parsedElements;
-(id)fetchValueObjectForiVar:(NSString *)key 
         inContainerInstance:(id)instanceOfClass;
-(NSDictionary *)getObjectGraph;
-(id)getObjectForFullyQualifiedKey:(NSString*)fqKey;

@end

@interface objCRuntimeClassGenerator (private)

void MakeObjectPostDeallocNotification(id obj);
-(void)addiVar:(NSString *)key toUnregisteredClass:(RTUnregisteredClass *)unreg;
-(RTUnregisteredClass *) createClass:(NSString *)className WithAttributeDictionary:(NSDictionary *)attributesDict;
-(RTUnregisteredClass *) createRootClass:(NSXMLElement *)rootElement Named:(NSString*)className;
-(Class) registerUnregisteredClass:(RTUnregisteredClass *)unreg;
-(void)setAttributediVars:(NSMutableDictionary *)attributesDict 
                 forClass:(id)instanceOfNewClass 
                     path:(NSString*)propertyPath;
-(void) setiVarValue:(id)value 
             foriVar:(id)key 
inRegisteredClassInstance:(id)instanceOfNewClass
                path:(NSString*)propertyPath;
-(void)createRuntimeChildObjectPool:(NSArray *)parsedElements 
						forNewClass:(RTUnregisteredClass*) unreg
                          forParent:(GenericXMLMessage *)parent
                               root:(NSXMLElement*)rootElement
                               path:propertyPath 
					 childClassName:(NSString*)name;
-(NSString*)getNextAvailableIvar:(NSString*)ivarKey 
					inDictionary:(NSDictionary*)iVarDictionary 
						   Index:(int)index;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol objCRuntimeClassGeneratorDelegate
@optional

- (void)generator:(objCRuntimeClassGenerator *)sender didCreateUnregisteredClass:(id)unregisteredClass;

- (void)generator:(objCRuntimeClassGenerator *)sender didRegisterClass:(id)unregisteredClass;

- (void)generator:(objCRuntimeClassGenerator *)sender didCreateClassInstance:(id)instance forClass:(Class)classObject;

- (void)generator:(objCRuntimeClassGenerator *)sender didRetrieveValue:(id)iVarValue foriVar:(id)ivar inClass:(id)classInstance;

- (void)generator:(objCRuntimeClassGenerator *)sender didSetValue:(id)iVarValue foriVar:(id)ivar inClass:(id)classInstance path:propertyPath;

- (void)generator:(objCRuntimeClassGenerator *)sender didFinishWithRoot:(id)rootObject RootKeyInObjectGraph:(NSString*)key;
@end