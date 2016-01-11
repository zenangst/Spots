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
#import "SPTRequest.h"
#import "SPTTypes.h"

/** This class provides helpers for using the follow features in the Spotify API.
 
 API Docs: https://developer.spotify.com/web-api/web-api-follow-endpoints/
 
 API Console: https://developer.spotify.com/web-api/console/follow/ 
 
 Example of following a user:

 ```
	NSURLRequest *req = [SPTFollow createRequestForFollowingUsers:@[@"possan"]] withAccessToken:@"<your accesstoken>" error:nil];
	[[SPTRequest sharedHandler] performRequest:req callback:^(NSError *error, NSURLResponse *response, NSData *data) {
		long statusCode = ((NSHTTPURLResponse*)response).statusCode;
		switch (statusCode) {
			case 204:
				NSLog(@"Successfully followed user.");
				break;
			case 401:
			case 403:
				NSLog(@"Failed to follow user, are you sure your token is valid and have the correct scopes?");
				break;
			default:
				NSLog(@"Unknown error");
				break;
		}
	}];
 ```
 
 Example of checking if a user is following a playlist:
 
 ```
	NSError *err2 = nil;
	NSURLRequest *req2 = [SPTFollow createRequestForCheckingIfUsers:@[@"possan"]
		areFollowingPlaylist:[NSURL URLWithString:@"spotify:user:eldloppa:playlist:4irwclB6noltFaHhqZSWRu"]
		withAccessToken:auth.session.accessToken
		error:&err2];
	NSLog(@"created request %@", req2);
	[[SPTRequest sharedHandler] performRequest:req2 callback:^(NSError *error, NSURLResponse *response, NSData *data) {
		NSLog(@"error=%@, response=%@, data=%@", error, response, data);
		NSArray *arr = [SPTFollow followingResultFromData:data withResponse:response error:nil];
		NSLog(@"is following? %@", [arr objectAtIndex:0]);
	}];
 ```
 
 */
@interface SPTFollow : NSObject






///----------------------------
/// @name API Request Factories
///----------------------------

/** Create a request for making the current user follow a list of artist.
 
 See https://developer.spotify.com/web-api/follow-artists-users/ for more information on parameters
 
 @param artistUris An array of `NSURL`s for artist to follow.
 @param accessToken A valid and authenticated access token with the `SPTAuthFollowModifyScope` scope.
 @param error An optional pointer to a `NSError` that receives an error if request creation failed.
 @return The created `NSURLRequest`.
 */
+ (NSURLRequest*)createRequestForFollowingArtists:(NSArray*)artistUris
								  withAccessToken:(NSString *)accessToken
											error:(NSError **)error;



/** Create a request for making the current user unfollow a list of artists.
 
 See https://developer.spotify.com/web-api/unfollow-artists-users/ for more information on parameters
 
 @param artistUris An array of `NSURL`s for artists to unfollow.
 @param accessToken A valid and authenticated access token with the `SPTAuthFollowModifyScope` scope.
 @param error An optional pointer to a `NSError` that receives an error if request creation failed.
 @return The created `NSURLRequest`.
 */
+ (NSURLRequest*)createRequestForUnfollowingArtists:(NSArray*)artistUris
									withAccessToken:(NSString *)accessToken
											  error:(NSError **)error;



/** Create a request to check if the current user is following a list of artists.
 
 Parse the response in to an `NSArray` of booleans using `parseFollowingResultData:withResponse:error`
 
 See https://developer.spotify.com/web-api/check-current-user-follows/ for more information on parameters
 
 @param artistUris An array of `NSURL`s for artists to check.
 @param accessToken A valid and authenticated access token with the `SPTAuthFollowModifyScope` scope.
 @param error An optional pointer to a `NSError` that receives an error if request creation failed.
 @return The created `NSURLRequest`.
 */
+ (NSURLRequest*)createRequestForCheckingIfFollowingArtists:(NSArray*)artistUris
											withAccessToken:(NSString *)accessToken
													  error:(NSError **)error;





/** Create a request to make the current user follow a list of users.
 
 See https://developer.spotify.com/web-api/follow-artists-users/ for more information on parameters
 
 @param usernames An array of `NSString`s containing spotify usernames to follow.
 @param accessToken A valid and authenticated access token with the `SPTAuthFollowModifyScope` scope.
 @param error An optional pointer to a `NSError` that receives an error if request creation failed.
 @return The created `NSURLRequest`.
 */
+ (NSURLRequest*)createRequestForFollowingUsers:(NSArray*)usernames
								withAccessToken:(NSString *)accessToken
										  error:(NSError **)error;



/** Create a request to make the current user unfollow a list of users.
 
 See https://developer.spotify.com/web-api/unfollow-artists-users/ for more information on parameters
 
 @param usernames An array of `NSString`s containing spotify usernames to unfollow.
 @param accessToken A valid and authenticated access token with the `SPTAuthFollowModifyScope` scope.
 @param error An optional pointer to a `NSError` that receives an error if request creation failed.
 @return The created `NSURLRequest`.
 */
+ (NSURLRequest*)createRequestForUnfollowingUsers:(NSArray*)usernames
								  withAccessToken:(NSString *)accessToken
											error:(NSError **)error;



/** Create a request to check if the current user is following a list of users.
 
 Parse the response in to an `NSArray` of booleans using `parseFollowingResultData:withResponse:error`
 
 See https://developer.spotify.com/web-api/check-current-user-follows/ for more information on parameters
 
 @param username A `NSString`s containing spotify username to check.
 @param accessToken A valid and authenticated access token with the `SPTAuthFollowModifyScope` scope.
 @param error An optional pointer to a `NSError` that receives an error if request creation failed.
 @return The created `NSURLRequest`.
 */
+ (NSURLRequest*)createRequestForCheckingIfFollowingUsers:(NSArray*)username
										  withAccessToken:(NSString *)accessToken
													error:(NSError **)error;




/** Create a request for following a playlist.
 
 See https://developer.spotify.com/web-api/get-list-new-releases/ for more information on parameters
 
 @param playlistUri The playlist URI to follow.
 @param secret Follow this playlist secretly.
 @param accessToken A valid and authenticated access token with the `SPTAuthPlaylistModifyPrivateScope` or `SPTAuthPlaylistModifyPublicScope` scope depending on if you're following it publicly or not.
 @param error An optional pointer to a `NSError` that receives an error if request creation failed.
 @return The created `NSURLRequest`.
 */
+ (NSURLRequest*)createRequestForFollowingPlaylist:(NSURL *)playlistUri
								   withAccessToken:(NSString *)accessToken
											secret:(BOOL)secret
											 error:(NSError **)error;



/** Create a request to check if a user is following a specific playlist.
 
 See https://developer.spotify.com/web-api/get-list-new-releases/ for more information on parameters
 
 @param playlistUri A playlist URI.
 @param accessToken A valid and authenticated access token with the `SPTAuthFollowModifyScope` scope.
 @param error An optional pointer to a `NSError` that receives an error if request creation failed.
 @return The created `NSURLRequest`.
 */
+ (NSURLRequest*)createRequestForUnfollowingPlaylist:(NSURL *)playlistUri
									 withAccessToken:(NSString *)accessToken
											   error:(NSError **)error;



/** Create a request to check if a user is following a specific playlist.
 
 Parse the response in to an `NSArray` of booleans using `SPTFollow parseFollowingResultData:withResponse:error`
 
 See https://developer.spotify.com/web-api/get-list-new-releases/ for more information on parameters
 
 @param usernames A list of spotify usernames.
 @param playlistUri A playlist URI.
 @param accessToken A valid and authenticated access token with the `SPTAuthFollowModifyScope` scope.
 @param error An optional pointer to a `NSError` that receives an error if request creation failed.
 @return The created `NSURLRequest`.
 */
+ (NSURLRequest*)createRequestForCheckingIfUsers:(NSArray *)usernames
							areFollowingPlaylist:(NSURL*)playlistUri
								 withAccessToken:(NSString *)accessToken
										   error:(NSError **)error;





///---------------------------
/// @name API Response Parsers
///---------------------------

/** Parse the result of a "am i following this entity"-query into an array of booleans

 @param data The API response data
 @param response The API response object
 @param error An optional pointer to a `NSError` that receives an error if request creation failed.
 @return An `NSArray` of booleans
 */
+ (NSArray*)followingResultFromData:(NSData *)data
					   withResponse:(NSURLResponse *)response
							  error:(NSError **)error;

@end
