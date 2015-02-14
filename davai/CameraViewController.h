//
//  CameraViewController.h
//  davai
//
//  Created by Zhi Li on 2014-09-26.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import "CameraPreviewView.h"
#import "VideoReviewViewController.h"
#import "ActionViewController.h"
#import "ActionBarViewControllerCollection.h"


static NSTimeInterval kMaximumVideoDuration = 15.0;
static NSTimeInterval kRecordIconUpdateInterval=0.1;
static int kRecordIconHeight = 128;

static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;


@protocol CameraViewControllerDelegate <NSObject>

@required

-(void)postVideo:(NSDictionary*)info;

@end



@interface CameraViewController : ActionViewController <CLLocationManagerDelegate, AVCaptureFileOutputRecordingDelegate, VideoSubmitViewControllerDelegate, VideoReviewViewControllerDelegate>


@property (nonatomic, weak) IBOutlet CameraPreviewView *previewView;

@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.


@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, strong) NSTimer *recordingTimer;

// Utilities.
//@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;


@property (nonatomic, strong) NSDate *recordStartingTime;
@property (nonatomic, strong) NSDate *recordIconLastUpdateTime;

@property (nonatomic) CGPoint recordIconLocation;
@property (nonatomic, strong) NSTimer *recordIconUpdateTimer;


@property (nonatomic, strong) NSURL *outputFileURL;


@property (nonatomic, weak) IBOutlet UIImageView *recordIconView;





@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) NSTimer *locationServiceTimer;
@property (nonatomic) CLLocationAccuracy desiredHorizontalAccuracy;





// Delegate Methods
- (void)saveWithInfo:(NSDictionary*)userInfo;
- (void)cancel;


- (void)exploreButtonOnVideoReviewViewTapped;
- (void)settingButtonOnVideoReviewViewTapped;
- (void)cameraButtonOnVideoReviewViewTapped;



@end
