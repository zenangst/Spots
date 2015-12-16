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
#import "SPTJSONDecoding.h"
#import "SPTRequest.h"
#import "SPTTypes.h"
#import "SPTPartialPlaylist.h"
#import "SPTImage.h"

@class SPTPlaylistSnapshot;
@class SPTSession;
@class SPTUser;
@class SPTListPage;

/** The field indicating whether the playlist is public. */
FOUNDATION_EXPORT NSString * const SPTPlaylistSnapshotPublicKey;

/** The field indicating the name of the playlist. */
FOUNDATION_EXPORT NSString * const SPTPlaylistSnapshotNameKey;

/** Represents a user's playlist on the Spotify service.
 
 API Docs: https://developer.spotify.com/web-api/playlist-endpoints/

 API Console: https://developer.spotify.com/web-api/console/playlists/
 
 API Model: https://developer.spotify.com/web-api/object-model/#playlist-object-full
 
 Playlist Guide: https://developer.spotify.com/web-api/working-with-playlists/

 Example:
 
 ```
	[SPTPlaylistSnapshot playlistWithURI:[NSURL URLWithString:@"spotify:user:spotify:playlist:2ujjMpFriZ2nayLmrD1Jgl"]
		accessToken:accessToken
		callback:^(NSError *error, SPTPlaylistSnapshot *object) {
			NSLog(@"tracks on page 1 = %@", [object.firstTrackPage tracksForPlayback]);
			[object.firstTrackPage requestNextPageWithAccessToken:accessToken
				callback:^(NSError *error, id object) {
				NSLog(@"tracks on page 2 = %@", [object tracksForPlayback]);
			}];
		}];
 ``` 
 */
@interface SPTPlaylistSnapshot : SPTPartialPlaylist <SPTJSONObject>






///----------------------------
/// @name Properties
///----------------------------

/** The tracks of the playlist, as a page of `SPTPartialTrack` objects. */
@property (nonatomic, readonly) SPTListPage *firstTrackPage;

/** The version identifier for the playlist. */
@property (nonatomic, readonly, copy) NSString *snapshotId;

/** The number of followers of this playlist */
@property (nonatomic, readonly) long followerCount;

/** The description of the playlist */
@property (nonatomic, readonly, copy) NSString *descriptionText;






///----------------------------
/// @name Requesting Playlists
///----------------------------

/** Request the playlist at the given Spotify URI.
 
 @note This method takes Spotify URIs in the form `spotify:*`, NOT HTTP URLs.
 
 @param uri The Spotify URI of the playlist to request.
 @param session An authenticated session. Must be valid and authenticated with the
 `SPTAuthPlaylistReadScope` or `SPTAuthPlaylistReadPrivateScope` scope as necessary.
 @param block The block to be called when the operation is complete. The block will pass a Spotify SDK metadata object on success, otherwise an error.
 */
+(void)playlistWithURI:(NSURL *)uri session:(SPTSession *)session callback:(SPTRequestCallback)block;

/** Request the playlist at the given Spotify URI.
 
 @note This method takes Spotify URIs in the form `spotify:*`, NOT HTTP URLs.
 
 @param uri The Spotify URI of the playlist to request.
 @param accessToken A valid access token authenticated with the `SPTAuthPlaylistReadScope` or `SPTAuthPlaylistReadPrivateScope` scope as necessary.
 @param block The block to be called when the operation is complete. The block will pass a Spotify SDK metadata object on success, otherwise an error.
 */
+(void)playlistWithURI:(NSURL *)uri accessToken:(NSString *)accessToken callback:(SPTRequestCallback)block;

/** Request multiple playlists given an array of Spotify URIs.
 
 @note This method takes an array of Spotify URIs in the form `spotify:*`, NOT HTTP URLs.
 
 @param uris An array of Spotify URIs.
 @param session An authenticated session. Must be valid and authenticated with the
 `SPTAuthPlaylistReadScope` or `SPTAuthPlaylistReadPrivateScope` scope as necessary.
 @param block The block to be called when the operation is complete. The block will pass an array of Spotify SDK metadata objects on success, otherwise an error.
 */
+(void)playlistsWithURIs:(NSArray *)uris session:(SPTSession *)session callback:(SPTRequestCallback)block;

/** Check if a `NSURL` is a valid playlist uri.
 @param uri The Spotify URI of the playlist.
 */
+(BOOL)isPlaylistURI:(NSURL*)uri;

/** Check if a `NSURL` is a starred uri.
 @param uri The Spotify URI of the playlist.
 */
+(BOOL)isStarredURI:(NSURL*)uri;


/** Get the authenticated user's starred playlist.
 
 @param session An authenticated session. Must be valid and authenticated with the
 `SPTAuthPlaylistReadScope` or `SPTAuthPlaylistReadPrivateScope` scope as necessary.
 @param block The block to be called when the operation is complete. The block will pass an `SPTPlaylistSnapshot` object on success, otherwise an error.
 */
+ (void)requestStarredListForUserWithSession:(SPTSession *)session
									callback:(SPTRequestCallback)block;

/** Request the starred playlist for a user
 
 @param username The user to get the starred playlist for
 @param accessToken A valid authenticated access token.
 @param block The block to be called when the operation is complete. The block will pass an `SPTPlaylistSnapshot` object on success, otherwise an error.
 */
+ (void)requestStarredListForUser:(NSString *)username
				  withAccessToken:(NSString *)accessToken
						 callback:(SPTRequestCallback)block;






///-----------------------------------------------
/// @name Helper methods for playlist manipulation
///-----------------------------------------------

/** Append tracks to the playlist.
 
 @note This operation is asynchronous on the server, it can take a couple of seconds for your changes to propagate everywhere after this operation has started.
 
 @param tracks The tracks to add, as `SPTTrack` or `SPTPartialTrack` objects.
 @param session An authenticated session. Must be valid and authenticated with the `SPTAuthPlaylistModifyScope` or `SPTAuthPlaylistModifyPrivateScope` scope as necessary.
 @param block The block to be called when the operation is started. This block will pass an error if the operation failed.
 */
-(void)addTracksToPlaylist:(NSArray *)tracks
			   withSession:(SPTSession *)session
				  callback:(SPTErrorableOperationCallback)block;

/** Append tracks to the playlist.
 
 @note This operation is asynchronous on the server, it can take a couple of seconds for your changes to propagate everywhere after this operation has started.
 
 @param tracks The tracks to add, as `SPTTrack` or `SPTPartialTrack` objects.
 @param accessToken A valid access token authenticated with the `SPTAuthPlaylistModifyPublicScope` or `SPTAuthPlaylistModifyPrivateScope` scope as necessary.
 @param block The block to be called when the operation is started. This block will pass an error if the operation failed.
 */
-(void)addTracksToPlaylist:(NSArray *)tracks
		   withAccessToken:(NSString *)accessToken
				  callback:(SPTErrorableOperationCallback)block;

/** Add tracks to the playlist at a certain position.
 
 @note This operation is asynchronous on the server, it can take a couple of seconds for your changes to propagate everywhere after this operation has started.
 
 @param tracks The tracks to add, as `SPTTrack` or `SPTPartialTrack` objects.
 @param position The position in which the tracks will be added, being 0 the top position.
 @param session An authenticated session. Must be valid and authenticated with the `SPTAuthPlaylistModifyScope` or `SPTAuthPlaylistModifyPrivateScope` scope as necessary.
 @param block The block to be called when the operation is started. This block will pass an error if the operation failed.
 */
-(void)addTracksWithPositionToPlaylist:(NSArray *)tracks
						  withPosition:(int)position
							   session:(SPTSession *)session
							  callback:(SPTErrorableOperationCallback)block ;


/** Add tracks to the playlist at a certain position.
 
 @note This operation is asynchronous on the server, it can take a couple of seconds for your changes to propagate everywhere after this operation has started.
 
 @param tracks The tracks to add, as `SPTTrack` or `SPTPartialTrack` objects.
 @param position The position in which the tracks will be added, being 0 the top position.
 @param accessToken A valid access token authenticated with the `SPTAuthPlaylistModifyPublicScope` or `SPTAuthPlaylistModifyPrivateScope` scope as necessary.
 @param block The block to be called when the operation is started. This block will pass an error if the operation failed.
 */
-(void)addTracksWithPositionToPlaylist:(NSArray *)tracks
						  withPosition:(int)position
						   accessToken:(NSString *)accessToken
							  callback:(SPTErrorableOperationCallback)block;

/** Replace the tracks in a playlist, overwriting any tracks already in it
 
 @note This operation is asynchronous on the server, it can take a couple of seconds for your changes to propagate everywhere after this operation has started.
 
 @param tracks The tracks to set, as `SPTTrack` or `SPTPartialTrack` objects.
 @param accessToken A valid access token authenticated with the `SPTAuthPlaylistModifyPublicScope` or `SPTAuthPlaylistModifyPrivateScope` scope as necessary.
 @param block The block to be called when the operation is started. This block will pass an error if the operation failed.
 */
-(void)replaceTracksInPlaylist:(NSArray *)tracks
			   withAccessToken:(NSString *)accessToken
					  callback:(SPTErrorableOperationCallback)block;

/** Change playlist details
 
 @note This operation is asynchronous on the server, it can take a couple of seconds for your changes to propagate everywhere after this operation has started.
 
 @param data The data to be changed. Use the key constants to refer to the field to change
 (e.g. `SPTPlaylistSnapshotNameKey`, `SPTPlaylistSnapshotPublicKey`). When passing boolean values, use @YES or @NO.
 @param accessToken A valid access token authenticated with the `SPTAuthPlaylistModifyPublicScope` or `SPTAuthPlaylistModifyPrivateScope` scope as necessary.
 @param block The block to be called when the operation is started. This block will pass an error if the operation failed.
 */
-(void)changePlaylistDetails:(NSDictionary *)data
			 withAccessToken:(NSString *)accessToken
					callback:(SPTErrorableOperationCallback)block;

/** Remove tracks from playlist. It removes all occurrences of the tracks in the playlist.
 
 @note This operation is asynchronous on the server, it can take a couple of seconds for your changes to propagate everywhere after this operation has started.
 
 @param tracks The tracks to remove, as `SPTTrack` or `SPTPartialTrack` objects.
 @param accessToken A valid access token authenticated with the `SPTAuthPlaylistModifyPublicScope` or `SPTAuthPlaylistModifyPrivateScope` scope as necessary.
 @param block The block to be called when the operation is started. This block will pass an error if the operation failed.
 */
-(void)removeTracksFromPlaylist:(NSArray *)tracks
				withAccessToken:(NSString *)accessToken
					   callback:(SPTErrorableOperationCallback)block;

/** Remove tracks that are in specific positions from playlist.
 
 @note This operation is asynchronous on the server, it can take a couple of seconds for your changes to propagate everywhere after this operation has started.
 
 @param tracks An array of dictionaries with 2 keys: `track` with the track to remove, as `SPTTrack` or `SPTPartialTrack` objects, and `positions` that is an array of integers with the positions the track will be removed from.
 @param accessToken A valid access token authenticated with the `SPTAuthPlaylistModifyPublicScope` or `SPTAuthPlaylistModifyPrivateScope` scope as necessary.
 @param block The block to be called when the operation is started. This block will pass an error if the operation failed.
 */
-(void)removeTracksWithPositionsFromPlaylist:(NSArray *)tracks
							 withAccessToken:(NSString *)accessToken
									callback:(SPTErrorableOperationCallback)block;







///-----------------------------------------------------
/// @name Playlist manipulation request creation methods
///-----------------------------------------------------

/** Create a request for appending tracks to a playlist.
 
 @note This operation is asynchronous on the server, it can take a couple of seconds for your changes to propagate everywhere after this operation has started.
 
 @param tracks The tracks to add, as `SPTTrack`, `SPTPartialTrack` or `NSURL` objects.
 @param playlist The playlist to manipulate.
 @param accessToken A valid access token authenticated with the `SPTAuthPlaylistModifyPublicScope` or `SPTAuthPlaylistModifyPrivateScope` scope as necessary.
 @param error An optional pointer to a `NSError` object that will be set if an error occured.
 @return A `NSURLRequest` object
 */
+ (NSURLRequest*)createRequestForAddingTracks:(NSArray *)tracks
								   toPlaylist:(NSURL*)playlist
							  withAccessToken:(NSString *)accessToken
										error:(NSError **)error;

/** Create a request for adding tracks to the playlist at a certain position.
 
 @note This operation is asynchronous on the server, it can take a couple of seconds for your changes to propagate everywhere after this operation has started.
 
 @param tracks The tracks to add, as `SPTTrack`, `SPTPartialTrack` or `NSURL` objects.
 @param playlist The playlist to manipulate.
 @param position The position in which the tracks will be added, being 0 the top position.
 @param accessToken A valid access token authenticated with the `SPTAuthPlaylistModifyPublicScope` or `SPTAuthPlaylistModifyPrivateScope` scope as necessary.
 @param error An optional pointer to a `NSError` object that will be set if an error occured.
 @return A `NSURLRequest` object
 */
+ (NSURLRequest *)createRequestForAddingTracks:(NSArray *)tracks
									atPosition:(int)position
									toPlaylist:(NSURL *)playlist
							   withAccessToken:(NSString *)accessToken
										 error:(NSError **)error;

/** Replace all the tracks in a playlist, overwriting any tracks already in it
 
 @note This operation is asynchronous on the server, it can take a couple of seconds for your changes to propagate everywhere after this operation has started.
 
 @param tracks The new tracks, as `SPTTrack`, `SPTPartialTrack` or `NSURL` objects.
 @param playlist The playlist to manipulate.
 @param accessToken A valid access token authenticated with the `SPTAuthPlaylistModifyPublicScope` or `SPTAuthPlaylistModifyPrivateScope` scope as necessary.
 @param error An optional pointer to a `NSError` object that will be set if an error occured.
 @return A `NSURLRequest` object
 */
+ (NSURLRequest *)createRequestForSettingTracks:(NSArray *)tracks
									 inPlaylist:(NSURL *)playlist
								withAccessToken:(NSString *)accessToken
										  error:(NSError **)error;

/** Change playlist details
 
 @note This operation is asynchronous on the server, it can take a couple of seconds for your changes to propagate everywhere after this operation has started.
 
 Example:
 ```
	NSURLRequest *req = [SPTPlaylistSnapshot createRequestForChangingDetails:@{
			@"name": @"New name!",
			@"public": @(false)
		}
		inPlaylist:[NSURL URLWithString:@"spotify:user:username234:playlist:playlistid123"]
		withAccessToken:@"xyz123"
		error:&err];
 ```
 
 @param data The data to be changed. Use the key constants to refer to the field to change
 (e.g. `SPTPlaylistSnapshotNameKey`, `SPTPlaylistSnapshotPublicKey`). When passing boolean values, use @YES or @NO.
 @param playlist The playlist to manipulate.
 @param accessToken A valid access token authenticated with the `SPTAuthPlaylistModifyPublicScope` or `SPTAuthPlaylistModifyPrivateScope` scope as necessary.
 @param error An optional pointer to a `NSError` object that will be set if an error occured.
 @return A `NSURLRequest` object
 */
+ (NSURLRequest *)createRequestForChangingDetails:(NSDictionary *)data
									   inPlaylist:(NSURL *)playlist
								  withAccessToken:(NSString *)accessToken
											error:(NSError **)error;

/** Remove tracks that are in specific positions from playlist.
 
 @note This operation is asynchronous on the server, it can take a couple of seconds for your changes to propagate everywhere after this operation has started.
 
 Example:
 ```
	NSURLRequest *req = [SPTPlaylistSnapshot createRequestForRemovingTracksWithPositions:@[
			@{
				@"track": [NSURL URLWithString:@"spotify:track:a"],
				@"positions": @[ @(3) ]
			},
			@{
				@"track": [NSURL URLWithString:@"spotify:track:b"],
				@"positions": @[ @(5), @(6) ]
			}
		]
		fromPlaylist:[NSURL URLWithString:@"spotify:user:username:playlist:playlistid"]
		withAccessToken:@"xyz123"
		snapshot:@"snapshot!"
		error:&err];
 ```
 
 @param tracks An array of dictionaries with 2 keys: `track` with the track to remove, as `SPTTrack`, `SPTPartialTrack` or `NSURL` objects, and `positions` that is an array of integers with the positions the track will be removed from.
 @param playlist The playlist to manipulate.
 @param accessToken A valid access token authenticated with the `SPTAuthPlaylistModifyPublicScope` or `SPTAuthPlaylistModifyPrivateScope` scope as necessary.
 @param snapshotId The playlist snapshotId to manipulate.
 @param error An optional pointer to a `NSError` object that will be set if an error occured.
 @return A `NSURLRequest` object
 */
+ (NSURLRequest*)createRequestForRemovingTracksWithPositions:(NSArray *)tracks
												fromPlaylist:(NSURL *)playlist
											 withAccessToken:(NSString *)accessToken
													snapshot:(NSString *)snapshotId
													   error:(NSError **)error;

/** Remove tracks from playlist.
 
 @note This operation is asynchronous on the server, it can take a couple of seconds for your changes to propagate everywhere after this operation has started.
 
 @param tracks An array of `SPTTrack`, `SPTPartialTrack` or `NSURL` objects.
 @param playlist The playlist to manipulate.
 @param accessToken A valid access token authenticated with the `SPTAuthPlaylistModifyPublicScope` or `SPTAuthPlaylistModifyPrivateScope` scope as necessary.
 @param snapshotId The playlist snapshotId to manipulate.
 @param error An optional pointer to a `NSError` object that will be set if an error occured.
 @return A `NSURLRequest` object
 */
+ (NSURLRequest *)createRequestForRemovingTracks:(NSArray *)tracks
									fromPlaylist:(NSURL *)playlist
								 withAccessToken:(NSString *)accessToken
										snapshot:(NSString *)snapshotId
										   error:(NSError **)error;

/** Create a request to fetch a single playlist
 
 @note This operation is asynchronous on the server, it can take a couple of seconds for your changes to propagate everywhere after this operation has started.
 
 @param uri The playlist to get.
 @param accessToken A valid access token authenticated with the appropriate scope as necessary.
 @param error An optional pointer to a `NSError` object that will be set if an error occured.
 @return A `NSURLRequest` object
 */
+ (NSURLRequest *)createRequestForPlaylistWithURI:(NSURL *)uri
									  accessToken:(NSString *)accessToken
											error:(NSError **)error;



///------------------------------
/// @name Response parser methods
///------------------------------

/**
 Parse the response from an API call into an `SPTPlaylistSnapshot` object
 
 @param data The API response data
 @param response The API response object
 @param error An optional pointer to an `NSError` that will receive the error code if operation failed.
 @return The `SPTPlaylistSnapshot` object
 */
+ (instancetype)playlistSnapshotFromData:(NSData*)data
							withResponse:(NSURLResponse*)response
								   error:(NSError **)error;

/**
 Parse the response from an API call into an `SPTPlaylistSnapshot` object
 
 @param decodedObject The decoded JSON object structure
 @param error An optional pointer to an `NSError` that will receive the error code if operation failed.
 @return The `SPTPlaylistSnapshot` object
 */
+ (instancetype)playlistSnapshotFromDecodedJSON:(id)decodedObject
										  error:(NSError **)error;

@end
