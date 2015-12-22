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
#import "SPTPartialAlbum.h"

@class SPTImage;
@class SPTPartialArtist;
@class SPTListPage;

/** This class represents an album on the Spotify service.
 
 API Docs: https://developer.spotify.com/web-api/get-album/
 
 API Console: https://developer.spotify.com/web-api/console/albums/

 API Model: https://developer.spotify.com/web-api/object-model/#album-object-full
 
 Example usage:

 ```
	[SPTAlbum albumWithURI:[NSURL URLWithString:@"spotify:album:58Dbqi6VBskSmnSsbXbgrs"]
		accessToken:accessToken
		market:@"UK"
		callback:^(NSError *error, id object) {
			if (error != nil) { handle error  }
			NSLog(@"Got album %@", object);
	}];
 ```
 */
@interface SPTAlbum : SPTPartialAlbum <SPTJSONObject, SPTTrackProvider>





///----------------------------
/// @name Properties
///----------------------------

/** Any external IDs of the album, such as the UPC code. */
@property (nonatomic, readonly, copy) NSDictionary *externalIds;

/** An array of artists for this album, as `SPTPartialArtist` objects. */
@property (nonatomic, readonly) NSArray *artists;

/** The tracks contained by this album, as a page of `SPTPartialTrack` objects. */
@property (nonatomic, readonly) SPTListPage *firstTrackPage;

/** The release year of the album if known, otherwise `0`. */
@property (nonatomic, readonly) NSInteger releaseYear;

/** Day-accurate release date of the track if known, otherwise `nil`. */
@property (nonatomic, readonly) NSDate *releaseDate;

/** Returns a list of genre strings for the album. */
@property (nonatomic, readonly, copy) NSArray *genres;

/** The popularity of the album as a value between 0.0 (least popular) to 100.0 (most popular). */
@property (nonatomic, readonly) double popularity;





///----------------------------
/// @name API Request Factories
///----------------------------

/** Create a request for getting an album.
 
 API Docs: https://developer.spotify.com/web-api/get-album/
 
 Try it: https://developer.spotify.com/web-api/console/get-album/
 
 @note This method takes Spotify URIs in the form `spotify:*`, NOT HTTP URLs.
 
 @param uri The Spotify URI of the album to request.
 @param accessToken An optional access token. Can be `nil`.
 @param market An optional market parameter. Can be `nil`.
 @param error An optional `NSError` that will be set if an error occured.
 @return A `NSURLRequest` for requesting the album
 */
+ (NSURLRequest*)createRequestForAlbum:(NSURL *)uri
					   withAccessToken:(NSString *)accessToken
								market:(NSString *)market
								 error:(NSError **)error;

/** Create a request for getting multiple albums.
 
 API Docs: https://developer.spotify.com/web-api/get-several-albums/
 
 Try it: https://developer.spotify.com/web-api/console/get-several-albums/
 
 @note This method takes Spotify URIs in the form `spotify:*`, NOT HTTP URLs.
 
 @param uris An array of Spotify URIs.
 @param accessToken An optional access token. Can be `nil`.
 @param market An optional market parameter. Can be `nil`.
 @param error An optional `NSError` that will be set if an error occured.
 @return A `NSURLRequest` for requesting the albums
 */
+ (NSURLRequest*)createRequestForAlbums:(NSArray *)uris
						withAccessToken:(NSString *)accessToken
								 market:(NSString *)market
								  error:(NSError **)error;





///---------------------------
/// @name API Response Parsers
///---------------------------

/** Parse an API Response into an `SPTAlbum` object.
 
 @param data The API response data
 @param response The API response object
 @param error An optional `NSError` that will be set if an error occured when parsing the data.
 @return an `SPTAlbum` object, or nil if the parsing failed.
 */
+ (instancetype)albumFromData:(NSData *)data
				 withResponse:(NSURLResponse *)response
						error:(NSError **)error;

/** Parse an JSON object structure into an `SPTAlbum` object.
 
 @param decodedObject The decoded JSON structure to parse.
 @param error An optional `NSError` that will be set if an error occured when parsing the data.
 @return an `SPTAlbum` object, or nil if the parsing failed.
 */
+ (instancetype)albumFromDecodedJSON:(id)decodedObject
							   error:(NSError **)error;

/** Parse an JSON object structure into an array of `SPTAlbum` object.
 
 @param decodedObject The decoded JSON structure to parse.
 @param error An optional `NSError` that will be set if an error occured when parsing the data.
 @return an `SPTAlbum` object, or nil if the parsing failed.
 */
+ (NSArray*)albumsFromDecodedJSON:(id)decodedObject
							error:(NSError **)error;





///--------------------------
/// @name Convenience Methods
///--------------------------

/** Request the album at the given Spotify URI.
 
 This is a convenience method on top of the [SPTAlbum createRequestForAlbum:withAccessToken:market:error:] and the shared SPTRequest handler.
 
 @note This method takes Spotify URIs in the form `spotify:*`, NOT HTTP URLs.
 @note This method is deprecated in favor of [SPTAlbum albumWithURI:accessToken:market:callback:]
 
 @param uri The Spotify URI of the album to request.
 @param session An authenticated session. Can be `nil`.
 @param block The block to be called when the operation is complete. The block will pass a SPTAlbum object on success, otherwise an error.
 */
+ (void)albumWithURI:(NSURL *)uri
			 session:(SPTSession *)session
			callback:(SPTRequestCallback)block DEPRECATED_ATTRIBUTE;

/** Request the album at the given Spotify URI.
 
 This is a convenience method on top of the [SPTAlbum createRequestForAlbum:withAccessToken:market:error:] and the shared SPTRequest handler.
 
 @note This method takes Spotify URIs in the form `spotify:*`, NOT HTTP URLs.
 
 @param uri The Spotify URI of the album to request.
 @param accessToken An optional access token. Can be `nil`.
 @param market An optional market parameter. Can be `nil`.
 @param block The block to be called when the operation is complete. The block will pass a SPTAlbum object on success, otherwise an error.
 */
+ (void)albumWithURI:(NSURL *)uri
		 accessToken:(NSString *)accessToken
			  market:(NSString *)market
			callback:(SPTRequestCallback)block;

/** Request multiple albums given an array of Spotify URIs.
 
 This is a convenience method on top of the [SPTAlbum createRequestForAlbums:withAccessToken:market:error:] and the shared SPTRequest handler.
 
 @note This method takes Spotify URIs in the form `spotify:*`, NOT HTTP URLs.
 
 @note This method is deprecated in favor of [SPTAlbum albumsWithURIs:accessToken:market:callback:]
 
 @param uris An array of Spotify URIs.
 @param session An authenticated session. Can be `nil`.
 @param block The block to be called when the operation is complete. The block will pass an array of SPTAlbum objects on success, otherwise an error.
 */
+ (void)albumsWithURIs:(NSArray *)uris
			   session:(SPTSession *)session
			  callback:(SPTRequestCallback)block DEPRECATED_ATTRIBUTE;

/** Request multiple albums given an array of Spotify URIs.
 
 This is a convenience method on top of the [SPTAlbum createRequestForAlbums:withAccessToken:market:error:] and the shared SPTRequest handler.
 
 @note This method takes Spotify URIs in the form `spotify:*`, NOT HTTP URLs.
 
 @param uris An array of Spotify URIs.
 @param accessToken An optional access token. Can be `nil`.
 @param market An optional market parameter. Can be `nil`.
 @param block The block to be called when the operation is complete. The block will pass an array of SPTAlbum objects on success, otherwise an error.
 */
+ (void)albumsWithURIs:(NSArray *)uris
		   accessToken:(NSString *)accessToken
				market:(NSString *)market
			  callback:(SPTRequestCallback)block;












///--------------------
/// @name Miscellaneous
///--------------------

/** Checks if the Spotify URI is a valid Spotify Album URI.
 
 @note This method takes Spotify URIs in the form `spotify:*`, NOT HTTP URLs.
 
 @param uri The Spotify URI to check.
 */
+ (BOOL)isAlbumURI:(NSURL*)uri;







@end
