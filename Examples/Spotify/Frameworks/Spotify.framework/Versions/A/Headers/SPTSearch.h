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
#import "SPTListPage.h"

/** This class provides helpers for using the search features in the Spotify API, See: https://developer.spotify.com/web-api/console/search/ */
@interface SPTSearch : NSObject





///----------------------------
/// @name Search
///----------------------------

/** Performs a search with a given query, offset and market filtering
 
 This is a convenience method around the createRequest equivalent and the current `SPTRequestHandlerProtocol`
  
 @param searchQuery The query to pass to the search.
 @param searchQueryType The type of search to do.
 @param offset The index at which to start returning results.
 @param accessToken A valid access token, or `nil`.
 @param market Either a ISO 3166-1 country code to filter the results to, or "from_token" (`SPTMarketFromToken`) to pick the market from the session (requires the `user-read-private` scope), or `nil` for no market filtering.
 @param block The block to be called when the operation is complete. The block will pass an `SPTListPage` containing results on success, otherwise an error.
 */
+(void)performSearchWithQuery:(NSString *)searchQuery
					queryType:(SPTSearchQueryType)searchQueryType
					   offset:(NSInteger)offset
				  accessToken:(NSString *)accessToken
					   market:(NSString *)market
					 callback:(SPTRequestCallback)block;

/** Create a request for searching with a given query, offset and market filtering
 
 @param searchQuery The query to pass to the search.
 @param searchQueryType The type of search to do.
 @param offset The index at which to start returning results.
 @param accessToken A valid access token, or `nil`.
 @param market Either a ISO 3166-1 country code to filter the results to, or "from_token" (`SPTMarketFromToken`) to pick the market from the session (requires the `user-read-private` scope), or `nil` for no market filtering.
 @param error An optional pointer to an `NSError` that will receive the error code if operation failed.
 */
+(NSURLRequest*)createRequestForSearchWithQuery:(NSString *)searchQuery
									  queryType:(SPTSearchQueryType)searchQueryType
										 offset:(NSInteger)offset
									accessToken:(NSString *)accessToken
										 market:(NSString *)market
										  error:(NSError**)error;

/** Performs a search with a given query and market filtering
 
 This is a convenience method around the createRequest equivalent and the current `SPTRequestHandlerProtocol`
 
 @param searchQuery The query to pass to the search.
 @param searchQueryType The type of search to do.
 @param accessToken A valid access token, or `nil`.
 @param market Either a ISO 3166-1 country code to filter the results to, or `from_token` to pick the market from the session (requires the `user-read-private` scope), or `nil` for no market filtering.
 @param block The block to be called when the operation is complete. The block will pass an `SPTListPage` containing results on success, otherwise an error.
 */
+(void)performSearchWithQuery:(NSString *)searchQuery
					queryType:(SPTSearchQueryType)searchQueryType
				  accessToken:(NSString *)accessToken
					   market:(NSString *)market
					 callback:(SPTRequestCallback)block;

/** Createa a query for searching with a given query and market filtering
 
 @param searchQuery The query to pass to the search.
 @param searchQueryType The type of search to do.
 @param accessToken A valid access token, or `nil`.
 @param market Either a ISO 3166-1 country code to filter the results to, or `from_token` to pick the market from the session (requires the `user-read-private` scope), or `nil` for no market filtering.
 @param error An optional pointer to an `NSError` that will receive the error code if operation failed.
 */
+ (NSURLRequest*)createRequestForSearchWithQuery:(NSString *)searchQuery
									   queryType:(SPTSearchQueryType)searchQueryType
									 accessToken:(NSString *)accessToken
										  market:(NSString *)market
										   error:(NSError**)error;

/** Performs a search with a given query and offset
 
 This is a convenience method around the createRequest equivalent and the current `SPTRequestHandlerProtocol`
 
 @param searchQuery The query to pass to the search.
 @param searchQueryType The type of search to do.
 @param offset The index at which to start returning results.
 @param accessToken A valid access token, or `nil`.
 @param block The block to be called when the operation is complete. The block will pass an `SPTListPage` containing results on success, otherwise an error.
 */
+ (void)performSearchWithQuery:(NSString *)searchQuery
					 queryType:(SPTSearchQueryType)searchQueryType
						offset:(NSInteger)offset
				   accessToken:(NSString *)accessToken
					  callback:(SPTRequestCallback)block;

/** Create a request for searching with a given query and offset
 
 @param searchQuery The query to pass to the search.
 @param searchQueryType The type of search to do.
 @param offset The index at which to start returning results.
 @param accessToken A valid access token, or `nil`.
 @param error An optional pointer to an `NSError` that will receive the error code if operation failed.
 */
+ (NSURLRequest*)createRequestForSearchWithQuery:(NSString *)searchQuery
									   queryType:(SPTSearchQueryType)searchQueryType
										  offset:(NSInteger)offset
									 accessToken:(NSString *)accessToken
										   error:(NSError**)error;

/** Performs a search with a given query.
 
 This is a convenience method around the createRequest equivalent and the current `SPTRequestHandlerProtocol`

 @param searchQuery The query to pass to the search.
 @param searchQueryType The type of search to do.
 @param accessToken A valid access token, or `nil`.
 @param block The block to be called when the operation is complete. The block will pass an `SPTListPage` containing results on success, otherwise an error.
 */
+ (void)performSearchWithQuery:(NSString *)searchQuery
					 queryType:(SPTSearchQueryType)searchQueryType
				   accessToken:(NSString *)accessToken
					  callback:(SPTRequestCallback)block;

/** Create a request for searching with a given query.
 
 @param searchQuery The query to pass to the search.
 @param searchQueryType The type of search to do.
 @param accessToken A valid access token, or `nil`.
 @param error An optional pointer to an `NSError` that will receive the error code if operation failed.
 */
+ (NSURLRequest*)createRequestForSearchWithQuery:(NSString *)searchQuery
									   queryType:(SPTSearchQueryType)searchQueryType
									 accessToken:(NSString *)accessToken
										   error:(NSError**)error;





///------------------------------
/// @name Parsers / Deserializers
///------------------------------

/** Parse the response from createRequestForSearch into a list of search results
 
 @param data The API response data
 @param response The API response object
 @param searchQueryType The type of search to do.
 @param error An optional pointer to an `NSError` that will receive the error code if operation failed.
 @return The list of search results as an `SPTListPage` object
 */
+ (SPTListPage *)searchResultsFromData:(NSData *)data
						  withResponse:(NSURLResponse *)response
							 queryType:(SPTSearchQueryType)searchQueryType
								 error:(NSError **)error;

/** Parse the response from createRequestForSearch into a list of search results
 
 @param decodedObject The decoded JSON object structure
 @param searchQueryType The type of search to do.
 @param error An optional pointer to an `NSError` that will receive the error code if operation failed.
 @return The list of search results as an `SPTListPage` object
 */
+ (SPTListPage *)searchResultsFromDecodedJSON:(id)decodedObject
									queryType:(SPTSearchQueryType)searchQueryType
										error:(NSError **)error;

@end
