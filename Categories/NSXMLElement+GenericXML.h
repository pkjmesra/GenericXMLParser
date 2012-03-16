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

#if TARGET_OS_IPHONE
  #import "DDXML.h"
#endif


@interface NSXMLElement (GenericXML)

/**
 * Creating elements with explicit xmlns values.
 * 
 * Use these instead of [NSXMLElement initWithName:URI:].
 * The category methods below are more readable, and they actually work.
**/

+ (NSXMLElement *)elementWithName:(NSString *)name xmlns:(NSString *)ns;
- (id)initWithName:(NSString *)name xmlns:(NSString *)ns;

/**
 * Extracting a single element.
**/

- (NSXMLElement *)elementForName:(NSString *)name;
- (NSXMLElement *)elementForName:(NSString *)name xmlns:(NSString *)xmlns;

/**
 * Working with the common GenericXML xmlns value.
 * 
 * Use these instead of getting/setting the URI.
 * The category methods below are more readable, and they actually work.
**/

- (NSString *)xmlns;
- (void)setXmlns:(NSString *)ns;

/**
 * Convenience methods for printing xml elements with different styles.
**/

- (NSString *)prettyXMLString;
/**
 * Shortcut to get a compact string representation of the element.
 **/
- (NSString *)compactXMLString;

/**
 * Convenience methods for adding attributes.
**/

- (void)addAttributeWithName:(NSString *)name stringValue:(NSString *)string;

/**
 * Convenience methods for extracting attribute values in different formats.
 * 
 * E.g. <beer name="guinness" price="4.50"/> // float price = [beer attributeFloatValueForName:@"price"];
**/

- (int)attributeIntValueForName:(NSString *)name;
- (BOOL)attributeBoolValueForName:(NSString *)name;
- (float)attributeFloatValueForName:(NSString *)name;
- (double)attributeDoubleValueForName:(NSString *)name;
- (int32_t)attributeInt32ValueForName:(NSString *)name;
- (uint32_t)attributeUInt32ValueForName:(NSString *)name;
- (int64_t)attributeInt64ValueForName:(NSString *)name;
- (uint64_t)attributeUInt64ValueForName:(NSString *)name;
- (NSInteger)attributeIntegerValueForName:(NSString *)name;
- (NSUInteger)attributeUnsignedIntegerValueForName:(NSString *)name;
- (NSString *)attributeStringValueForName:(NSString *)name;
- (NSNumber *)attributeNumberIntValueForName:(NSString *)name;
- (NSNumber *)attributeNumberBoolValueForName:(NSString *)name;
- (NSNumber *)attributeNumberFloatValueForName:(NSString *)name;
- (NSNumber *)attributeNumberDoubleValueForName:(NSString *)name;
- (NSNumber *)attributeNumberInt32ValueForName:(NSString *)name;
- (NSNumber *)attributeNumberUInt32ValueForName:(NSString *)name;
- (NSNumber *)attributeNumberInt64ValueForName:(NSString *)name;
- (NSNumber *)attributeNumberUInt64ValueForName:(NSString *)name;
- (NSNumber *)attributeNumberIntegerValueForName:(NSString *)name;
- (NSNumber *)attributeNumberUnsignedIntegerValueForName:(NSString *)name;

- (int)attributeIntValueForName:(NSString *)name withDefaultValue:(int)defaultValue;
- (BOOL)attributeBoolValueForName:(NSString *)name withDefaultValue:(BOOL)defaultValue;
- (float)attributeFloatValueForName:(NSString *)name withDefaultValue:(float)defaultValue;
- (double)attributeDoubleValueForName:(NSString *)name withDefaultValue:(double)defaultValue;
- (NSString *)attributeStringValueForName:(NSString *)name withDefaultValue:(NSString *)defaultValue;
- (NSNumber *)attributeNumberIntValueForName:(NSString *)name withDefaultValue:(int)defaultValue;
- (NSNumber *)attributeNumberBoolValueForName:(NSString *)name withDefaultValue:(BOOL)defaultValue;

- (NSMutableDictionary *)attributesAsDictionary;

/**
 * Convenience methods for extracting element values in different formats.
 * 
 * E.g. <price>9.99</price> // float price = [priceElement stringValueAsFloat];
**/

- (int)stringValueAsInt;
- (BOOL)stringValueAsBool;
- (float)stringValueAsFloat;
- (double)stringValueAsDouble;
- (int32_t)stringValueAsInt32;
- (uint32_t)stringValueAsUInt32;
- (int64_t)stringValueAsInt64;
- (uint64_t)stringValueAsUInt64;
- (NSInteger)stringValueAsNSInteger;
- (NSUInteger)stringValueAsNSUInteger;

/**
 * Working with namespaces.
**/

- (void)addNamespaceWithPrefix:(NSString *)prefix stringValue:(NSString *)string;

- (NSString *)namespaceStringValueForPrefix:(NSString *)prefix;
- (NSString *)namespaceStringValueForPrefix:(NSString *)prefix withDefaultValue:(NSString *)defaultValue;

@end
