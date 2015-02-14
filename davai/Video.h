//
//  Video.h
//  davai
//
//  Created by Zhi Li on 2014-12-30.
//  Copyright (c) 2014 Davai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Video : NSManagedObject

@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * localURL;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * s3key;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * videoID;
@property (nonatomic, retain) NSNumber * liked;
@property (nonatomic, retain) NSNumber * numberOfLikes;

@end
