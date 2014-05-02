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
    
    UIView *_highlightView;
    UILabel *_label;
}

@end



@implementation CDVXocializeScanner

-(CDVPlugin*) initWithWebView:(UIWebView*)theWebView
{
    self = (CDVXocializeScanner*)[super initWithWebView:theWebView];
    return self;
}

- (void) cordovaGetBC:(CDVInvokedUrlCommand *)command
{
    
    _highlightView = [[UIView alloc] init];
    _highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    _highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    _highlightView.layer.borderWidth = 3;
    [self.webView.superview addSubview:_highlightView];
    
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
    
    [self.webView.superview bringSubviewToFront:_highlightView];
    [self.webView.superview bringSubviewToFront:_label];
    
    //_barcode = @"testing works";
    
    _barcodetest = command.callbackId;
    
    _barcode = nil;
    
       
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
 
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type])
            {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                
                _barcode = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                
                break;
            }
        }
        
        if (detectionString != nil)
        {
            _label.text = detectionString;
            
            CDVPluginResult *pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: _barcode];
            
            [self.commandDelegate sendPluginResult:pluginResult callbackId:_barcodetest];
            
            [_prevLayer performSelectorOnMainThread:@selector(removeFromSuperlayer) withObject:nil waitUntilDone:NO];
            
            [_highlightView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
            
            [_label performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
            
            break;
            
        }
        else
            _label.text = @"Scanning";
    }
    
    _highlightView.frame = highlightViewRect;
}

@end
