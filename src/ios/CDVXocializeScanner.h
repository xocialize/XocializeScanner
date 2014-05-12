//
//  CDVXocializeScanner.h
//  Xocialize
//
//  Created by Dustin Nielson on 5/1/14.
//
//

#import <Foundation/Foundation.h>

#import <Cordova/CDV.h>
#import <UIKit/UIKit.h>


@class UIViewController;


@interface CDVXocializeScanner : CDVPlugin {
    
    UIView* parentView;
    
    NSString *_callback;
    
    NSArray *_barCodeResults;
    
    NSArray *_barCodeTypes;
    
}

- (void) cordovaGetBC:(CDVInvokedUrlCommand *)command;

@end
