//
//  NetworkController.m
//  davai
//
//  Created by Zhi Li on 2014-11-25.
//  Copyright (c) 2014 Davai. All rights reserved.
//

#import "NetworkController.h"

@implementation NetworkController

NSString *const AWSAccountID = @"850451620997";
NSString *const CognitoPoolID = @"us-east-1:1d097b8e-27fd-46fa-b6fe-2a4ee8baeea1";
NSString *const CognitoRoleAuth = @"arn:aws:iam::850451620997:role/Cognito_Davai_TestAuth_DefaultRole";
NSString *const CognitoRoleUnauth = @"arn:aws:iam::850451620997:role/Cognito_Davai_TestUnauth_DefaultRole";
NSString *const S3BucketName = @"davaivideo";


#pragma mark -
#pragma mark Private Initialization
- (id)init {
    self = [super init];
    
    if (self) {
        // Initialize Reachability
        self.reachability = [Reachability reachabilityForInternetConnection];
        
        // Start Monitoring
        [self.reachability startNotifier];
        [self setupAWSService];
        
        self.uploads = [[NSMutableArray alloc]init];
        self.downloads = [[NSMutableArray alloc]init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appDidBecomeForeground)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appDidEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        self.isDownloading = NO;
        self.isUploading = NO;
        
        // network condictions
    }
    
    return self;
}


+ (id)sharedController {
    static NetworkController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)setupAWSService
{
    [AWSLogger defaultLogger].logLevel = AWSLogLevelError;
    AWSCognitoCredentialsProvider *credentialsProvider = [AWSCognitoCredentialsProvider
                                                          credentialsWithRegionType:AWSRegionUSEast1
                                                          accountId:AWSAccountID
                                                          identityPoolId:CognitoPoolID
                                                          unauthRoleArn:CognitoRoleUnauth
                                                          authRoleArn:CognitoRoleAuth];
    
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSEast1
                                                                          credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
}

- (void)appDidBecomeForeground
{
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    for (NSDictionary *uploadRequestInfo in self.uploads) {
        AWSS3TransferManagerUploadRequest *uploadRequest = [uploadRequestInfo objectForKey:@"request"];
        NSDictionary *videoDict = [uploadRequestInfo objectForKey:@"videoDict"];
//        NSLog(@"video Dict resume upload video file : %@", videoDict);
        [[transferManager upload:uploadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor]
                                                           withBlock:^id(BFTask *task) {
//            NSLog(@"in block");
            if (task.error) {
                if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                    switch (task.error.code) {
                        case AWSS3TransferManagerErrorCancelled:
                        case AWSS3TransferManagerErrorPaused:
                            break;
    
                        default:
                            NSLog(@"Error: %@", task.error);
                            break;
                    }
                } else {
                    // Unknown error.
                    NSLog(@"Error: %@", task.error);
                }
            }
    
            if (task.result) {
                AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
    //            [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoFileDidUpload" object:nil userInfo:videoDict];
                // The file uploaded successfully.
//                NSLog(@"The file uploaded successfully.");
                [self.uploads removeObject:uploadRequestInfo];
                [self postVideo:videoDict];
            }
            return nil;
        }];
    }
//    [transferManager resumeAll:nil];
}

- (void)appDidEnterBackground
{
//    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    for (NSDictionary *uploadRequestInfo in self.uploads) {
        AWSS3TransferManagerUploadRequest *uploadRequest = [uploadRequestInfo objectForKey:@"request"];
        [uploadRequest pause];
    }
//    [transferManager pauseAll];
}



- (BOOL)hasConnectivity
{
    NetworkStatus networkStatus = [self.reachability currentReachabilityStatus];
    if (networkStatus == NotReachable)
//    if ([self.reachability connectionRequired] || networkStatus == NotReachable)
        return NO;
    else
        return YES;
}

/*
 register
 */
+ (NSDictionary*)registerWithUserData:(NSDictionary*)userData
{
    NSMutableDictionary *user = nil;
    
    NSString *command = @"register";
    NSString *username = [userData objectForKey:@"username"];
    NSString *password = [userData objectForKey:@"password"];
    NSString *email = [userData objectForKey:@"email"];
    NSString *real_name = @"";
    NSString *home = @"";
    
    NSString *post = [NSString stringWithFormat:@"command=%@&username=%@&password=%@&real_name=%@&email=%@&home=%@",command, username, password, real_name, email, home];
//    NSLog(@"%@", post);
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.davai.co/login.php"]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLResponse *response = nil;
    NSError *connectionError = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
    if (response) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//        NSLog(@"Response Status Code: %ld", (long)[httpResponse statusCode]);
    }
    if (connectionError) {
        NSLog(@"Response Connection Error: %@", connectionError);
    }
    else {
        
        if (data != nil && [data length] > 0) {
//            NSLog(@"Returned Data: %@", data);
            
            NSString *dataString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"Returned Data String: %@", dataString);
            BOOL contains = ([dataString rangeOfString:@"already in use"].location != NSNotFound);
            if (!contains) {
                NSError *error;
                NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                
                NSDictionary *dict = [jsonArray objectAtIndex:0];
                
                if (dict) {
                    user = [[NSMutableDictionary alloc]init];
                    [user setObject:username forKey:@"username"];
                    
                    [user setObject:password forKey:@"password"];
                    [user setObject:email forKey:@"email"];
                    if ([dict objectForKey:@"home"])
                        [user setObject:[dict objectForKey:@"home"] forKey:@"home"];
                    if ([dict objectForKey:@"real_name"])
                        [user setObject:[dict objectForKey:@"real_name"] forKey:@"realname"];
                    if ([dict objectForKey:@"uuid"])
                        [user setObject:[dict objectForKey:@"uuid"] forKey:@"uuid"];
                    if ([dict objectForKey:@"id"])
                        [user setObject:[dict objectForKey:@"id"] forKey:@"id"];
                }
            
            }
        }
    }
//    NSLog(@"REGISTER");
    
    return user;
}

/*
 login
 */

+ (NSDictionary*)logInWithUserData:(NSDictionary*)userData;
{
    NSMutableDictionary *user = nil;
    
    NSString *command = @"login";
    NSString *username = [userData objectForKey:@"username"];
    NSString *password = [userData objectForKey:@"password"];
    
    NSString *post = [NSString stringWithFormat:@"command=%@&username=%@&password=%@",command, username, password];
    NSLog(@"%@", post);
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.davai.co/login.php"]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLResponse *response = nil;
    NSError *connectionError = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
    if (response) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//        NSLog(@"Response Status Code: %ld", (long)[httpResponse statusCode]);
    }
    if (connectionError) {
        NSLog(@"Response Connection Error: %@", connectionError);
    }
    else {
        if (data != nil && [data length] > 0) {
            NSLog(@"Returned Data: %@", data);

            NSString *dataString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Returned Data String: %@", dataString);
            
            NSError *error;
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            NSDictionary *dict = [jsonArray objectAtIndex:0];
            
            if (dict) {
                user = [[NSMutableDictionary alloc]init];
                [user setObject:username forKey:@"username"];
                [user setObject:password forKey:@"password"];
                [user setObject:[dict objectForKey:@"email"] forKey:@"email"];
                [user setObject:[dict objectForKey:@"home"] forKey:@"home"];
                [user setObject:[dict objectForKey:@"real_name"] forKey:@"realname"];
                [user setObject:[dict objectForKey:@"uuid"] forKey:@"uuid"];
                [user setObject:[dict objectForKey:@"id"] forKey:@"id"];
//                [user setObject:[NSNumber numberWithLong:[[dict objectForKey:@"id"] integerValue]] forKey:@"id"];
            }
        }
    }
//    NSLog(@"LOGIN");
    
    return user;
}

- (void)uploadVideoFile:(NSDictionary*)videoDict
{
//    NSLog(@"Upload");
    NSString *filePath = [videoDict objectForKey:@"localURL"];
    
    NSString *videokey = [videoDict objectForKey:@"videokey"];
//    NSLog(@"file path: %@", filePath);
    NSURL *url = [NSURL URLWithString:filePath];
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];

    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = S3BucketName;
    uploadRequest.key = videokey;
    uploadRequest.body = url;
    
    NSDictionary *uploadRequestInfo = @{ @"request":uploadRequest,
                                         @"videoDict":videoDict};
    
    
//    NSLog(@"video Dict upload video file : %@", videoDict);
    [self.uploads addObject:uploadRequestInfo];
    [[transferManager upload:uploadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor]
                                                       withBlock:^id(BFTask *task) {
//        NSLog(@"in block");
        if (task.error) {
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                        break;

                    default:
                        NSLog(@"Error: %@", task.error);
                        break;
                }
            } else {
                // Unknown error.
                NSLog(@"Error: %@", task.error);
            }
        }

        if (task.result) {
            AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoFileDidUpload" object:nil userInfo:videoDict];
            // The file uploaded successfully.
//            NSLog(@"The file uploaded successfully.");
            [self.uploads removeObject:uploadRequestInfo];
            [self postVideo:videoDict];
        }
        return nil;
        }];
}


/*
 post video related information to featuredKremlin.php
 */
- (void)postVideo:(NSDictionary*)videoDict
{
    
    NSString *username = [videoDict objectForKey:@"author"];
    NSString *latitude = [videoDict objectForKey:@"latitude"];
    NSString *longitude = [videoDict objectForKey:@"longitude"];
    NSString *videokey = [videoDict objectForKey:@"videokey"];
    videokey = [[videokey componentsSeparatedByString:@"/"] objectAtIndex:1];
    NSString *caption = [videoDict objectForKey:@"caption"];
    NSString *location = [videoDict objectForKey:@"location"];
    
    
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [format setTimeZone:timeZone];
    [format setDateFormat:@"yyyyMMdd_HHmmss_z"];
    NSDate *date = [videoDict objectForKey:@"date"];
    NSString *time = [format stringFromDate:date];
    
    NSString *post = [NSString stringWithFormat:@"username=%@&videokey=%@&latitude=%@&longitude=%@&title=%@&location=%@&time=%@", username, videokey, latitude, longitude, caption, location, time];
//    NSLog(@"post: %@", post);
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.davai.co/app.php"]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError)
     {
//         NSLog(@"app.php");
         if (response) {
             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
             NSLog(@"Response Status Code: %ld", (long)[httpResponse statusCode]);
             if ([httpResponse statusCode] == 200 && connectionError == nil) {
                 if (data.length > 0) {
                     NSString *dataString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//                     NSLog(@"Returned Data: %@", dataString);
                     NSError *error;
                     //             NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                     //             NSLog(@"Returned Data Json: %@", jsonDict);
                     NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//                     NSLog(@"Returned Data Json: %@", jsonArray);
                     if (jsonArray) {
                         NSString *videoID = [jsonArray objectAtIndex:0];
                         NSMutableDictionary *newVideoDict = [NSMutableDictionary dictionaryWithDictionary:videoDict];
                         [newVideoDict setObject:videoID
                                          forKey:@"videoID"];
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoInformationDidPost" object:nil userInfo:newVideoDict];
                     }
                 }
             }
         }
         if (connectionError != nil){
             NSLog(@"Error: %@", connectionError);
         }
     }];
    
//    NSLog(@"APP.PHP");
}

/*
 fetch related videos
 */

- (void)fetchVideos:(NSString*)username
{
        NSString *post = [NSString stringWithFormat:@"username=%@", username];
//        NSLog(@"%@", post);
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.davai.co/featuredKremlin.php"]];
    
    
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
    
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response,
                                                   NSData *data,
                                                   NSError *connectionError)
         {
//             NSLog(@"featuredKremlin.php");
             if (response) {
                 NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//                 NSLog(@"Response Status Code: %ld", (long)[httpResponse statusCode]);
                 DataController *dataController = [DataController sharedController];
                 if (data.length > 0) {
                     NSString *dataString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//                     NSLog(@"Returned Data: %@", dataString);
                     NSError *error;
                     NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//                     NSLog(@"Returned Data Json: %@", jsonDict);
                     
                     error = nil;
                     NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                     
//                     NSLog(@"count %lu", (unsigned long)[jsonArray count]);
                     for (NSDictionary *dict in jsonArray) {
//                         NSLog(@"video_id : %@", [dict objectForKey:@"video_id"]);
//                         NSLog(@"link : %@", [dict objectForKey:@"link"]);
//                         NSLog(@"username : %@", [dict objectForKey:@"username"]);
//                         NSLog(@"\n");

                         NSMutableDictionary *videoDict = [[NSMutableDictionary alloc]init];
                         [videoDict setValue:[dict objectForKey:@"title"] forKey:@"caption"];
                         [videoDict setValue:[dict objectForKey:@"video_id"] forKey:@"videoID"];
                         [videoDict setValue:[dict objectForKey:@"username"] forKey:@"username"];
                         [videoDict setValue:[dict objectForKey:@"link"] forKey:@"link"];
                         [videoDict setValue:[dict objectForKey:@"location"] forKey:@"location"];
                         [videoDict setValue:[NSNumber numberWithDouble:[[videoDict objectForKey:@"latitude"] doubleValue]] forKey:@"latitude"];
                         [videoDict setValue:[NSNumber numberWithDouble:[[videoDict objectForKey:@"longitude"] doubleValue]] forKey:@"longitude"];
                         [videoDict setValue:[NSNumber numberWithInt:[[videoDict objectForKey:@"numberOfLikes"] doubleValue]] forKey:@"numberOfLikes"];
//                         [videoDict setValue:[NSNumber numberWithBool:[[videoDict objectForKey:@"liked"] doubleValue]] forKey:@"liked"];
                         NSDateFormatter *format = [[NSDateFormatter alloc] init];
                         NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
                         [format setTimeZone:timeZone];
                         [format setDateFormat:@"yyyyMMdd_HHmmss_Z"];
                         NSDate *date = [format dateFromString:[dict objectForKey:@"time"]];
                         [videoDict setObject:date forKey:@"date"];
                         
                         
                         if ([dataController videoWithVideoID:[dict objectForKey:@"video_id"]] == nil) {
                             [self downloadVideoFile:videoDict];
                         }
                         else {
                             [self fetchComments:videoDict];
                         }
                     }
                 }
             }
             
             if (connectionError != nil){
                 NSLog(@"Error: %@", connectionError);
             }
         }];
    
}

/*
 post a comment
 */

- (void)postComment:(NSDictionary*)commentDict
{
    NSString *posted_to = [commentDict objectForKey:@"videoAuthorName"];
    NSString *posted_by = [commentDict objectForKey:@"username"];
    NSString *video_id = [commentDict objectForKey:@"videoID"];
    NSString *comment_text = [commentDict objectForKey:@"text"];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [format setTimeZone:timeZone];
    [format setDateFormat:@"yyyyMMdd_HHmmss_z"];
    NSDate *date = [commentDict objectForKey:@"date"];
    NSString *time = [format stringFromDate:date];
    NSString *post = [NSString stringWithFormat:@"posted_to=%@&posted_by=%@&video_id=%@&comment_text=%@&time=%@", posted_to, posted_by, video_id, comment_text, time];
//    NSLog(@"%@", post);
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.davai.co/comments.php"]];
    
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError)
     {
//         NSLog(@"comments.php");
         if (response) {
             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//             NSLog(@"Response Status Code: %ld", (long)[httpResponse statusCode]);
         }
         if (data.length > 0) {
             NSString *dataString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//             NSLog(@"Returned Data: %@", dataString);
         }
         
         if (connectionError != nil){
             NSLog(@"Error: %@", connectionError);
         }
     }];
    
}


- (void)fetchComments:(NSDictionary*)videoDict
{
    NSString *video_id = [videoDict objectForKey:@"videoID"];
    NSString *post = [NSString stringWithFormat:@"video_id=%@", video_id];
//    NSLog(@"%@", post);
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.davai.co/commentretrieval.php"]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError)
     {
//         NSLog(@"commentretrieval.php");
         if (response) {
             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//             NSLog(@"Response Status Code: %ld", (long)[httpResponse statusCode]);
         }
         
         if (data.length > 0) {
             NSString *dataString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//             NSLog(@"Returned Data: %@", dataString);
             NSError *error;
             
             NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
             
//             NSLog(@"count %lu", (unsigned long)[jsonArray count]);
             
             NSMutableArray *commentArray = [[NSMutableArray alloc]init];
             for (NSDictionary *dict in jsonArray) {
                 NSDateFormatter *format = [[NSDateFormatter alloc] init];
                 NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
                 [format setTimeZone:timeZone];
                 [format setDateFormat:@"yyyyMMdd_HHmmss_Z"];
                 NSDate *date = [format dateFromString:[dict objectForKey:@"time"]];
//                 NSLog(@"date : %@", [date description]);                 
//                 NSLog(@"video_id : %@", [dict objectForKey:@"video_id"]);
//                 NSLog(@"comment_text : %@", [dict objectForKey:@"comment_text"]);
//                 NSLog(@"posted_by : %@", [dict objectForKey:@"posted_by"]);
//                 NSLog(@"\n");
                 
                 NSDictionary *commentDict = @{ @"text":[dict objectForKey:@"comment_text"],
                                                @"date":date,
                                                @"username":[dict objectForKey:@"posted_by"]};
                 [commentArray addObject:commentDict];
             }
             
             DataController *dataController = [DataController sharedController];
             Video *video = [dataController videoWithVideoID:[videoDict objectForKey:@"videoID"]];

             if (video) {
                 [dataController deleteCommentsForVideo:video];
                 [dataController addComments:commentArray toVideo:video];
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"CommentDidUpdate" object:nil userInfo:videoDict];
             }

         }
         
         if (connectionError != nil){
             NSLog(@"Error: %@", connectionError);
         }
     }];
    
}



- (void)downloadVideoFile:(NSDictionary*)videoDict
{
    NSString *link = [videoDict objectForKey:@"link"];
    
//    NSLog(@"download link: %@", link);
    NSString *identifier = [NSString stringWithFormat:@"co.davai-%@", [videoDict objectForKey:@"videoID"]];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:identifier];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];

    
    
    NSURL *downloadURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", link]];
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request];
    
    if (downloadTask) {
        NSDictionary *downloadRequestInfo = @{ @"downloadTask":downloadTask,
                                               @"videoDict":videoDict };
        
        [self.downloads addObject:downloadRequestInfo];
        
        [downloadTask resume];

    }
}


- (void)likeVideo:(NSDictionary*)videoDict
{
    
    NSString *username = [videoDict objectForKey:@"username"];
    NSString *video_id = [videoDict objectForKey:@"videoID"];
    NSString *post = [NSString stringWithFormat:@"username=%@&videoid=%@", username, video_id];
//    NSLog(@"%@", post);
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.davai.co/likes.php"]];
    
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError)
     {
//         NSLog(@"likes.php");
         if (response) {
             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//             NSLog(@"Response Status Code: %ld", (long)[httpResponse statusCode]);
             
             if (data.length > 0) {
                 NSString *dataString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//                 NSLog(@"returned data %@", dataString);
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoDidLike" object:nil userInfo:videoDict];
             }
         }

         if (connectionError != nil){
             NSLog(@"Error: %@", connectionError);
         }
     }];
    
}


#pragma mark - NSURLSession Delegate Method


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)downloadURL
{
    
    NSDictionary *downloadInfo;
    
    for (NSDictionary *info in self.downloads) {
        if ([info objectForKey:@"downloadTask"] == downloadTask) {
            downloadInfo = info;
            break;
        }
    }
    
    if (downloadInfo) {

        NSMutableDictionary *videoDict = [[NSMutableDictionary alloc]initWithDictionary:[downloadInfo objectForKey:@"videoDict"]];
        
        NSString *link = [videoDict objectForKey:@"link"];
        NSString *filename = [link lastPathComponent];
        
        
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

        [fileManager moveItemAtURL:downloadURL toURL:videoURL error:nil];
        
        [videoDict setObject:[videoURL absoluteString] forKey:@"localURL"];
        
//        NSLog(@"video Dict download: %@", videoDict);
        [self.downloads removeObject:downloadInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoFileDidDownload" object:nil userInfo:videoDict];
            [self fetchComments:videoDict];
        });
    }
}



- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.backgroundSessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
        appDelegate.backgroundSessionCompletionHandler = nil;
        completionHandler();
    }
    
//    NSLog(@"All tasks are finished");
}

@end
