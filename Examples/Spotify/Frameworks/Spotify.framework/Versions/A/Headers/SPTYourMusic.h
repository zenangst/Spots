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

/** This class provides helpers for using the your music features in the Spotify API.
 
 API Docs: https://developer.spotify.com/web-api/browse-endpoints/
 
 API Console: https://developer.spotify.com/web-api/console/user%20library/
 */
@interface SPTYourMusic : NSObject





///----------------------------
/// @name API Request Factories
///----------------------------

/** Create a request for getting the authenticated user's Your Music library tracks
 
 @param accessToken A valid and authenticated access token with the `SPTAuthUserLibraryRead` scope.
 @param error An optional pointer to an `NSError` that will receive the error code if operation failed.
 */
+ (NSURLRequest*)createRequestForCurrentUsersSavedTracksWithAccessToken:(NSString *)accessToken
																  error:(NSError **)error;

/** Create a request for adding a set of tracks to the authenticated user's Your Music library.
 
 @param tracks An array of `SPTTrack`, `SPTPartialTrack` or `NSURI` objects.
 @param accessToken A valid and authenticated access token with the `SPTAuthUserLibraryModify` scope.
 @param error An optional pointer to an `NSError` that will receive the error code if operation failed.
 */
+ (NSURLRequest*)createRequestForSavingTracks:(NSArray *)tracks
					   forUserWithAccessToken:(NSString *)accessToken
										error:(NSError **)error;

/** Create a request for checking whether the authenticated user's Your Music library contains a set of tracks.
 
 @param tracks An array of `SPTTrack`, `SPTPartialTrack` or `NSURL` objects.
 @param accessToken A valid and authenticated access token with the `SPTAuthUserLibraryRead` scope.
 @param error An optional pointer to an `NSError` that will receive the error code if operation failed.
 */
+ (NSURLRequest*)createRequestForCheckingIfSavedTracksContains:(NSArray *)tracks
										forUserWithAccessToken:(NSString *)accessToken
														 error:(NSError **)error;

/** Create a request for removing a set of tracks from the authenticated user's Your Music library.
 
 @param tracks An array of `SPTTrack`, `SPTPartialTrack` or `NSURL` objects.
 @param accessToken A valid and authenticated access token with the `SPTAuthUserLibraryModify` scope.
 @param error An optional pointer to an `NSError` that will receive the error code if operation failed.
 */
+ (NSURLRequest*)createRequestForRemovingTracksFromSaved:(NSArray *)tracks
								  forUserWithAccessToken:(NSString *)accessToken
												   error:(NSError **)error;





///--------------------------
/// @name Convenience Methods
///--------------------------

/** Gets the authenticated user's Your Music Library tracks
 
 This is a convenience method around the createRequest equivalent and the current `SPTRequestHandlerProtocol`
 
 @param accessToken A valid and authenticated access token with the `SPTAuthUserLibraryRead` scope.
 @param block The block to be called when the operation is complete, with the data set if success, otherwise an error.
 */
+ (void)savedTracksForUserWithAccessToken:(NSString *)accessToken
								 callback:(SPTRequestCallback)block;

/** Adds a set of tracks to the authenticated user's Your Music Library.
 
 This is a convenience method around the createRequest equivalent and the current `SPTRequestHandlerProtocol`
 
 @param tracks An array of `SPTTrack`, `SPTPartialTrack` or `NSURI` objects.
 @param accessToken A valid and authenticated access token with the `SPTAuthUserLibraryModify` scope.
 @param block The block to be called when the operation is complete, with the data set if success, otherwise an error.
 */
+ (void)saveTracks:(NSArray *)tracks
forUserWithAccessToken:(NSString *)accessToken
		  callback:(SPTRequestCallback)block;

/** Checks whether the authenticated user's Your Music Library contains a set of tracks.
 
 This is a convenience method around the createRequest equivalent and the current `SPTRequestHandlerProtocol`
 
 @param tracks An array of `SPTTrack`, `SPTPartialTrack` or `NSURI` objects.
 @param accessToken A valid and authenticated access token with the `SPTAuthUserLibraryRead` scope.
 @param block The block to be called when the operation is complete, with the data set if success, otherwise an error.
 */
+ (void)savedTracksContains:(NSArray *)tracks
	 forUserWithAccessToken:(NSString *)accessToken
				   callback:(SPTRequestCallback)block;

/** Removes a set of tracks from the authenticated user's Your Music Library.

 This is a convenience method around the createRequest equivalent and the current `SPTRequestHandlerProtocol`

 @param tracks An array of `SPTTrack`, `SPTPartialTrack` or `NSURL` objects.
 @param accessToken A valid and authenticated access token  with the `SPTAuthUserLibraryModify` scope.
 @param block The block to be called when the operation is complete, with the data set if success, otherwise an error.
 */
+ (void)removeTracksFromSaved:(NSArray *)tracks
	   forUserWithAccessToken:(NSString *)accessToken
					 callback:(SPTRequestCallback)block;




@end
