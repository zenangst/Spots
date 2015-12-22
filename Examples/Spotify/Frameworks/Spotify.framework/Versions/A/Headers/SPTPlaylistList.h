/*
 Copyright 2015 Spotify AB

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "SPTPlaylistSnapshot.h"
#import "SPTListPage.h"

@class SPTSession;

/** The callback that gets called after a playlist creation, will contain your newly created playlist. */
typedef void (^SPTPlaylistCreationCallback)(NSError *error, SPTPlaylistSnapshot *playlist);

/** This class represents a user's list of playlists, and also contains methods for listing and creating new playlists on behalf of a user.
 
 API Docs: https://developer.spotify.com/web-api/playlist-endpoints/
 
 API Console: https://developer.spotify.com/web-api/console/playlists/

 Playlist Guide: https://developer.spotify.com/web-api/working-with-playlists/

 */
@interface SPTPlaylistList : SPTListPage




///-------------------------
/// @name Creating playlists
///-------------------------

/**
 Create a new playlist and add it to the this playlist list.
 
 See: https://developer.spotify.com/web-api/create-playlist/
 
 @param name The name of the newly-created playlist.
 @param isPublic Whether the newly-created playlist is public.
 @param session An authenticated session. Must be valid and authenticated with the
 `SPTAuthPlaylistModifyPublicScope` or `SPTAuthPlaylistModifyPrivateScope` scope as necessary.
 @param block The callback block to be fired when playlist creation is completed (or fails).
 */
+ (void)createPlaylistWithName:(NSString *)name
					publicFlag:(BOOL)isPublic
					   session:(SPTSession *)session
					  callback:(SPTPlaylistCreationCallback)block;

/**
 Create a new playlist and add it to the this playlist list.
 
 See: https://developer.spotify.com/web-api/create-playlist/
 
 @param name The name of the newly-created playlist.
 @param username The user to create the playlist for. (Needs to be the currently authenticated user)
 @param isPublic Whether the newly-created playlist is public.
 @param accessToken An valid access token with the `SPTAuthPlaylistModifyPublicScope` or `SPTAuthPlaylistModifyPrivateScope` scope as necessary.
 @param block The callback block to be fired when playlist creation is completed (or fails).
 */
+ (void)createPlaylistWithName:(NSString *)name
					   forUser:(NSString *)username
					publicFlag:(BOOL)isPublic
				   accessToken:(NSString *)accessToken
					  callback:(SPTPlaylistCreationCallback)block;



///---------------------------------
/// @name Listing a user's playlists
///---------------------------------

/** Get the authenticated user's playlist list.
 
 See: https://developer.spotify.com/web-api/get-list-users-playlists/
 
 @param session An authenticated session. Must be valid and authenticated with the
 `SPTAuthPlaylistReadScope` or `SPTAuthPlaylistReadPrivateScope` scope as necessary.
 @param block The block to be called when the operation is complete. The block will pass an `SPTPlaylistList` object on success, otherwise an error.
 */
+ (void)playlistsForUserWithSession:(SPTSession *)session
						   callback:(SPTRequestCallback)block;

/** Get the a user's playlist list.
 
 See: https://developer.spotify.com/web-api/get-list-users-playlists/
 
 @param username The username of the user to get playlists for.
 @param accessToken An authenticated access token with the `SPTAuthPlaylistReadScope` or `SPTAuthPlaylistReadPrivateScope` scope as necessary.
 @param block The block to be called when the operation is complete. The block will pass an `SPTPlaylistList` object on success, otherwise an error.
 */
+ (void)playlistsForUser:(NSString *)username
		 withAccessToken:(NSString *)accessToken
				callback:(SPTRequestCallback)block;

/** Get the a user's playlist list.
 
 See: https://developer.spotify.com/web-api/get-list-users-playlists/

 @param username The username of the user to get playlists for.
 @param session An authenticated session. Must be valid and authenticated with the `SPTAuthPlaylistReadScope` scope as necessary.
 @param block The block to be called when the operation is complete. The block will pass an `SPTPlaylistList` object on success, otherwise an error.
 */
+ (void)playlistsForUser:(NSString *)username
			 withSession:(SPTSession *)session
				callback:(SPTRequestCallback)block;





///------------------------------------------------
/// @name Playlist listing request creation methods
///------------------------------------------------

/**
 Create a request for creating a new playlist and add it to the current users' playlists.
 
 See: https://developer.spotify.com/web-api/create-playlist/
 
 @param name The name of the newly-created playlist.
 @param username The username of the user to create the playlist for. (Must be the current user)
 @param isPublic Whether the newly-created playlist is public.
 @param accessToken An authenticated access token. Must be valid and authenticated with the `SPTAuthPlaylistModifyPublicScope` or `SPTAuthPlaylistModifyPrivateScope` scope as necessary.
 @param error An optional pointer to an `NSError` that will receive the error code if operation failed.
 */
+ (NSURLRequest*)createRequestForCreatingPlaylistWithName:(NSString *)name
												  forUser:(NSString *)username
										   withPublicFlag:(BOOL)isPublic
											  accessToken:(NSString *)accessToken
													error:(NSError **)error;

/** Get the a user's playlist list.
 
 Example:
 
 ```
	// Getting the first two pages of a playlists for a user
 	NSURLRequest *playlistrequest = [SPTPlaylistList createRequestForGettingPlaylistsForUser:@"possan" withAccessToken:accessToken error:nil];
	[[SPTRequest sharedHandler] performRequest:playlistrequest callback:^(NSError *error, NSURLResponse *response, NSData *data) {
		if (error != nil) { Handle error }
		SPTPlaylistList *playlists = [SPTPlaylistList playlistListFromData:data withResponse:response error:nil];
		NSLog(@"Got possan's playlists, first page: %@", playlists);
		NSURLRequest *playlistrequest2 = [playlists createRequestForNextPageWithAccessToken:accessToken error:nil];
		[[SPTRequest sharedHandler] performRequest:playlistrequest2 callback:^(NSError *error2, NSURLResponse *response2, NSData *data2) {
			if (error2 != nil) { Handle error }
			SPTPlaylistList *playlists2 = [SPTPlaylistList playlistListFromData:data2 withResponse:response2 error:nil];
			NSLog(@"Got possan's playlists, second page: %@", playlists2);
		}];
	}];
 ```

 See: https://developer.spotify.com/web-api/get-list-users-playlists/

 @param username The username of the user to get playlists for.
 @param accessToken An authenticated access token. Must be valid and authenticated with the `SPTAuthPlaylistReadPublicScope` or `SPTAuthPlaylistReadPrivateScope` scope as necessary.
 @param error An optional pointer to an `NSError` that will receive the error code if operation failed.
 */
+ (NSURLRequest*)createRequestForGettingPlaylistsForUser:(NSString *)username
										 withAccessToken:(NSString *)accessToken
												   error:(NSError **)error;





///------------------------------
/// @name Parsers / Deserializers
///------------------------------

/**
 Parse the response of an API call into an `SPTPlaylistList` object

 @param data The API response data
 @param response The API response object
 @param error An optional pointer to an `NSError` that will receive the error code if operation failed.
 */
+ (instancetype)playlistListFromData:(NSData*)data
						withResponse:(NSURLResponse*)response
							   error:(NSError **)error;

/**
 Parse a decoded JSON object into an `SPTPlaylistList` object
 
 @param decodedObject The decoded JSON object
 @param error An optional pointer to an `NSError` that will receive the error code if operation failed.
 */
+ (instancetype)playlistListFromDecodedJSON:(id)decodedObject
									  error:(NSError **)error;

@end
