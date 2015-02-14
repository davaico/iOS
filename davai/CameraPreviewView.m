//
//  CameraPreviewView.m
//  Video Recording
//
//  Created by Zhi Li on 2014-09-24.
//  Copyright (c) 2014 Zhi Li. All rights reserved.
//

#import "CameraPreviewView.h"

@implementation CameraPreviewView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session
{
    return [(AVCaptureVideoPreviewLayer *)[self layer] session];
}

- (void)setSession:(AVCaptureSession *)session
{
    [(AVCaptureVideoPreviewLayer *)[self layer] setSession:session];
}



@end
