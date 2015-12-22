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
#import "SPTListPage.h"
#import "SPTTypes.h"

/** This class provides helpers for using the browse features in the Spotify API
 
 API Docs: https://developer.spotify.com/web-api/browse-endpoints/
 
 API Console: https://developer.spotify.com/web-api/console/browse/
 */
@interface SPTBrowse : NSObject






///----------------------------
/// @name API Request Factories
///----------------------------

/** Get a list of featured playlists

 Parse the response into an `SPTFeaturedPlaylistList` using `SPTFeaturedPlaylistList playlistListFromData:withResponse:error`
 
 See https://developer.spotify.com/web-api/get-list-featured-playlists/ for more information on parameters
 
 @param country A ISO 3166-1 country code to get playlists for, or `nil` to get global recommendations.
 @param limit The number of results to return, max 50.
 @param offset The index at which to start returning results.
 @param locale The locale of the user, for localized recommendations, `nil` will default to American English.
 @param timestamp The time of day to get recommendations for (without timezone), or `nil` for current local time
 @param accessToken An authenticated access token. Must be valid and authenticated
 @param error An optional error value, will be set if the creation of the request failed.
 @return The request
 */
+ (NSURLRequest *)createRequestForFeaturedPlaylistsInCountry:(NSString *)country
													   limit:(NSInteger)limit
													  offset:(NSInteger)offset
													  locale:(NSString *)locale
												   timestamp:(NSDate*)timestamp
												 accessToken:(NSString *)accessToken
													   error:(NSError **)error;

/** Get a list of new releases.
 
 Parse the response into an `SPTListPage` of `SPTAlbum`'s using `SPTListPage listPageFromData:withResponse:error`
 
 See https://developer.spotify.com/web-api/get-list-new-releases/ for more information on parameters
 
 @param country A ISO 3166-1 country code to get releases for, or `nil` for global releases.
 @param limit The number of results to return, max 50.
 @param offset The index at which to start returning results.
 @param accessToken An authenticated access token. Must be valid and authenticated
 @param error An optional error value, will be set if the creation of the request failed.
 */
+ (NSURLRequest *)createRequestForNewReleasesInCountry:(NSString *)country
												 limit:(NSInteger)limit
												offset:(NSInteger)offset
										   accessToken:(NSString *)accessToken
												 error:(NSError **)error;






///---------------------------
/// @name API Response Parsers
///---------------------------

/** Parse the response from createRequestForNewReleasesInCountry into a list of new releases

 @param data The API response data
 @param response The API response object
 @param error An optional pointer to an `NSError` that will receive the error code if operation failed.
 @return The list of new releases as an `SPTListPage` object
 */
+ (SPTListPage *)newReleasesFromData:(NSData *)data
						withResponse:(NSURLResponse *)response
							   error:(NSError **)error;











///--------------------------
/// @name Convenience methods
///--------------------------

/** Get a list of featured playlists
 
 This is a convenience method around the createRequest equivalent and the current `SPTRequestHandlerProtocol`
 
 See https://developer.spotify.com/web-api/get-list-featured-playlists/ for more information on parameters
 
 @param country A ISO 3166-1 country code to get playlists for, or `nil` to get global recommendations.
 @param limit The number of results to return, max 50.
 @param offset The index at which to start returning results.
 @param locale The locale of the user, for localized recommendations, `nil` will default to American English.
 @param timestamp The time of day to get recommendations for (without timezone), or `nil` for current local time
 @param accessToken An authenticated access token. Must be valid and authenticated
 @param block The block to be called when the operation is complete, containing a `SPTFeaturedPlaylistList`
 */
+ (void)requestFeaturedPlaylistsForCountry:(NSString *)country
									 limit:(NSInteger)limit
									offset:(NSInteger)offset
									locale:(NSString *)locale
								 timestamp:(NSDate*)timestamp
							   accessToken:(NSString *)accessToken
								  callback:(SPTRequestCallback)block;

/** Get a list of new releases.
 
 This is a convenience method around the createRequest equivalent and the current `SPTRequestHandlerProtocol`
 
 See https://developer.spotify.com/web-api/get-list-new-releases/ for more information on parameters
 
 @param country A ISO 3166-1 country code to get releases for, or `nil` for global releases.
 @param limit The number of results to return, max 50.
 @param offset The index at which to start returning results.
 @param accessToken An authenticated access token. Must be valid and authenticated
 @param block The block to be called when the operation is complete, containing a `SPTListPage`
 */
+ (void)requestNewReleasesForCountry:(NSString *)country
							   limit:(NSInteger)limit
							  offset:(NSInteger)offset
						 accessToken:(NSString *)accessToken
							callback:(SPTRequestCallback)block;


@end
