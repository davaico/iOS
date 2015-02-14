//
//  CameraViewController.m
//  davai
//
//  Created by Zhi Li on 2014-09-26.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import "CameraViewController.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

NSTimeInterval kLocationServiceInterval = 1.0;

@interface CameraViewController ()

@end

@implementation CameraViewController

- (BOOL)isSessionRunningAndDeviceAuthorized
{
    return [[self session] isRunning] && [self isDeviceAuthorized];
}

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
{
    return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create the AVCaptureSession
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    self.session = session;
    [session setSessionPreset:AVCaptureSessionPresetMedium];
    
    // Setup the preview view
    self.previewView.session = session;
    self.previewView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    self.sessionQueue = sessionQueue;
    
    dispatch_async(sessionQueue, ^{
        NSError *error = nil;
        
        AVCaptureDevice *videoDevice = [CameraViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (error)
            NSLog(@"%@", error);
        
        if ([session canAddInput:videoDeviceInput])
        {
            [session addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [(AVCaptureVideoPreviewLayer *)[[self previewView] layer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
                [[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
            });
        }
        
        AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
        AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
        
        if (error)
            NSLog(@"%@", error);
        
        if ([session canAddInput:audioDeviceInput])
            [session addInput:audioDeviceInput];
        
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        if ([session canAddOutput:movieFileOutput])
        {
            [session addOutput:movieFileOutput];
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
//            NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
//            if(version.majorVersion < 8){
                if ([connection isVideoStabilizationSupported])
                    connection.enablesVideoStabilizationWhenAvailable = YES;
//            }
//            else {
//                if (connection.supportsVideoStabilization)
//                    [connection setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeAuto];
//            }
            [self setMovieFileOutput:movieFileOutput];
        }
        
    });
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.desiredHorizontalAccuracy = kCLLocationAccuracyBest;
    self.locationManager.desiredAccuracy = self.desiredHorizontalAccuracy;
    
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToFocus:)];
    [self.previewView addGestureRecognizer:self.tapGestureRecognizer];
    
    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToRecord:)];
    self.longPressGestureRecognizer.numberOfTapsRequired = 0;
    self.longPressGestureRecognizer.minimumPressDuration = 0.0;
    [self.recordIconView addGestureRecognizer:self.longPressGestureRecognizer];
    
    self.recordIconView.userInteractionEnabled = YES;
    self.barTitle.text = @"Record";
    [self.cameraButton setImage:[UIImage imageNamed:@"Switch to Rear Facing Camera"] forState:UIControlStateNormal];
    [self.view bringSubviewToFront:self.actionBarView];
}


#pragma mark File Output Delegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    if (error)
        NSLog(@"%@", error);
    
    self.outputFileURL = outputFileURL;
    
    VideoReviewViewController *videoReviewViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoReviewViewController"];
    videoReviewViewController.delegate = self;
    videoReviewViewController.videoFileUrl = outputFileURL;
    [videoReviewViewController setupPlayer];
    [self presentViewController:videoReviewViewController animated:YES completion:nil];
}




- (void)checkDeviceAuthorizationStatus
{
    NSString *mediaType = AVMediaTypeVideo;
    
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if (granted)
        {
            //Granted access to mediaType
            [self setDeviceAuthorized:YES];
        }
        else
        {
            //Not granted access to mediaType
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"davai!"
                                            message:@"davai doesn't have permission to use Camera, please change privacy settings"
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
                [self setDeviceAuthorized:NO];
            });
        }
    }];
}




- (void)viewWillAppear:(BOOL)animated
{
    // start updating location
    [self startLocationService];
    
    // update the record icon
    self.recordIconView.hidden = YES;
    self.recordIconView.image = [self getRecordIconWithPercent:1.0];
    
    // start the camera preview
    dispatch_async([self sessionQueue], ^{
        //        [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
        //        [self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        
        __weak CameraViewController *weakSelf = self;
        [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
            CameraViewController *strongSelf = weakSelf;
            dispatch_async([strongSelf sessionQueue], ^{
                // Manually restarting the session since it must have been stopped due to an error.
                [[strongSelf session] startRunning];
            });
        }]];
        [[self session] startRunning];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.recordIconView.hidden = NO;
        });

    });
}

- (void)viewDidDisappear:(BOOL)animated
{
    // stop updating location
    if (self.locationServiceTimer) {
        [self.locationServiceTimer invalidate];
        self.locationServiceTimer = nil;
    }
    [self.locationManager stopUpdatingLocation];
    
    // stop camera
    dispatch_async([self sessionQueue], ^{
        [[self session] stopRunning];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
    });
}

//- (BOOL)prefersStatusBarHidden
//{
//    return YES;
//}
//
//- (BOOL)shouldAutorotate
//{
//    // Disable autorotation of the interface when recording is in progress.
//    return ![self lockInterfaceRotation];
//}
//
//- (NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskAll;
//}
//
//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    [[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
//}


//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    if (context == RecordingContext)
//    {
//        BOOL isRecording = [change[NSKeyValueChangeNewKey] boolValue];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (isRecording)
//            {
//                ;
//            }
//            else
//            {
//                ;
//            }
//        });
//    }
//    else if (context == SessionRunningAndDeviceAuthorizedContext)
//    {
//        BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (isRunning)
//            {
//                ;
//            }
//            else
//            {
//                ;
//            }
//        });
//    }
//    else
//    {
//        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
//    }
//}

- (void)tapToFocus:(UITapGestureRecognizer *)gesture{
    
    CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)[[self previewView] layer] captureDevicePointOfInterestForPoint:[gesture locationInView:[gesture view]]];
    [self focusWithMode:AVCaptureFocusModeAutoFocus
         exposeWithMode:AVCaptureExposureModeAutoExpose
          atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
    
    
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *device = [[self videoDeviceInput] device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
            {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            }
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
            {
                [device setExposureMode:exposureMode];
                [device setExposurePointOfInterest:point];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        }
        else
            NSLog(@"%@", error);
    });
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
    if ([device hasFlash] && [device isFlashModeSupported:flashMode])
    {
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        }
        else
            NSLog(@"%@", error);
    }
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
        {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}



- (void)changeCamera
{
    self.cameraButton.enabled = NO;
    self.recordIconView.userInteractionEnabled = NO;

    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
        AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
        AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
        
        switch (currentPosition)
        {
            case AVCaptureDevicePositionUnspecified:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
            case AVCaptureDevicePositionBack:
                preferredPosition = AVCaptureDevicePositionFront;
                break;
            case AVCaptureDevicePositionFront:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
        }
        
        AVCaptureDevice *videoDevice = [CameraViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
        
        [[self session] beginConfiguration];
        
        [[self session] removeInput:[self videoDeviceInput]];
        if ([[self session] canAddInput:videoDeviceInput])
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
            
            [CameraViewController setFlashMode:AVCaptureFlashModeAuto forDevice:videoDevice];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];
            
            [[self session] addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
        }
        else
            [[self session] addInput:[self videoDeviceInput]];
        
        [[self session] commitConfiguration];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
            if (currentPosition == AVCaptureDevicePositionBack) {
                [self.cameraButton setImage:[UIImage imageNamed:@"Switch to Front Facing Camera"] forState:UIControlStateNormal];

            }
            else if (currentPosition == AVCaptureDevicePositionFront) {
                [self.cameraButton setImage:[UIImage imageNamed:@"Switch to Rear Facing Camera"] forState:UIControlStateNormal];

            }
            self.cameraButton.enabled = YES;
            self.recordIconView.userInteractionEnabled = YES;
        });
    });
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
    CGPoint devicePoint = CGPointMake(.5, .5);
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}



- (void)longPressToRecord:(UILongPressGestureRecognizer*)gesture{
    
    if (gesture.state == UIGestureRecognizerStateBegan){
        
        dispatch_async([self sessionQueue], ^{
            [self setLockInterfaceRotation:YES];
            
            // Update the orientation on the movie file output video connection before starting recording.
            [[[self movieFileOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
            
            // Turning OFF flash for video recording
            [CameraViewController setFlashMode:AVCaptureFlashModeOff forDevice:[[self videoDeviceInput] device]];
            
            // Start recording to a temporary file.
            NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"movie" stringByAppendingPathExtension:@"mov"]];
            [[self movieFileOutput] startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                self.recordStartingTime = [NSDate new];
                self.recordIconLastUpdateTime = self.recordStartingTime;
                
                if (self.recordIconUpdateTimer != nil) {
                    [self.recordIconUpdateTimer invalidate];
                    self.recordIconUpdateTimer = nil;
                }
                
                self.recordIconUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:kRecordIconUpdateInterval
                                                                              target:self
                                                                            selector:@selector(updateRecordIcon)
                                                                            userInfo:nil repeats:YES];
                
                if (self.recordingTimer != nil) {
                    [self.recordingTimer invalidate];
                    self.recordingTimer = nil;
                }
                self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval:kMaximumVideoDuration target:self selector:@selector(timesup:) userInfo:nil repeats:NO];
            });
            
            
        });
        
//        NSLog(@"Started Recording");
    }
    
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
//        self.recordIconLocation = [gesture locationInView:[gesture view]];
//        self.recordIconView.center = self.recordIconLocation;
        ;
    }
    
    
    
    if (gesture.state == UIGestureRecognizerStateEnded){
        dispatch_async([self sessionQueue], ^{
            [[self movieFileOutput] stopRecording];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (self.recordingTimer != nil) {
                    [self.recordingTimer invalidate];
                    self.recordingTimer = nil;
                }
                if (self.recordIconUpdateTimer != nil) {
                    [self.recordIconUpdateTimer invalidate];
                    self.recordIconUpdateTimer = nil;
                }
                self.recordStartingTime = nil;
                self.recordIconLastUpdateTime = nil;
            });

        });
//        NSLog(@"Stopped Recording");

    }
}






- (void)updateRecordIcon
{
    self.recordIconLastUpdateTime = [NSDate new];
    NSTimeInterval timeElapsed = [self.recordIconLastUpdateTime timeIntervalSinceDate:self.recordStartingTime];
    self.recordIconView.image = [self getRecordIconWithPercent:(timeElapsed / kMaximumVideoDuration)];
}

- (UIImage*)getRecordIconWithPercent:(CGFloat) percent
{
    
    if (percent > 1.0)
        percent = 1.0;
    
    CGSize size = CGSizeMake(kRecordIconHeight, kRecordIconHeight);
//    CGSize size = self.recordButton.frame.size;
    
    CGPoint circleCenter = CGPointMake(size.width / 2, size.height / 2);
    CGFloat circleRadius = size.width / 2 * 0.7;
    
    UIGraphicsBeginImageContext(size);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:circleCenter
                    radius:circleRadius
                startAngle:M_PI * -0.5
                  endAngle:-0.5 * M_PI + M_PI * 2.0 * percent
                 clockwise:YES];
    
    [[UIColor whiteColor] setStroke];
    [path setMiterLimit:-10.0];
    [path setLineWidth:12.0];
    [path stroke];
    
    
    path = [UIBezierPath bezierPath];
    [path addArcWithCenter:circleCenter
                    radius:circleRadius - 4
                startAngle: 0.0
                  endAngle:2 * M_PI
                 clockwise:YES];

    [[UIColor colorWithRed:233.0f/255.0f green:105.0f/255.0f blue:106.0f/255.0f alpha:1.0f] setFill];
    [path fill];

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(void)saveWithInfo:(NSDictionary*)info
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [format setTimeZone:timeZone];
    [format setDateFormat:@"yyyyMMdd_HHmmss"];
    NSDate *now = [NSDate new];
    NSString *date = [format stringFromDate:now];
    NSString* filename = [NSString stringWithFormat:@"%@.%@", date, [self.outputFileURL pathExtension]];
    
    NSMutableDictionary *videoInfo = [[NSMutableDictionary alloc]initWithDictionary:info];
    NSURL *videoURL = [self saveFileWithName:filename];
    [videoInfo setObject:[videoURL absoluteString] forKey:@"localURL"];
    [videoInfo setObject:[NSNumber numberWithDouble:self.currentLocation.coordinate.latitude] forKey:@"latitude"];
    [videoInfo setObject:[NSNumber numberWithDouble:self.currentLocation.coordinate.longitude] forKey:@"longitude"];
    [videoInfo setObject:now forKey:@"date"];
    
    
    NSString *filePath = [videoURL path];
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:filePath] options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality])
    {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetPassthrough];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *newFilePath = [NSString stringWithFormat:@"%@/Videos/%@.mp4", [paths objectAtIndex:0], [filename stringByDeletingPathExtension]];
        exportSession.outputURL = [NSURL fileURLWithPath:newFilePath];
//        NSLog(@"videopath of your mp4 file = %@",newFilePath);  // PATH OF YOUR .mp4 FILE
        exportSession.outputFileType = AVFileTypeMPEG4;
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusFailed:
                NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Export canceled");
                break;
            default:
                break;
        }
        NSURL *oldFileURL = [NSURL fileURLWithPath:filePath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtURL:oldFileURL error:nil];
        
        [videoInfo setObject:[exportSession.outputURL absoluteString] forKey:@"localURL"];
    }
    
    
//    NSLog(@"cvc videoInfo %@", videoInfo);

    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate postVideo:videoInfo];
    }];
}

- (void)cancel
{
    [self removeFile];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (NSURL*)saveFileWithName:(NSString*)filename
{
    
    NSFileManager *fileManager;
    NSArray *dirPaths;
    NSString *docsDir;
    NSString *newDir;
    
    fileManager = [NSFileManager defaultManager];
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                   NSUserDomainMask, YES);
    
    docsDir = dirPaths[0];
    newDir = [docsDir stringByAppendingPathComponent:@"Videos"];
    
    if ([fileManager createDirectoryAtPath:newDir
               withIntermediateDirectories:YES
                                attributes:nil
                                     error: nil] == NO)
    {
        // Failed to create directory
    }
    
    
    NSString* videoPath = [newDir stringByAppendingPathComponent:filename];
    
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    
    
    if (![fileManager fileExistsAtPath:videoPath])
        [fileManager moveItemAtURL:self.outputFileURL toURL:videoURL error:nil];

//    NSLog(@"saved file %@", self.outputFileURL);
//    NSLog(@"saved to %@", videoURL);
    return videoURL;
//    [(id<CameraViewControllerDelegate>)self.delegate didAddNewVideo];
}

- (void)removeFile
{
    [[NSFileManager defaultManager] removeItemAtURL:self.outputFileURL error:nil];
//    NSLog(@"deleted file %@", self.outputFileURL);
}

- (void)exploreButtonOnVideoReviewViewTapped
{
    [self removeFile];
    [self exploreButtonTapped];
}
- (void)settingButtonOnVideoReviewViewTapped
{
    [self removeFile];
    [self settingButtonTapped];
}
- (void)cameraButtonOnVideoReviewViewTapped
{
    [self removeFile];
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)exploreButtonTapped
{
    ActionBarViewControllerCollection *actionBarViewControllerCollection = [ActionBarViewControllerCollection sharedCollection];
    ActionViewController *actionViewController = actionBarViewControllerCollection.exploreViewController;
    [self.delegate transitFromActionViewController:self toActionViewController:actionViewController animated:YES];
}
- (void)settingButtonTapped
{
    ActionBarViewControllerCollection *actionBarViewControllerCollection = [ActionBarViewControllerCollection sharedCollection];
    ActionViewController *actionViewController = actionBarViewControllerCollection.settingViewController;
    [self.delegate transitFromActionViewController:self toActionViewController:actionViewController animated:YES];
}
- (void)cameraButtonTapped
{
    [self changeCamera];
}


- (void)timesup:(NSTimer *)timer
{
    [self.longPressGestureRecognizer setState:UIGestureRecognizerStateEnded];
}





#pragma mark - Location Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
//    NSLog(@"new location: %f, %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);

    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) {
        return;
    }
    
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    
    // test the measurement to see if it is more accurate than the previous measurement
    if (self.currentLocation == nil ||
        self.currentLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        
        // store the location as the "best effort"
        self.currentLocation = newLocation;
        
//        NSLog(@"current location: %f, %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
        
        // stop updating location
        [self.locationManager stopUpdatingLocation];
        // schedule the next update
        if (self.locationServiceTimer) {
            [self.locationServiceTimer invalidate];
            self.locationServiceTimer = nil;
        }
        self.locationServiceTimer = [NSTimer scheduledTimerWithTimeInterval:kLocationServiceInterval
                                                                     target:self
                                                                   selector:@selector(startLocationService)
                                                                   userInfo:nil
                                                                    repeats:NO];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error code] != kCLErrorLocationUnknown) {
        NSLog(@"%@", error);
    }
}

- (void)startLocationService
{
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        [self.locationManager requestWhenInUseAuthorization];

    [self.locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
