//
//  User.h
//  davai
//
//  Created by Zhi Li on 2014-12-12.
//  Copyright (c) 2014 Davai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * home;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * loggedIn;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * realname;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * uuid;

@end
