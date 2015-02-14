//
//  DataController.m
//  davai
//
//  Created by Zhi Li on 2014-11-27.
//  Copyright (c) 2014 Davai. All rights reserved.
//

#import "DataController.h"

@implementation DataController

+ (id)sharedController {
    static DataController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)save
{
    NSError *saveError = nil;
    if (![self.managedObjectContext save:&saveError]) {
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", saveError, saveError.localizedDescription);
    }
}

- (User*)userWithUsername:(NSString*)username
{
    User *user = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"username == %@", username];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    NSLog(@"result count: %lu", (unsigned long)[result count]);
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    
    if (result.count == 1)
        user = (User *)[result objectAtIndex:0];
    
    return user;

}

- (User*)userMake:(NSDictionary*)userData
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext];
    User *newUser = [[User alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    
    newUser.username = [userData objectForKey:@"username"];
    if ([userData objectForKey:@"password"])
        newUser.password = [userData objectForKey:@"password"];
    if ([userData objectForKey:@"email"])
        newUser.email = [userData objectForKey:@"email"];
    if ([userData objectForKey:@"home"])
        newUser.home = [userData objectForKey:@"home"];
    if ([userData objectForKey:@"realname"])
        newUser.realname = [userData objectForKey:@"realname"];
    if ([userData objectForKey:@"id"])
        newUser.id = [userData objectForKey:@"id"];
    if ([userData objectForKey:@"uuid"])
        newUser.uuid = [userData objectForKey:@"uuid"];

    return newUser;
}

- (void)logInUser:(User*)user
{
    user.loggedIn = [NSNumber numberWithBool:YES];
    [self save];
}

- (void)logOutUser:(User*)user
{
    user.loggedIn = [NSNumber numberWithBool:NO];
    [self save];
}

- (User*)fetchLoggedInUser
{
    User *user = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"loggedIn == 1"];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    NSLog(@"logged in user result count: %lu", (unsigned long)[result count]);
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    
    if (result.count == 1)
        user = (User *)[result objectAtIndex:0];
    
    return user;
}

- (Video*)videoWithVideoID:(NSString*)videoID
{
    Video *video;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Video" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"videoID == %@", videoID];
    [fetchRequest setPredicate:predicate];
    
    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    NSLog(@"videoWithVideoID video result count: %lu", (unsigned long)[result count]);
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    if ([result count] == 1)
        video = [result objectAtIndex:0];
    return video;
}

- (void)addVideo:(NSDictionary*)videoInfo author:(User*)author comments:(NSArray*)comments
{
    if ([self videoWithVideoID:[videoInfo objectForKey:@"videoID"]]) {
        return;
    }
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Video" inManagedObjectContext:self.managedObjectContext];
    Video *newVideo = [[Video alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    
    newVideo.username = author.username;
    if ([videoInfo objectForKey:@"videoID"])
        newVideo.videoID = [videoInfo objectForKey:@"videoID"];
//    NSLog(@"videoID %@", newVideo.videoID);
    if ([videoInfo objectForKey:@"caption"])
        newVideo.caption = [videoInfo objectForKey:@"caption"];
    if ([videoInfo objectForKey:@"location"])
        newVideo.location = [videoInfo objectForKey:@"location"];
    if ([videoInfo objectForKey:@"latitude"])
        newVideo.latitude = [videoInfo objectForKey:@"latitude"];
    if ([videoInfo objectForKey:@"longitude"])
        newVideo.longitude = [videoInfo objectForKey:@"longitude"];
    if ([videoInfo objectForKey:@"date"])
        newVideo.date = [videoInfo objectForKey:@"date"];
    if ([videoInfo objectForKey:@"s3key"])
        newVideo.s3key = [videoInfo objectForKey:@"s3key"];
    if ([videoInfo objectForKey:@"localURL"])
        newVideo.localURL = [videoInfo objectForKey:@"localURL"];
    if ([videoInfo objectForKey:@"date"])
        newVideo.date = [videoInfo objectForKey:@"date"];
    if ([videoInfo objectForKey:@"liked"])
        newVideo.liked = [videoInfo objectForKey:@"liked"];
    if ([videoInfo objectForKey:@"numberOfLikes"])
        newVideo.numberOfLikes = [videoInfo objectForKey:@"numberOfLikes"];
    if (comments)
        [self addComments:comments toVideo:newVideo];
    [self save];
}

- (Comment*)addComment:(NSDictionary*)commentDict toVideo:(Video*)video
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Comment" inManagedObjectContext:self.managedObjectContext];
    Comment *newComment = [[Comment alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    newComment.text = [commentDict objectForKey:@"text"];
    if ([commentDict objectForKey:@"date"])
        newComment.date = [commentDict objectForKey:@"date"];
    User *user = [self userWithUsername:[commentDict objectForKey:@"username"]];
    if (!user)
        user = [self userMake:@{@"username" : [commentDict objectForKey:@"username"]}];
    newComment.username = user.username;
    newComment.videoID = video.videoID;
//    [video addCommentObject:newComment];
//    [self save];
    return newComment;
}

- (void)addComments:(NSArray*)commentInfo toVideo:(Video*)video
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Comment" inManagedObjectContext:self.managedObjectContext];
    for (NSDictionary *commentDict in commentInfo) {
        Comment *newComment = [[Comment alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.managedObjectContext];
        newComment.text = [commentDict objectForKey:@"text"];
        if ([commentDict objectForKey:@"date"])
            newComment.date = [commentDict objectForKey:@"date"];
        User *user = [self userWithUsername:[commentDict objectForKey:@"username"]];
        if (!user)
            user = [self userMake:@{@"username" : [commentDict objectForKey:@"username"]}];
        newComment.username = user.username;
        newComment.videoID = video.videoID;
//        [video addCommentObject:newComment];
    }
}

- (NSArray*)fetchAllVideos
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Video" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    NSLog(@"video result count: %lu", (unsigned long)[result count]);
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    
    NSArray *sortedArray = [result sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
    
    return sortedArray;
}

- (NSArray*)sortVideos:(NSArray*)videos ByDateAscending:(BOOL)ascending
{
    NSArray *sortedArray = [videos sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:ascending]]];
    return sortedArray;
}


- (NSArray*)fetchCommentsForVideo:(Video*)video
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Comment" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"videoID == %@", video.videoID];
    [fetchRequest setPredicate:predicate];

    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    NSLog(@"video result count: %lu", (unsigned long)[result count]);
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    NSArray *sortedArray = [result sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
    return sortedArray;
}

- (void)deleteCommentsForVideo:(Video*)video
{
    NSArray *comments = [self fetchCommentsForVideo:video];
    
    for (Comment *comment in comments) {
        [self.managedObjectContext deleteObject:comment];
    }
    [self save];
}
@end
