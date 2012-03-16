//
//  GenericXMLParserAppDelegate.h
//  GenericXMLParser
//
//  Created by Praveen Jha on 16/03/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GenericXMLParserViewController;

@interface GenericXMLParserAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    GenericXMLParserViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet GenericXMLParserViewController *viewController;

@end

