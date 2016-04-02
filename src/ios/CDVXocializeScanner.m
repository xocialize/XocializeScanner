//
//  CDVXocializeScanner.m
//  Xocialize
//
//  Created by Dustin Nielson on 5/1/14.
//
//
#import <AVFoundation/AVFoundation.h>
#import "CDVXocializeScanner.h"

@class UIViewController;

@interface CDVXocializeScanner () <AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureSession *_session;
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_output;
    AVCaptureVideoPreviewLayer *_prevLayer;
    
    UILabel *_label;
    UINavigationBar *_navcon;
    UILabel *_navtitle;
}

@end

@implementation CDVXocializeScanner

-(CDVPlugin*) initWithWebView:(UIWebView*)theWebView
{
    //self = (CDVXocializeScanner*)[super initWithWebView:theWebView];
    //return self;
    [self pluginInitialize];
}

- (void) cordovaGetBC:(CDVInvokedUrlCommand *)command
{
    
    _navcon = [[UINavigationBar alloc] init];
    [_navcon setFrame:CGRectMake(0,0,self.webView.superview.bounds.size.width,64)];
    
    _navtitle = [[UILabel alloc]initWithFrame:CGRectMake(0,10,self.webView.superview.bounds.size.width,64)];
    _navtitle.text = @"Scanner";
    _navtitle.textAlignment = NSTextAlignmentCenter;
    
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    navItem.title = @"Scanner";
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(closeView:)];
    navItem.leftBarButtonItem = leftButton;
    
    _navcon.items = @[ navItem ];
    
    [self.webView.superview addSubview:_navcon];
    
    _label = [[UILabel alloc] init];
    _label.frame = CGRectMake(0, self.webView.superview.bounds.size.height - 40, self.webView.superview.bounds.size.width, 40);
    _label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _label.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.65];
    _label.textColor = [UIColor whiteColor];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"Scanning";
    [self.webView.superview addSubview:_label];
    
    _session = [[AVCaptureSession alloc] init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (_input) {
        [_session addInput:_input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];
    
    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];
    
    _prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _prevLayer.frame = self.webView.superview.bounds;
    _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.webView.superview.layer addSublayer:_prevLayer];
    
    [_session startRunning];
    
    [self.webView.superview bringSubviewToFront:_label];
    [self.webView.superview bringSubviewToFront:_navcon];
    
    _callback = command.callbackId;
    
    _barCodeTypes = command.arguments;
    
}

- (void) closeView :(id)sender{
    
    [_prevLayer performSelectorOnMainThread:@selector(removeFromSuperlayer) withObject:nil waitUntilDone:NO];
    
    [_label performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
    
    [_navtitle performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
    
    [_navcon performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
    
    [_session stopRunning];
    
    [_session removeOutput:_output];
    
    [_session removeInput:_input];
    
    _output = nil;
    
    _input = nil;
    
    _device = nil;
    
    _session = nil;
    
    _barCodeResults = @[@"",@"",@"0"];
    
    CDVPluginResult *pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray: _barCodeResults];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:_callback];
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    
    AVMetadataMachineReadableCodeObject *barCodeObject;
    
    NSString *detectionString = nil;
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in _barCodeTypes) {
            
            if ([metadata.type isEqualToString:type])
            {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                
                _barCodeResults = @[[(AVMetadataMachineReadableCodeObject *)metadata stringValue],metadata.type,@"1"];
                
                break;
            }
        }
        
        if (detectionString != nil)
        {
            _label.text = detectionString;
            
            [_prevLayer performSelectorOnMainThread:@selector(removeFromSuperlayer) withObject:nil waitUntilDone:NO];
            
            [_label performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
            
            [_navtitle performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
            
            [_navcon performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
            
            [_session stopRunning];
            
            [_session removeOutput:_output];
            
            [_session removeInput:_input];
            
            _output = nil;
            
            _input = nil;
            
            _device = nil;
            
            _session = nil;
            
            CDVPluginResult *pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray : _barCodeResults];
            
            [self.commandDelegate sendPluginResult:pluginResult callbackId:_callback];
            
            break;
            
        }
        else
            _label.text = @"Scanning";
    }
    
    
}

@end
