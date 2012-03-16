//
//  GenericXMLParserAppDelegate.m
//  GenericXMLParser
//
//  Created by Praveen Jha on 16/03/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "GenericXMLParserAppDelegate.h"
#import "GenericXMLParserViewController.h"

@implementation GenericXMLParserAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}

@end
