//
//  SPSearch.h
//  CocoaLibSpotify
//
//  Created by Daniel Kennett on 4/21/11.
/*
Copyright (c) 2011, Spotify AB
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Spotify AB nor the names of its contributors may 
      be used to endorse or promote products derived from this software 
      without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL SPOTIFY AB BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <Foundation/Foundation.h>
#import "CocoaLibSpotifyPlatformImports.h"

@class SPSession;

/** The default search page size. Used if no page size is specified. */
static SInt32 const kSPSearchDefaultSearchPageSize = 75;
/** The "do not search" page size. Used if you don't want to search for a particular kind of result. */
static SInt32 const kSPSearchDoNotSearchPageSize = 0;

/** This class performs a search on the Spotify catalogue available to the given session, returning tracks, albums and artists. */
@interface SPSearch : NSObject <SPAsyncLoading>

///----------------------------
/// @name Creating and Initializing Searches
///----------------------------

/** Creates a new SPSearch with the default page size from the given Spotify search URL. 
 
 This convenience method is simply returns a new, autoreleased SPSearch
 object. No caching is performed.
 
 @warning If you pass in an invalid search URL (i.e., any URL not
 starting `spotify:search:`, this method will return `nil`.
 
 @warning The search query will be sent to the Spotify search service
 immediately. Be sure you want to perform the search before creating the object!
 
 @param searchURL The search URL to create an SPSearch for.
 @param aSession The SPSession the track should exist in.
 @return Returns the created SPSearch object. 
 */
+(SPSearch *)searchWithURL:(NSURL *)searchURL inSession:(SPSession *)aSession;

/** Creates a new SPSearch with the default page size for the given query.
 
 This convenience method is simply returns a new, autoreleased SPSearch
 object. No caching is performed.
 
 @warning The search query will be sent to the Spotify search service
 immediately. Be sure you want to perform the search before creating the object!
 
 @param searchQuery The search query to create an SPSearch for.
 @param aSession The SPSession the track should exist in.
 @return Returns the created SPSearch object. 
 */
+(SPSearch *)searchWithSearchQuery:(NSString *)searchQuery inSession:(SPSession *)aSession;

/** Creates a new "live search" SPSearch with the default page size for the given query.
 
 Live searches should be used when displaying "live search" UI — for example, a search suggestion
 UI as the user is typing into a search field. This convenience method is simply returns a new, 
 autoreleased SPSearch object. No caching is performed.
 
 @warning The search query will be sent to the Spotify search service
 immediately. Be sure you want to perform the search before creating the object!
 
 @param searchQuery The search query to create an SPSearch for.
 @param aSession The SPSession the track should exist in.
 @return Returns the created SPSearch object. 
 */
+(SPSearch *)liveSearchWithSearchQuery:(NSString *)searchQuery inSession:(SPSession *)aSession;

/** Initializes a new SPSearch with the default page size from the given Spotify search URL. 

 @warning If you pass in an invalid search URL (i.e., any URL not
 starting `spotify:search:`, this method will return `nil`.
 
 @param searchURL The search URL to create an SPSearch for.
 @param aSession The SPSession the track should exist in.
 @return Returns the created SPSearch object. 
 */
-(id)initWithURL:(NSURL *)searchURL 
	   inSession:(SPSession *)aSession;

/** Initializes a new SPSearch from the given Spotify search URL. 
 
 @warning If you pass in an invalid search URL (i.e., any URL not
 starting `spotify:search:`, this method will return `nil`.
 
 @warning The search query will be sent to the Spotify search service
 immediately. Be sure you want to perform the search before creating the object!
 
 @param searchURL The search URL to create an SPSearch for.
 @param size The number of results to request per page of results.
 @param aSession The SPSession the track should exist in.
 @return Returns the created SPSearch object. 
 */
-(id)initWithURL:(NSURL *)searchURL
		pageSize:(NSInteger)size
	   inSession:(SPSession *)aSession;

/** Initializes a new SPSearch with the default page size for the given query. 
 
 @warning The search query will be sent to the Spotify search service
 immediately. Be sure you want to perform the search before creating the object!
 
 @param searchString The search query to create an SPSearch for.
 @param aSession The SPSession the track should exist in.
 @return Returns the created SPSearch object. 
 */
-(id)initWithSearchQuery:(NSString *)searchString
			   inSession:(SPSession *)aSession;

/** Initializes a new SPSearch with the default page size for the given query and type.
 
 If you are displaying "live search" UI — for example, a search suggestion
 UI as the user is typing into a search field — pass `SP_SEARCH_SUGGEST` to `type` 
 for more appropriate results.
 
 @warning The search query will be sent to the Spotify search service
 immediately. Be sure you want to perform the search before creating the object!
 
 @param searchString The search query to create an SPSearch for.
 @param aSession The SPSession the track should exist in.
 @param type The type of search to perform, either `SP_SEARCH_STANDARD` or `SP_SEARCH_SUGGEST`.
 @return Returns the created SPSearch object. 
 */
-(id)initWithSearchQuery:(NSString *)searchString
			   inSession:(SPSession *)aSession
					type:(sp_search_type)type;

/** Initializes a new SPSearch for the given query. 
 
 @warning The search query will be sent to the Spotify search service
 immediately. Be sure you want to perform the search before creating the object!
 
 @param searchString The search query to create an SPSearch for.
 @param size The number of results to request per page of results.
 @param aSession The SPSession the track should exist in.
 @return Returns the created SPSearch object. 
 */
-(id)initWithSearchQuery:(NSString *)searchString
				pageSize:(NSInteger)size
			   inSession:(SPSession *)aSession;

/** Initializes a new SPSearch for the given query. 
 
 If you are displaying "live search" UI — for example, a search suggestion
 UI as the user is typing into a search field — pass `SP_SEARCH_SUGGEST` to `type` 
 for more appropriate results.

 @warning The search query will be sent to the Spotify search service
 immediately. Be sure you want to perform the search before creating the object!
 
 @param searchString The search query to create an SPSearch for.
 @param size The number of results to request per page of results.
 @param aSession The SPSession the track should exist in.
 @param type The type of search to perform, either `SP_SEARCH_STANDARD` or `SP_SEARCH_SUGGEST`.
 @return Returns the created SPSearch object. 
 */
-(id)initWithSearchQuery:(NSString *)searchString
				pageSize:(NSInteger)size
			   inSession:(SPSession *)aSession
					type:(sp_search_type)type;

///----------------------------
/// @name Requesting More Results
///----------------------------

/** Request an extra page of albums from the Spotify search service. 
 
 The albums property will be updated when new results are returned.
 
 @warning If you want to request more than just albums, use 
 `-addPageForArtists:albums:tracks:playlists:` for better performance.
 
 @return Returns `YES` if a search request was created, `NO` if there are no more results to fetch
 or if a search is already in progress.
 */
-(BOOL)addAlbumPage;

/** Request an extra page of artists from the Spotify search service. 
 
  The artists property will be updated when new results are returned.
 
 @warning If you want to request more than just artists, use 
 `-addPageForArtists:albums:tracks:playlists:` for better performance.
 
 @return Returns `YES` if a search request was created, `NO` if there are no more results to fetch
 or if a search is already in progress.
 */
-(BOOL)addArtistPage;

/** Request an extra page of tracks from the Spotify search service. 
 
  The tracks property will be updated when new results are returned.
 
 @warning If you want to request more than just tracks, use 
 `-addPageForArtists:albums:tracks:playlists:` for better performance.
 
 @return Returns `YES` if a search request was created, `NO` if there are no more results to fetch
 or if a search is already in progress.
 */
-(BOOL)addTrackPage;

/** Request an extra page of playlists from the Spotify search service. 
 
 The playlists property will be updated when new results are returned.
 
 @warning If you want to request more than just playlists, use 
 `-addPageForArtists:albums:tracks:playlists:` for better performance.
 
 @return Returns `YES` if a search request was created, `NO` if there are no more results to fetch
 or if a search is already in progress.
 */
-(BOOL)addPlaylistPage;

/** Request an extra page of tracks, albums, tracks and playlists from the Spotify search service. 
 
  The albums, artists, tracks and playlists properties will be updated as appropriate when new results are returned.
 
 @param searchArtist Set to `YES` to request more artist results.
 @param searchAlbum Set to `YES` to request more album results.
 @param searchTrack Set to `YES` to request more track results.
 @param searchPlaylist Set to `YES` to request more playlist results. 
 @return Returns `YES` if a search request was created, `NO` if there are no more results to fetch 
  or if a search is already in progress.
 */
-(BOOL)addPageForArtists:(BOOL)searchArtist albums:(BOOL)searchAlbum tracks:(BOOL)searchTrack playlists:(BOOL)searchPlaylist;

///----------------------------
/// @name Results
///----------------------------

/** Returns a "suggested" search query provided by the search service, or `nil` if the search has not loaded or there is no suggested query.
 
 This can be presented to the user as a "did you mean?" suggestion.
 */
@property (nonatomic, readonly, copy) NSString *suggestedSearchQuery;

/** Returns `YES` if the search service has indicated there are no more album results to find. */
@property (nonatomic, readonly) BOOL hasExhaustedAlbumResults;

/** Returns `YES` if the search service has indicated there are no more artist results to find. */
@property (nonatomic, readonly) BOOL hasExhaustedArtistResults;

/** Returns `YES` if the search service has indicated there are no more track results to find. */
@property (nonatomic, readonly) BOOL hasExhaustedTrackResults;

/** Returns `YES` if the search service has indicated there are no more playlist results to find. */
@property (nonatomic, readonly) BOOL hasExhaustedPlaylistResults;

/** Returns the album results of the search, or `nil` if the search has not loaded or there are no album results. */
@property (nonatomic, readonly, strong) NSArray *albums;

/** Returns the artist results of the search, or `nil` if the search has not loaded or there are no artist results. */
@property (nonatomic, readonly, strong) NSArray *artists;

/** Returns the track results of the search, or `nil` if the search has not loaded or there are no track results. */
@property (nonatomic, readonly, strong) NSArray *tracks;

/** Returns the playlist results of the search, or `nil` if the search has not loaded or there are no playlist results. */
@property (nonatomic, readonly, strong) NSArray *playlists;

///----------------------------
/// @name Properties
///----------------------------

/** Returns an NSError indicating the search failure reason, or `nil` if there was no error. */
@property (nonatomic, readonly, copy) NSError *searchError;

/** Returns `NO` if a search is currently in progress, or `YES` if the search is complete (or has failed). */
@property (nonatomic, readonly, getter = isLoaded) BOOL loaded;

/** Returns the search query for this search. */
@property (nonatomic, readonly, copy) NSString *searchQuery;

/** Returns the session the search is being performed in. */
@property (nonatomic, readonly, strong) SPSession *session;

/** Returns the Spotify URI of the search, for example: `spotify:search:rick+astley` */
@property (nonatomic, readonly, copy) NSURL *spotifyURL;

/** Returns the type of search, either `SP_SEARCH_STANDARD` or `SP_SEARCH_SUGGEST`. */
@property (nonatomic, readonly) sp_search_type searchType;



@end
