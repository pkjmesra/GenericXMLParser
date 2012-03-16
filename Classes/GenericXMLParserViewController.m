//
//  GenericXMLParserViewController.m
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
#import "GenericXMLParserViewController.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "GenericXMLStream.h"
#import "objCRuntimeClassGenerator.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@implementation GenericXMLParserViewController



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    GenericXMLStream *stream = [[GenericXMLStream alloc] init];
    NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
    NSData * data = [NSData dataWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"SomeSample.xml"]];
    
	[stream addDelegate:self];
	[stream parseUTF8XMLData:data];
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark objCRuntimeClassGeneratorDelegate Configuration
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * This method is called after the stream is finished parsing the data.
 **/
- (void)StreamDidFinishParsing:(GenericXMLStream *)sender 
				   RootNodeKey:(NSString*)rootKey 
				 inObjectGraph:(NSDictionary*)graph 
			  runtimeGenerator:(objCRuntimeClassGenerator *)rtGenerator
{
	DDLogInfo(@"Object graph received:%@", graph);
	DDLogInfo(@"shipto city is:%@", [rtGenerator fetchValueObjectForiVar:INNER_VALUE_IVAR_KEY inContainerInstance:[graph objectForKey:@"shiporder.shipto.city"]]);
}


@end
