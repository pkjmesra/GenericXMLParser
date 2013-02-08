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
#import <Foundation/Foundation.h>


@interface NSNumber (GenericXML)

+ (NSNumber *)numberWithPtr:(const void *)ptr;
- (id)initWithPtr:(const void *)ptr;

+ (BOOL)parseString:(NSString *)str intoInt32:(int32_t *)pNum;
+ (BOOL)parseString:(NSString *)str intoUInt32:(uint32_t *)pNum;

+ (BOOL)parseString:(NSString *)str intoInt64:(int64_t *)pNum;
+ (BOOL)parseString:(NSString *)str intoUInt64:(uint64_t *)pNum;

+ (BOOL)parseString:(NSString *)str intoNSInteger:(NSInteger *)pNum;
+ (BOOL)parseString:(NSString *)str intoNSUInteger:(NSUInteger *)pNum;

+ (UInt8)extractUInt8FromData:(NSData *)data atOffset:(unsigned int)offset;

+ (UInt16)extractUInt16FromData:(NSData *)data atOffset:(unsigned int)offset andConvertFromNetworkOrder:(BOOL)flag;

+ (UInt32)extractUInt32FromData:(NSData *)data atOffset:(unsigned int)offset andConvertFromNetworkOrder:(BOOL)flag;

@end
