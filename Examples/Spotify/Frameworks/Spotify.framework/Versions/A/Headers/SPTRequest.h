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
#import "SPTPartialObject.h"

@class SPTSession;

/** Callback for requests
 
 @param error An optional error indicating that the operation failed, or `nil` if it succeeded.
 @param object The result of the operation
 */
typedef void (^SPTRequestCallback)(NSError *error, id object);

/** Callback for `SPTRequestHandlerProtocol` 
 
 @param error An optional error indicating that the request failed, or `nil` if it succeeded.
 @param response The `NSURLResponse` for the request
 @param data An `NSData` containing the result of the request
 */
typedef void (^SPTRequestDataCallback)(NSError *error, NSURLResponse *response, NSData *data);

/// Defines types of result objects that can be searched for.
typedef NS_ENUM(NSUInteger, SPTSearchQueryType) {
	/// Specifies that all search results will be of type `SPTTrack`.
	SPTQueryTypeTrack = 0,
	/// Specifies that all search results will be of type `SPTArtist`.
	SPTQueryTypeArtist,
	/// Specifies that all search results will be of type `SPTAlbum`.
	SPTQueryTypeAlbum,
	/// Specifies that all search results will be of type `SPTPartialPlaylist`.
	SPTQueryTypePlaylist,
};

FOUNDATION_EXPORT NSString * const SPTMarketFromToken;

/** Protocol for request handlers
 */
@protocol SPTRequestHandlerProtocol

/**
 Make a request
 
 @param request The NSURLRequest object for the request.
 @param block The callback to call when data has been received.
 */
-(void)performRequest:(NSURLRequest *)request callback:(SPTRequestDataCallback)block;

@end



/** This class provides convenience methods for talking to the Spotify Web API and wraps a customizable handler for requests which are used by those convenience methods.
 
 All the functions for direct access to the api inside this class has been deprecated and moved out to their respective classes, for getting track metadata, look at `SPTTrack`, for getting featured playlists in browse, look at `SPTBrowse` and so on.

 All model classes provide both convenience methods for getting content in the callback fashion, but also provides methods named `createRequestFor...` for creating `NSURLRequests` for calling the api directly with the request handler of choice, this allows you to do caching, cancellation and scheduling of calls in your own way. The model classes also provides methods for parsing a API Response back into a usable object, those are called `...fromData:withResponse:error`, pluralized methods for getting multiple entities at once are also available when appropriate.

 
 Example of using the API request creation / API response parser paradigm:
 
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

 Example without response body:

 ```
 	// Following a user
	NSURLRequest *req = [SPTFollow createRequestForFollowingUsers:@[@"possan"]] withAccessToken:accessToken error:nil];
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
				NSLog(@"Bork bork!");
				break;
		}
	}];
 ``` 

 Example of using convenience methods:

 ```
	// Getting multiple artists
	[SPTArtist artistsWithURIs:@[
			[NSURL URLWithString:@"spotify:artist:30Y7JOpiNgAGEhnkYPdI1P"],
			[NSURL URLWithString:@"spotify:artist:0jO0TlgxW9Il5JphAWzhR4"],
			[NSURL URLWithString:@"spotify:artist:0AKlaf8M1k8NjJp1uCOlTA"]
		]
		accessToken:accessToken callback:^(NSError *error, id object) {
			NSLog(@"Got artists: %@", object);
		}];
 ```

 API Console: https://developer.spotify.com/web-api/console

 */
@interface SPTRequest : NSObject





///----------------------
/// @name Request handler
///----------------------

/**
 Get a request handler
 */
+ (id<SPTRequestHandlerProtocol>)sharedHandler;

/**
 Override the default request handler, this is where you'd implement your own if you want to, or use AFNetworking or similar
 
 @param handler New handler for requests
 */
+ (void)setSharedHandler:(id<SPTRequestHandlerProtocol>)handler;





///----------------------------
/// @name Generic Requests
///----------------------------

/** Request the item at the given Spotify URI.
  
 This method is deprecated, use the helpers in each individual object class instead.

 For example: `SPTTrack trackWithURI:session:callback:` or `SPTPlaylistSnapshot playlistWithURI:session:callback

 @note This method takes Spotify URIs in the form `spotify:*`, NOT HTTP URLs.

 @param uri The Spotify URI of the item to request.
 @param session An authenticated session. Can be `nil` depending on the URI.
 @param block The block to be called when the operation is complete. The block will pass a Spotify SDK metadata object on success, otherwise an error.
 */
+ (void)requestItemAtURI:(NSURL *)uri
			 withSession:(SPTSession *)session
				callback:(SPTRequestCallback)block DEPRECATED_ATTRIBUTE;

/** Request the item at the given Spotify URI.

 @note This method takes Spotify URIs in the form `spotify:*`, NOT HTTP URLs.

 @param uri The Spotify URI of the item to request.
 @param market Either a ISO 3166-1 country code to filter the results to, or "from_token" (`SPTMarketFromToken`) to pick the market from the session (requires the `user-read-private` scope), or `nil` for no market filtering.
 @param session An authenticated session. Can be `nil` depending on the URI.
 @param block The block to be called when the operation is complete. The block will pass a Spotify SDK metadata object on success, otherwise an error.
 */
+ (void)requestItemAtURI:(NSURL *)uri
			 withSession:(SPTSession *)session
				  market:(NSString *)market
				callback:(SPTRequestCallback)block DEPRECATED_ATTRIBUTE;

/** Convert an `SPTPartialObject` into a "full" metadata object.

 Use the appropriate `...WithURI` method in the full metadata object instead.  

 @param partialObject The object to promote to a "full" object.
 @param session An authenticated session. Can be `nil` depending on the URI.
 @param block The block to be called when the operation is complete. The block will pass a Spotify SDK metadata object on success, otherwise an error.
 */
+ (void)requestItemFromPartialObject:(id <SPTPartialObject>)partialObject
						 withSession:(SPTSession *)session
							callback:(SPTRequestCallback)block DEPRECATED_ATTRIBUTE;

/** Convert an `SPTPartialObject` into a "full" metadata object.

 Use the appropriate `...WithURI` method in the full metadata object instead.  

 @param partialObject The object to promote to a "full" object.
 @param market Either a ISO 3166-1 country code to filter the results to, or "from_token" (`SPTMarketFromToken`) to pick the market from the session (requires the `user-read-private` scope), or `nil` for no market filtering.
 @param session An authenticated session. Can be `nil` depending on the URI.
 @param block The block to be called when the operation is complete. The block will pass a Spotify SDK metadata object on success, otherwise an error.
 */
+ (void)requestItemFromPartialObject:(id <SPTPartialObject>)partialObject
						 withSession:(SPTSession *)session
							  market:(NSString *)market
							callback:(SPTRequestCallback)block DEPRECATED_ATTRIBUTE;




///-------------------------------
/// @name Request creation helpers
///-------------------------------

/** Helper function for creates an authenticated `NSURLRequest` for a Spotify API resource.
 
 @param url The HTTPS URL to request, this is a Spotify API URL, not a spotify URI.
 @param accessToken A valid access token, or `nil` if authentication isn't needed.
 @param httpMethod The HTTP method to use eg. `GET` `POST` etc.
 @param values The arguments to send to the URL
 @param encodeAsJSON Encode arguments as an JSON object in the body of the request instead of QueryString encoding them.
 @param dataAsQueryString Send arguments as a part of the query string instead of in the body of the request.
 @param error An optional `NSError` that will receive an error if request creation failed.
 @return A `NSURLRequest`
 */

+ (NSURLRequest *)createRequestForURL:(NSURL *)url
					  withAccessToken:(NSString *)accessToken
						   httpMethod:(NSString *)httpMethod
							   values:(id)values
					  valueBodyIsJSON:(BOOL)encodeAsJSON
				sendDataAsQueryString:(BOOL)dataAsQueryString
								error:(NSError **)error;





///----------------------------
/// @name Playlists
///----------------------------

/** Get the authenticated user's playlist list.
 
 This method is moved to the `SPTPlaylistList` class.

 @param session An authenticated session. Must be valid and authenticated with the
 `SPTAuthPlaylistReadScope` or `SPTAuthPlaylistReadPrivateScope` scope as necessary.
 @param block The block to be called when the operation is complete. The block will pass an `SPTPlaylistList` object on success, otherwise an error.
 */
+ (void)playlistsForUserInSession:(SPTSession *)session
						 callback:(SPTRequestCallback)block DEPRECATED_ATTRIBUTE;

/** Get the a user's playlist list.
 
 This method is moved to the `SPTPlaylistList` class.

 @param username The username of the user to get playlists for.
 @param session An authenticated session. Must be valid and authenticated with the `SPTAuthPlaylistReadScope` scope as necessary.
 @param block The block to be called when the operation is complete. The block will pass an `SPTPlaylistList` object on success, otherwise an error.
 */
+ (void)playlistsForUser:(NSString *)username
			 withSession:(SPTSession *)session
				callback:(SPTRequestCallback)block DEPRECATED_ATTRIBUTE;

/** Get the authenticated user's starred playlist.
 
 This method is moved to the `SPTPlaylistSnapshot` class.

 @param session An authenticated session. Must be valid and authenticated with the
 `SPTAuthPlaylistReadScope` or `SPTAuthPlaylistReadPrivateScope` scope as necessary.
 @param block The block to be called when the operation is complete. The block will pass an `SPTPlaylistSnapshot` object on success, otherwise an error.
 */
+ (void)starredListForUserInSession:(SPTSession *)session
						   callback:(SPTRequestCallback)block DEPRECATED_ATTRIBUTE;




///----------------------------
/// @name User Information
///----------------------------

/** Get the authenticated user's information.

 This method is moved to the `SPTUser` class.

 @param session An authenticated session. Must be valid and authenticated with the
 scopes required for the information you require. See the `SPTUser` documentation for details.
 @param block The block to be called when the operation is complete. The block will pass an `SPTUser` object on success, otherwise an error.
 @see SPTUser
 */
+ (void)userInformationForUserInSession:(SPTSession *)session
							   callback:(SPTRequestCallback)block DEPRECATED_ATTRIBUTE;




///----------------------------
/// @name Search
///----------------------------

/** Performs a search with a given query, offset and market filtering
 
 This method is moved to the `SPTSearch` class.

 @param searchQuery The query to pass to the search.
 @param searchQueryType The type of search to do.
 @param offset The index at which to start returning results.
 @param session An authenticated session. Can be `nil`.
 @param market Either a ISO 3166-1 country code to filter the results to, or "from_token" (`SPTMarketFromToken`) to pick the market from the session (requires the `user-read-private` scope), or `nil` for no market filtering.
 @param block The block to be called when the operation is complete. The block will pass an `SPTListPage` containing results on success, otherwise an error.
 */
+ (void)performSearchWithQuery:(NSString *)searchQuery
					 queryType:(SPTSearchQueryType)searchQueryType
						offset:(NSInteger)offset
					   session:(SPTSession *)session
						market:(NSString *)market
					  callback:(SPTRequestCallback)block DEPRECATED_ATTRIBUTE;

/** Performs a search with a given query and market filtering

 This method is moved to the `SPTSearch` class.

 @param searchQuery The query to pass to the search.
 @param searchQueryType The type of search to do.
 @param session An authenticated session. Can be `nil`.
 @param market Either a ISO 3166-1 country code to filter the results to, or `from_token` to pick the market from the session (requires the `user-read-private` scope), or `nil` for no market filtering.
 @param block The block to be called when the operation is complete. The block will pass an `SPTListPage` containing results on success, otherwise an error.
 */
+ (void)performSearchWithQuery:(NSString *)searchQuery
					 queryType:(SPTSearchQueryType)searchQueryType
					   session:(SPTSession *)session
						market:(NSString *)market
					  callback:(SPTRequestCallback)block DEPRECATED_ATTRIBUTE;

/** Performs a search with a given query and offset
 
 This method is moved to the `SPTSearch` class.

 @param searchQuery The query to pass to the search.
 @param searchQueryType The type of search to do.
 @param offset The index at which to start returning results.
 @param session An authenticated session. Can be `nil`.
 @param block The block to be called when the operation is complete. The block will pass an `SPTListPage` containing results on success, otherwise an error.
 */
+ (void)performSearchWithQuery:(NSString *)searchQuery
					 queryType:(SPTSearchQueryType)searchQueryType
						offset:(NSInteger)offset
					   session:(SPTSession *)session
					  callback:(SPTRequestCallback)block DEPRECATED_ATTRIBUTE;

/** Performs a search with a given query.
 
 This method is moved to the `SPTSearch` class.

 @param searchQuery The query to pass to the search.
 @param searchQueryType The type of search to do.
 @param session An authenticated session. Can be `nil`.
 @param block The block to be called when the operation is complete. The block will pass an `SPTListPage` containing results on success, otherwise an error.
 */
+ (void)performSearchWithQuery:(NSString *)searchQuery
					 queryType:(SPTSearchQueryType)searchQueryType
					   session:(SPTSession *)session
					  callback:(SPTRequestCallback)block DEPRECATED_ATTRIBUTE;




///----------------------------
/// @name Your Music Library
///----------------------------

/** Gets the authenticated user's Your Music Library tracks

 This method is moved to the `SPTYourMusic` class.

 @param session An authenticated session. Must be valid and authenticated with the
 `SPTAuthUserLibraryRead` scope.
 @param block The block will pass an `SPTListPage` containing results on success, otherwise an error.
 */
+ (void)savedTracksForUserInSession:(SPTSession *)session
						   callback:(SPTRequestCallback)block DEPRECATED_ATTRIBUTE;

/** Adds a set of tracks to the authenticated user's Your Music Library.

 This method is moved to the `SPTYourMusic` class.

 @param tracks An array of `SPTTrack` or `SPTPartialTrack` objects.
 @param session An authenticated session. Must be valid and authenticated with the
 `SPTAuthUserLibraryModify` scope.
 @param block The block to be called when the operation is complete.
 */
+ (void)saveTracks:(NSArray *)tracks
  forUserInSession:(SPTSession *)session
		  callback:(SPTRequestCallback)block DEPRECATED_ATTRIBUTE;

/** Checks whether the authenticated user's Your Music Library contains a set of tracks.

 This method is moved to the `SPTYourMusic` class.

 @param tracks An array of `SPTTrack` or `SPTPartialTrack` objects.
 @param session An authenticated session. Must be valid and authenticated with the
 `SPTAuthUserLibraryRead` scope.
 @param block The block to be called when the operation is complete. The block will pass an NSArray of Bool values on success, otherwise an error.
 */
+ (void)savedTracksContains:(NSArray *)tracks
		   forUserInSession:(SPTSession *)session
				   callback:(SPTRequestCallback)block DEPRECATED_ATTRIBUTE;

/** Removes a set of tracks from the authenticated user's Your Music Library.

 This method is moved to the `SPTYourMusic` class.

 @param tracks An array of `SPTTrack` or `SPTPartialTrack` objects.
 @param session An authenticated session. Must be valid and authenticated with the
 `SPTAuthUserLibraryModify` scope.
 @param block The block to be called when the operation is complete.
*/
+ (void)removeTracksFromSaved:(NSArray *)tracks
			 forUserInSession:(SPTSession *)session
					 callback:(SPTRequestCallback)block DEPRECATED_ATTRIBUTE;





///----------------------------
/// @name Browse
///----------------------------

/** Get a list of featured playlists
 
 This method is moved to the `SPTBrowse` class.

 See https://developer.spotify.com/web-api/get-list-featured-playlists/ for more information on parameters
 
 @param country A ISO 3166-1 country code to get playlists for, or `nil` to get global recommendations.
 @param limit The number of results to return, max 50.
 @param offset The index at which to start returning results.
 @param locale The locale of the user, for localized recommendations, `nil` will default to American English.
 @param timestamp The time of day to get recommendations for (without timezone), or `nil` for current local time
 @param session An authenticated session. Must be valid and authenticated with the
 @param block The block to be called when the operation is complete, containing a `SPTFeaturedPlaylistList`
 */
+ (void)requestFeaturedPlaylistsForCountry:(NSString *)country
									 limit:(NSInteger)limit
									offset:(NSInteger)offset
									locale:(NSString *)locale
								 timestamp:(NSDate*)timestamp
								   session:(SPTSession *)session
								  callback:(SPTRequestCallback)block DEPRECATED_ATTRIBUTE;

/** Get a list of new releases.
 
 This method is moved to the `SPTBrowse` class.
 
 See https://developer.spotify.com/web-api/get-list-new-releases/ for more information on parameters

 @param country A ISO 3166-1 country code to get releases for, or `nil` for global releases.
 @param limit The number of results to return, max 50.
 @param offset The index at which to start returning results.
 @param session An authenticated session. Must be valid and authenticated with the `SPTAuthUserLibraryModify` scope.
 @param block The block to be called when the operation is complete, containing a `SPTListPage`
 */
+ (void)requestNewReleasesForCountry:(NSString *)country
							   limit:(NSInteger)limit
							  offset:(NSInteger)offset
							 session:(SPTSession *)session
							callback:(SPTRequestCallback)block DEPRECATED_ATTRIBUTE;





@end
