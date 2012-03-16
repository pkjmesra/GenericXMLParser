//
//  GenericXMLParserViewController.m
//  GenericXMLParser
//
//  Created by Praveen Jha on 16/03/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "GenericXMLParserViewController.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "GenericXMLStream.h"

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
    NSData * data = [NSData dataWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"VMGGetCurrentSettingsRequest.xml"]];
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

@end
