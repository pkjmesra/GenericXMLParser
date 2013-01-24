//
//  CocoaLumberjack.h
//  CocoaLumberjack
//

/**
 ############################## ############################## #################
 Loading Bundle Resources
 ==============================
 In order to load bundle resources, we must first ask the third-party developer
 to add the .bundle to their application. To do so they will simply drag the
 .bundle that you distributed with the .framework to their project and ensure
 that it is copied in the copy files phase of their app target.
 
 To load resources from the bundle we can use the following code:
 
 / Load the framework bundle.
 + (NSBundle *)frameworkBundle
 {
 static NSBundle* frameworkBundle = nil;
 static dispatch_once_t predicate;
 dispatch_once(&predicate, ^{
 NSString* mainBundlePath = [[NSBundle mainBundle] resourcePath];
 NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"<YourBundleProductName>.bundle"];
 frameworkBundle = [[NSBundle bundleWithPath:frameworkBundlePath] retain];
  //         [frameworkBundle load]; // you should call this if this is the first time you are doing this
 });
 return frameworkBundle;
 }
 
 [UIImage imageWithContentsOfFile:[[[self class] frameworkBundle] pathForResource:@"image" ofType:@"png"]];
 */


/**
 Adding the Framework to a Third-Party Application
 ===================================================
 This is the easy part (and what your third-party developers will have to do).
 Simply drag the .framework to your application's project, ensuring that it's
 being added to the necessary targets.
 
 #import <CocoaLumberjack/CocoaLumberjack.h>
 
 If you're distributing resources with your framework then you will also send
 the .bundle file to the developers. The developer will then drag the .bundle
 file into their application and ensure that it's added to the application target.
 
 */


/**
 Developing the Framework as a Dependent Project
 ===============================================
 
 When developing the framework you want to minimize build times while ensuring
 that your experience roughly matches that of your third-party developers. We
 achieve this balance by only building the static library but treating the
 static library as though it were a framework.
 
 ############################## ############################## #################
 Step 1: Add the Framework Project to your Application Project
 ############################## ############################## #################
 To add the framework as a dependent target in your application, drag the
 framework's xcodeproj to Xcode and drop it in your application's frameworks
 folder. This will add a reference to the framework's xcodeproj folder.
 
 
 ############################## ############################## #################
 Step 2: Make the Framework Static Library Target a Dependency
 ############################## ############################## #################
 Once you've added the framework project to your app you can add the static
 library product as a dependency. Select your project in the Xcode file explorer
 and open the "Build Phases" tab. Expand the "Target Dependencies" group and
 click the + button. Select the static library target and click "Add".
 
 
 ############################## ############################## #################
 Step 3: Link your Application with the Framework Static Library
 ############################## ############################## #################
 In order to use the framework's static library we must link it into the
 application. Expand the "Link Binary With Libraries" phase and click the + button.
 Select the .a file that's exposed by your framework's project and then click add.
 
 
 ############################## ############################## #################
 Step 4: Import the Framework Header
 ############################## ############################## #################
 You now simply need to import the framework header somewhere in your project.
 I generally prefer the pch so that I don't have to clutter up my application's
 source with framework headers, but you can obviously choose whatever practice
 suits your needs.
 
 #import <CocoaLumberjack/CocoaLumberjack.h>
 
 ############################## ############################## #################
 Step 4-b: Adding Resources
 ############################## ############################## #################
 If you are developing resources for your framework you can also add the bundle
 target as a dependency.
 
 You must then add the bundle to the Copy Bundle Resources phase of your
 application by expanding the products folder of your framework product and
 dragging the .bundle into that section.
 
 
 ############################## ############################## #################
 Step 5: Build and Test
 ############################## ############################## #################
 Build your application and verify a couple things:
 
 # Your framework should be built before your application.
 # Your framework should be linked into the application.
 # You shouldn't get any compiler or linker errors.
 
 */

#import <Foundation/Foundation.h>

#import <CocoaLumberjack/DDAbstractDatabaseLogger.h>
#import <CocoaLumberjack/DDASLLogger.h>
#import <CocoaLumberjack/DDFileLogger.h>
#import <CocoaLumberjack/DDLog.h>
#import <CocoaLumberjack/DDTTYLogger.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
