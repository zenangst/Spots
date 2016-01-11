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
#import "SPTPartialArtist.h"
#import "SPTAlbum.h"

@class SPTImage;

/** This class represents an artist on the Spotify service.

 API Docs: https://developer.spotify.com/web-api/get-artist/

 API Console: https://developer.spotify.com/web-api/console/get-artist
 
 API Model: https://developer.spotify.com/web-api/object-model/#artist-object-full
 */
@interface SPTArtist : SPTPartialArtist<SPTJSONObject>




///----------------------------
/// @name Properties
///----------------------------

/** Any external IDs of the track, such as the ISRC code. */
@property (nonatomic, readonly, copy) NSDictionary *externalIds;

/** Returns a list of genre strings for the artist. */
@property (nonatomic, readonly, copy) NSArray *genres;

/** Returns a list of artist images in various sizes, as `SPTImage` objects. */
@property (nonatomic, readonly, copy) NSArray *images;

/** Convenience method that returns the smallest available artist image. */
@property (nonatomic, readonly) SPTImage *smallestImage;

/** Convenience method that returns the largest available artist image. */
@property (nonatomic, readonly) SPTImage *largestImage;

/** The popularity of the artist as a value between 0.0 (least popular) to 100.0 (most popular). */
@property (nonatomic, readonly) double popularity;

/** The number of followers this artist has. */
@property (nonatomic, readonly) long followerCount;





///----------------------------
/// @name API Request Factories
///----------------------------

/** Create a request for fetching an artist
 
 @note This method takes Spotify URIs in the form `spotify:*`, NOT HTTP URLs.
 
 @param uri The Spotify URI of the artist to request.
 @param accessToken An optional access token. Can be `nil`.
 @param error An optional `NSError` that will be set if an error occured.
 @return A NSURLRequest for requesting the album
 */
+ (NSURLRequest*)createRequestForArtist:(NSURL *)uri
						withAccessToken:(NSString *)accessToken
								  error:(NSError **)error;

/** Create a request for fetching a multiple artists
 
 @note This method takes Spotify URIs in the form `spotify:*`, NOT HTTP URLs.
 
 @param uris An array of Spotify URIs.
 @param accessToken An optional access token. Can be `nil`.
 @param error An optional `NSError` that will be set if an error occured.
 @return A NSURLRequest for requesting the albums
 */
+ (NSURLRequest*)createRequestForArtists:(NSArray *)uris
						 withAccessToken:(NSString *)accessToken
								   error:(NSError **)error;

/** Request the artist's albums.
 
 The territory parameter of this method can be `nil` to specify "any country", but expect a lot of
 duplicates as the Spotify catalog often has different albums for each country. Pair this with an
 `SPTUser`'s `territory` property for best results.
 
 @param artist The Spotify URI of the artist.
 @param type The type of albums to get.
 @param accessToken An optional access token. Can be `nil`.
 @param market An ISO 3166 country code of the territory to get albums for, or `nil`.
 @param error An optional `NSError` that will be set if an error occured.
 */
+ (NSURLRequest*)createRequestForAlbumsByArtist:(NSURL*)artist
										 ofType:(SPTAlbumType)type
								withAccessToken:(NSString *)accessToken
										 market:(NSString *)market
										  error:(NSError **)error;

/** Request the artist's top tracks.
 
 The territory parameter of this method is required. Pair this with an
 `SPTUser`'s `territory` property for best results.
 
 @param artist The Spotify URI of the artist.
 @param accessToken An optional access token. Can be `nil`.
 @param market An ISO 3166 country code of the territory to get top tracks for.
 @param error An optional `NSError` that will be set if an error occured.
 */
+ (NSURLRequest*)createRequestForTopTracksForArtist:(NSURL *)artist
									withAccessToken:(NSString *)accessToken
											 market:(NSString *)market
											  error:(NSError **)error;

/** Request the artist's related artists.
 
 @param artist The Spotify URI of the artist.
 @param accessToken An optional access token. Can be `nil`.
 @param error An optional `NSError` that will be set if an error occured.
 */
+ (NSURLRequest*)createRequestForArtistsRelatedTo:(NSURL *)artist
								  withAccessToken:(NSString *)accessToken
											error:(NSError **)error;








///---------------------------
/// @name API Response Parsers
///---------------------------

/** Parse an API response into an `SPTArtist` object.
 
 @param data The API response data.
 @param response The API response object.
 @param error An optional `NSError` that will be set if an error occured when parsing the data.
 @return an `SPTAlbum` object, or nil if the parsing failed.
 */
+ (instancetype)artistFromData:(NSData *)data
				  withResponse:(NSURLResponse *)response
						 error:(NSError **)error;

/** Parse an JSON object structure into an array of `SPTAlbum` object.
 
 @param decodedObject The decoded JSON structure to parse.
 @param error An optional `NSError` that will be set if an error occured when parsing the data.
 @return an `SPTAlbum` object, or nil if the parsing failed.
 */
+ (instancetype)artistFromDecodedJSON:(id)decodedObject
								error:(NSError **)error;

/** Parse an API response into an array of `SPTArtist` objects.
 
 @param data The API response data.
 @param response The API response object.
 @param error An optional `NSError` that will be set if an error occured when parsing the data.
 @return an `SPTAlbum` object, or nil if the parsing failed.
 */
+ (NSArray*)artistsFromData:(NSData *)data
			   withResponse:(NSURLResponse *)response
					  error:(NSError **)error;

/** Parse an JSON object structure into an array of `SPTAlbum` object.
 
 @param decodedObject The decoded JSON structure to parse.
 @param error An optional `NSError` that will be set if an error occured when parsing the data.
 @return an `SPTAlbum` object, or nil if the parsing failed.
 */
+ (NSArray*)artistsFromDecodedJSON:(id)decodedObject
							 error:(NSError **)error;





///--------------------------
/// @name Convenience Methods
///--------------------------

/** Request the artist at the given Spotify URI.
 
 This is a convenience method on top of the `+createRequestForArtist:withAccessToken:error:` and `SPTRequest performRequest:callback:`
 
 @note This method takes Spotify URIs in the form `spotify:*`, NOT HTTP URLs.
 
 @param uri The Spotify URI of the artist to request.
 @param session An authenticated session. Can be `nil`.
 @param block The block to be called when the operation is complete. The block will pass a Spotify SDK metadata object on success, otherwise an error.
 */
+(void)artistWithURI:(NSURL *)uri session:(SPTSession *)session callback:(SPTRequestCallback)block;

/** Request the artist at the given Spotify URI.
 
 This is a convenience method on top of the `+createRequestForArtist:withAccessToken:error:` and `SPTRequest performRequest:callback:`
 
 @note This method takes Spotify URIs in the form `spotify:*`, NOT HTTP URLs.
 
 @param uri The Spotify URI of the artist to request.
 @param accessToken An optional access token. Can be `nil`.
 @param block The block to be called when the operation is complete. The block will pass a Spotify SDK metadata object on success, otherwise an error.
 */
+(void)artistWithURI:(NSURL *)uri accessToken:(NSString *)accessToken callback:(SPTRequestCallback)block;

/** Request multiple artists given an array of Spotify URIs.
 
 This is a convenience method on top of the +createRequestForArtists:withAccessToken:error:` and `SPTRequest performRequest:callback:`
 
 @note This method takes an array Spotify URIs in the form `spotify:*`, NOT HTTP URLs.
 
 @param uris An array of Spotify URIs.
 @param session An authenticated session. Can be `nil`.
 @param block The block to be called when the operation is complete. The block will pass an array of `SPTArtist` objects on success, otherwise an error.
 */
+(void)artistsWithURIs:(NSArray *)uris session:(SPTSession *)session callback:(SPTRequestCallback)block;

/** Request multiple artists given an array of Spotify URIs.
 
 This is a convenience method on top of the `+createRequestForArtists:withAccessToken:error:` and `SPTRequest performRequest:callback:`
 
 @note This method takes an array Spotify URIs in the form `spotify:*`, NOT HTTP URLs.
 
 @param uris An array of Spotify URIs.
 @param accessToken An optional access token. Can be `nil`.
 @param block The block to be called when the operation is complete. The block will pass an array of `SPTArtist` objects on success, otherwise an error.
 */
+(void)artistsWithURIs:(NSArray *)uris accessToken:(NSString *)accessToken callback:(SPTRequestCallback)block;

/** Request the artist's albums.
 
 The territory parameter of this method can be `nil` to specify "any country", but expect a lot of
 duplicates as the Spotify catalog often has different albums for each country. Pair this with an
 `SPTUser`'s `territory` property for best results.
 
 @param type The type of albums to get.
 @param session A valid `SPTSession`.
 @param territory An ISO 3166 country code of the territory to get albums for, or `nil`.
 @param block The block to be called when the operation is complete. The block will pass an
 `SPTListPage` object on success, otherwise an error.
 */
-(void)requestAlbumsOfType:(SPTAlbumType)type
			   withSession:(SPTSession *)session
	  availableInTerritory:(NSString *)territory
				  callback:(SPTRequestCallback)block;

/** Request the artist's albums.
 
 The territory parameter of this method can be `nil` to specify "any country", but expect a lot of
 duplicates as the Spotify catalog often has different albums for each country. Pair this with an
 `SPTUser`'s `territory` property for best results.
 
 @param type The type of albums to get.
 @param accessToken An optional access token. Can be `nil`.
 @param territory An ISO 3166 country code of the territory to get albums for, or `nil`.
 @param block The block to be called when the operation is complete. The block will pass an
 `SPTListPage` object on success, otherwise an error.
 */
-(void)requestAlbumsOfType:(SPTAlbumType)type
		   withAccessToken:(NSString *)accessToken
	  availableInTerritory:(NSString *)territory
				  callback:(SPTRequestCallback)block;

/** Request the artist's top tracks.
 
 The territory parameter of this method is required. Pair this with an
 `SPTUser`'s `territory` property for best results.
 
 @param territory An ISO 3166 country code of the territory to get top tracks for.
 @param session A valid `SPTSession`.
 @param block The block to be called when the operation is complete. The block will pass an
 `NSArray` object containing `SPTTrack`s on success, otherwise an error.
 */
-(void)requestTopTracksForTerritory:(NSString *)territory
						withSession:(SPTSession *)session
						   callback:(SPTRequestCallback)block;
/** Request the artist's top tracks.
 
 The territory parameter of this method is required. Pair this with an
 `SPTUser`'s `territory` property for best results.
 
 @param territory An ISO 3166 country code of the territory to get top tracks for.
 @param accessToken An optional access token. Can be `nil`.
 @param block The block to be called when the operation is complete. The block will pass an
 `NSArray` object containing `SPTTrack`s on success, otherwise an error.
 */
-(void)requestTopTracksForTerritory:(NSString *)territory
		   withAccessToken:(NSString *)accessToken
						   callback:(SPTRequestCallback)block;

/** Request the artist's related artists.
 
 @param session A valid `SPTSession`.
 @param block The block to be called when the operation is complete. The block will pass an
 `NSArray` object containing `SPTArtist`s on success, otherwise an error.
 */
-(void)requestRelatedArtistsWithSession:(SPTSession *)session
							   callback:(SPTRequestCallback)block;


/** Request the artist's related artists.
 
 @param accessToken An optional access token. Can be `nil`.
 @param block The block to be called when the operation is complete. The block will pass an
 `NSArray` object containing `SPTArtist`s on success, otherwise an error.
 */
-(void)requestRelatedArtistsWithAccessToken:(NSString *)accessToken
								   callback:(SPTRequestCallback)block;









///--------------------
/// @name Miscellaneous
///--------------------

/** Checks if the Spotify URI is a valid Spotify Artist URI.
 
 @note This method takes Spotify URIs in the form `spotify:*`, NOT HTTP URLs.
 
 @param uri The Spotify URI to check.
 @return True if a valid artist URI.
 */
+ (BOOL)isArtistURI:(NSURL *)uri;

/** Get the identifier part of an Spotify Artist URI.
 
 @note This method takes Spotify URIs in the form `spotify:*`, NOT HTTP URLs.
 
 @param uri The Spotify URI to check.
 @return The identifier part of the artist URI.
 */
+ (NSString *)identifierFromURI:(NSURL *)uri;

@end
