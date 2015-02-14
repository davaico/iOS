//
//  DataController.h
//  davai
//
//  Created by Zhi Li on 2014-11-27.
//  Copyright (c) 2014 Davai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "User.h"
#import "Video.h"
#import "Comment.h"

@interface DataController : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

/** The shared instance of DataController
 * @return The shared instance of DataController
 */
+ (id)sharedController;

/** Save data
 */
- (void)save;

/** Fetch the logged in user for the database
 * @return The logged in user; nil if no user logged in
 */
- (User*)fetchLoggedInUser;

/** Log in the given user
 * @param user The user to be logged in
 */
- (void)logInUser:(User*)user;

/** Log out the given user
 * @param user The user to be logged out
 */
- (void)logOutUser:(User*)user;

/** Make a User object using the given userData information
 * @param userData A Dictionary the contains the user's data
 * @return A User object using the given information
 */

- (User*)userMake:(NSDictionary*)userData;
/** Fetch the User object by its username
 * @param username The username of a user
 * @return A User object with the given username
 */
- (User*)userWithUsername:(NSString*)username;


- (Video*)videoWithVideoID:(NSString*)videoID;


/** Add a video to the database with the given information
 * @param videoInfo Information of the video
 * @param author The author of the video
 * @param comments The comments of the video; if no comment, nil
 */
- (void)addVideo:(NSDictionary*)videoInfo author:(User*)author comments:(NSArray*)comments;

/** Add a comment to the database with the given information
 * @param commentDict Information of the comment
 * @param video The video of the comment
 * @return the new comment added to the video
 */
- (Comment*)addComment:(NSDictionary*)commentDict toVideo:(Video*)video;

/** Add comments to the database with the given information
 * @param commentInfo Information of the comments
 * @param video The video of the comments
 */
- (void)addComments:(NSArray*)commentInfo toVideo:(Video*)video;

/** Fetch all videos in the database
 * @return An array containing the videos
 */
- (NSArray*)fetchAllVideos;

/** Fetch all comments for the given video
 * @return An array containing the comments
 */
- (NSArray*)fetchCommentsForVideo:(Video*)video;

- (void)deleteCommentsForVideo:(Video*)video;

- (NSArray*)sortVideos:(NSArray*)videos ByDateAscending:(BOOL)ascending;

@end
