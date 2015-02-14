//
//  Comment.h
//  davai
//
//  Created by Zhi Li on 2014-12-12.
//  Copyright (c) 2014 Davai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Comment : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * videoID;
@property (nonatomic, retain) NSString * username;

@end
