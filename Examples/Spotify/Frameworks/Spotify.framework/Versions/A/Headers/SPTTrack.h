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
#import "SPTPartialAlbum.h"
#import "SPTPartialTrack.h"
#import "SPTRequest.h"

/** This class represents a track on the Spotify service.
 
 API Docs: https://developer.spotify.com/web-api/track-endpoints/

 API Console: https://developer.spotify.com/web-api/console/tracks/
 
 API Model: https://developer.spotify.com/web-api/object-model/#track-object-full
 */
@interface SPTTrack : SPTPartialTrack <SPTJSONObject>






///----------------------------
/// @name Properties
///----------------------------

/** The popularity of the track as a value between 0.0 (least popular) to 100.0 (most popular). */
@property (nonatomic, readonly) double popularity;

/** Any external IDs of the track, such as the ISRC code. */
@property (nonatomic, readonly, copy) NSDictionary *externalIds;








///----------------------------
/// @name API Request Factories
///----------------------------

/** Create a request for fetching one track.
 
 Parse the response into an `SPTListPage` using `SPTTrack trackFromData:withResponse:error:`
 
 See https://developer.spotify.com/web-api/get-list-new-releases/ for more information on parameters
 
 @param uri The Spotify URI of the track to request.
 @param accessToken An access token, or `nil`.
 @param market Either a ISO 3166-1 country code to filter the results to, or `from_token` to pick the market from the session (requires the `user-read-private` scope), or `nil` for no market filtering.
 @param error An optional pointer to an `NSError` that will receive the error code if operation failed.
 */
+ (NSURLRequest *)createRequestForTrack:(NSURL *)uri
						withAccessToken:(NSString *)accessToken
								 market:(NSString *)market
								  error:(NSError **)error;

/** Create a request for fetching multiple rtacks
 
 Parse the response into an `NSArray` of `SPTTrack`-objects using `SPTTrack trackFromDecodedJSON:`
 
 See https://developer.spotify.com/web-api/get-list-new-releases/ for more information on parameters
 
 @param uris An array of Spotify Track URIs.
 @param accessToken An access token, or `nil`.
 @param market Either a ISO 3166-1 country code to filter the results to, or `from_token` to pick the market from the session (requires the `user-read-private` scope), or `nil` for no market filtering.
 @param error An optional pointer to an `NSError` that will receive the error code if operation failed.
 */
+ (NSURLRequest *)createRequestForTracks:(NSArray *)uris
						 withAccessToken:(NSString *)accessToken
								  market:(NSString *)market
								   error:(NSError **)error;








///---------------------------
/// @name API Response Parsers
///---------------------------

/** Parse an JSON object structure into an array of `SPTTrack` object.
 
 @param data The API response data
 @param response The API response object
 @param error An optional `NSError` that will be set if an error occured when parsing the data.
 @return an `SPTTrack` object, or nil if the parsing failed.
 */
+ (instancetype)trackFromData:(NSData *)data
				 withResponse:(NSURLResponse *)response
						error:(NSError **)error;

/** Parse an JSON object structure into an array of `SPTTrack` object.
 
 @param decodedObject The decoded JSON structure to parse.
 @param error An optional `NSError` that will be set if an error occured when parsing the data.
 @return an `SPTAlbum` object, or nil if the parsing failed.
 */
+ (instancetype)trackFromDecodedJSON:(id)decodedObject
							   error:(NSError **)error;

/** Parse an JSON object structure into an array of `SPTTrack` object.
 
 @param data The API response data
 @param response The API response object
 @param error An optional `NSError` that will be set if an error occured when parsing the data.
 @return an array of `SPTTrack` objects, or nil if the parsing failed.
 */
+ (NSArray *)tracksFromData:(NSData *)data
			   withResponse:(NSURLResponse *)response
					  error:(NSError **)error;

/** Parse an JSON object structure into an array of `SPTTrack` objects.
 
 @param decodedObject The decoded JSON structure to parse.
 @param error An optional `NSError` that will be set if an error occured when parsing the data.
 @return an `SPTAlbum` object, or nil if the parsing failed.
 */
+ (NSArray*)tracksFromDecodedJSON:(id)decodedObject
							error:(NSError **)error;








///--------------------------
/// @name Convenience Methods
///--------------------------

/** Request the track at the given Spotify URI.
 
 This is a convenience method on top of the `SPTTrack createRequestForTrack:withAccessToken:error:` and `SPTRequest performRequest:callback:` methods
 
 See: https://developer.spotify.com/web-api/get-track/
 
 @note This method takes Spotify URIs in the form `spotify:*`, NOT HTTP URLs.
 
 @param uri The Spotify URI of the track to request.
 @param session An authenticated session. Can be `nil`.
 @param block The block to be called when the operation is complete. The block will pass a Spotify SDK metadata object on success, otherwise an error.
 */
+ (void)trackWithURI:(NSURL *)uri session:(SPTSession *)session callback:(SPTRequestCallback)block;

/** Request the track at the given Spotify URI.
 
 This is a convenience method on top of the `SPTTrack createRequestForTracks:withAccessToken:error:` and `SPTRequest performRequest:callback:` methods
 
 See: https://developer.spotify.com/web-api/get-track/
 
 @note This method takes Spotify URIs in the form `spotify:*`, NOT HTTP URLs.
 
 @param uri The Spotify URI of the track to request.
 @param accessToken An access token, or `nil`.
 @param market Either a ISO 3166-1 country code to filter the results to, or `from_token` to pick the market from the session (requires the `user-read-private` scope), or `nil` for no market filtering.
 @param block The block to be called when the operation is complete. The block will pass a Spotify SDK metadata object on success, otherwise an error.
 */
+ (void)trackWithURI:(NSURL *)uri accessToken:(NSString *)accessToken market:(NSString *)market callback:(SPTRequestCallback)block;

/** Request multiple tracks with given an array of Spotify URIs.
 
 This is a convenience method on top of the `SPTTrack createRequestForTrack:withAccessToken:error:` and `SPTRequest performRequest:callback:` methods
 
 See: https://developer.spotify.com/web-api/get-several-tracks/
 
 @note This method takes an array of Spotify URIs in the form `spotify:*`, NOT HTTP URLs.
 
 @param uris An array of Spotify Track URIs.
 @param session An authenticated session. Can be `nil`.
 @param block The block to be called when the operation is complete. The block will pass an array of Spotify SDK metadata objects on success, otherwise an error.
 */

+ (void)tracksWithURIs:(NSArray *)uris session:(SPTSession *)session callback:(SPTRequestCallback)block;

/** Request multiple tracks with given an array of Spotify URIs.
 
 This is a convenience method on top of the `SPTTrack createRequestForTracks:withAccessToken:error:` and `SPTRequest performRequest:callback:` methods
 
 See: https://developer.spotify.com/web-api/get-several-tracks/
 
 @note This method takes an array of Spotify URIs in the form `spotify:*`, NOT HTTP URLs.
 
 @param uris An array of Spotify Track URIs.
 @param accessToken An access token, or `nil`.
 @param market Either a ISO 3166-1 country code to filter the results to, or `from_token` to pick the market from the session (requires the `user-read-private` scope), or `nil` for no market filtering.
 @param block The block to be called when the operation is complete. The block will pass an array of Spotify SDK metadata objects on success, otherwise an error.
 */

+ (void)tracksWithURIs:(NSArray *)uris accessToken:(NSString *)accessToken market:(NSString *)market callback:(SPTRequestCallback)block;







///--------------------
/// @name Miscellaneous
///--------------------

/** Checks if the Spotify URI is a valid Spotify Track URI.
 
 @note This method takes Spotify URIs in the form `spotify:*`, NOT HTTP URLs.
 
 @param uri The Spotify URI to check.
 */
+ (BOOL)isTrackURI:(NSURL*)uri;

/** Returns the identifier for a Spotify Track uri.
 
 @note This method takes Spotify URIs in the form `spotify:*`, NOT HTTP URLs.
 
 @param uri An track uri.
 @return The track id, or `nil` if an invalid track uri was passed.
 */
+ (NSString *)identifierFromURI:(NSURL *)uri;

/** Returns a list of track id's from an array containing either `SPTPartialTrack`, `SPTTrack` or `NSURL`'s 
 
 @param tracks An array of tracks.
 @return An array of track id's.
*/
+ (NSArray*)identifiersFromArray:(NSArray *)tracks;

/** Returns a list of track uri's as `NSURL`'s from an array containing either `SPTPartialTrack`, `SPTTrack` or `NSURL`'s
 
 @param tracks An array of tracks.
 @return An array of track uri's.
 */
+ (NSArray*)urisFromArray:(NSArray *)tracks;

/** Returns a list of track uri's as `NSString`'s from an array containing either `SPTPartialTrack`, `SPTTrack` or `NSURL`'s
 
 @param tracks An array of tracks.
 @return An array of track uri strings.
 */
+ (NSArray*)uriStringsFromArray:(NSArray *)tracks;

@end
