//
//  SPAlbumBrowse.h
//  CocoaLibSpotify
//
//  Created by Daniel Kennett on 4/24/11.
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

/** Represents an "album browse" of an album on the Spotify service. 
 
 An "album browse" fetches detailed information about an album from the Spotify 
 service, including a review, copyright information and a list of the album's tracks.
 
 Artist or album browses are required for certain SPTrack metadata to be available - 
 see the SPTrack documentation for details. 
 */

#import <Foundation/Foundation.h>
#import "CocoaLibSpotifyPlatformImports.h"

@class SPAlbum;
@class SPSession;
@class SPArtist;

@interface SPAlbumBrowse : NSObject <SPAsyncLoading>

///----------------------------
/// @name Creating and Initializing Album Browses
///----------------------------

/** Creates an SPAlbumBrowse from the given SPAlbum.
 
 This convenience method is simply returns a new, autoreleased SPAlbumBrowse
 object. No caching is performed.
 
 @param anAlbum The SPAlbum to make an SPAlbumBrowse for.
 @param aSession The SPSession the browse should exist in.
 @return Returns the created SPAlbumBrowse object. 
 */
+(SPAlbumBrowse *)browseAlbum:(SPAlbum *)anAlbum inSession:(SPSession *)aSession;

/** Creates an SPAlbumBrowse from the given album URL. 
 
 This convenience method is simply returns a new, autoreleased SPAlbumBrowse
 object. No caching is performed.
 
 @warning If you pass in an invalid album URL (i.e., any URL not
 starting `spotify:album:`, this method will return `nil`.
 
 @param albumURL The album URL to make an SPAlbumBrowse for.
 @param aSession The SPSession the browse should exist in.
 @param block The block to be called with the created SPAlbumBrowse object. 
 */
+(void)browseAlbumAtURL:(NSURL *)albumURL inSession:(SPSession *)aSession callback:(void (^)(SPAlbumBrowse *albumBrowse))block;

/** Initializes a new SPAlbumBrowse from the given SPAlbum. 
 
 @param anAlbum The SPAlbum to make an SPAlbumBrowse for.
 @param aSession The SPSession the browse should exist in.
 @return Returns the created SPAlbumBrowse object. 
 */
-(id)initWithAlbum:(SPAlbum *)anAlbum inSession:(SPSession *)aSession;

///----------------------------
/// @name Properties
///----------------------------

/** Returns `YES` if the album metadata has finished loading. */ 
@property (nonatomic, readonly, getter=isLoaded) BOOL loaded;

/** Returns the error that occurred during loading, or `nil` if no error occurred. */
@property (nonatomic, readonly, copy) NSError *loadError;

/** Returns the session the album's metadata is loaded in. */
@property (nonatomic, readonly, strong) SPSession *session;

///----------------------------
/// @name Metadata
///----------------------------

/** Returns the browse operation's album. */
@property (nonatomic, readonly, strong) SPAlbum *album;

/** Returns the album's artist, or `nil` if the metadata isn't loaded yet. */
@property (nonatomic, readonly, strong) SPArtist *artist;

/** Returns the album's copyrights as an array of NSString, or `nil` if the metadata isn't loaded yet. */
@property (nonatomic, readonly, strong) NSArray *copyrights;

/** Returns the album's review, or `nil` if the metadata isn't loaded yet. */
@property (nonatomic, readonly, copy) NSString *review;

/** Returns the album's tracks, or `nil` if the metadata isn't loaded yet. */
@property (nonatomic, readonly, strong) NSArray *tracks;

@end
