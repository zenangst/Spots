//
//  SPArtistBrowse.h
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

/** Represents an "artist browse" of an artist on the Spotify service. 
 
 An "artist browse" fetches detailed information about an artist from the Spotify 
 service, including a biography, portrait images, related artists and a list of 
 their tracks and albums.
 
 Artist or album browses are required for certain SPTrack metadata to be available - 
 see the SPTrack documentation for details. 
 */

#import <Foundation/Foundation.h>
#import "CocoaLibSpotifyPlatformImports.h"

@class SPArtist;
@class SPSession;
@class SPImage;

@interface SPArtistBrowse : NSObject <SPAsyncLoading>

///----------------------------
/// @name Creating and Initializing Artist Browses
///----------------------------

/** Creates an SPArtistBrowse from the given SPArtist. 
 
 This convenience method is simply returns a new, autoreleased SPArtistBrowse
 object. No caching is performed.

 @warning It is strongly recommended that you don't use `SP_ARTISTBROWSE_FULL`
 as the browse type, as this will download metadata for every single album and track from the given
 artist, which is both a lengthy and memory-intensive operation. Please use 
 `SP_ARTISTBROWSE_NO_TRACKS` (which downloads artist information, their albums and top tracks) or
 `SP_ARTISTBROWSE_NO_ALBUMS` (which only downloads artist information and top tracks) instead.
 
 @warning If you pass in an invalid artist URL (i.e., any URL not
 starting `spotify:artist:`, this method will return `nil`.
 
 @param anArtist The SPArtist to make an SPArtistBrowse for.
 @param aSession The SPSession the browse should exist in.
 @param browseMode The type of artist browse to perform.
 @return Returns the created SPArtistBrowse object. 
 */
+(SPArtistBrowse *)browseArtist:(SPArtist *)anArtist inSession:(SPSession *)aSession type:(sp_artistbrowse_type)browseMode;

/** Creates an SPArtistBrowse from the given artist URL. 
 
 This convenience method is simply returns a new, autoreleased SPArtistBrowse
 object. No caching is performed.
 
 @warning It is strongly recommended that you don't use `SP_ARTISTBROWSE_FULL`
 as the browse type, as this will download metadata for every single album and track from the given
 artist, which is both a lengthy and memory-intensive operation. Please use 
 `SP_ARTISTBROWSE_NO_TRACKS` (which downloads artist information, their albums and top tracks) or
 `SP_ARTISTBROWSE_NO_ALBUMS` (which only downloads artist information and top tracks) instead.
 
 @warning If you pass in an invalid artist URL (i.e., any URL not
 starting `spotify:artist:`, this method will return `nil`.
 
 @param artistURL The artist URL to make an SPArtistBrowse for.
 @param aSession The SPSession the browse should exist in.
 @param browseMode The type of artist browse to perform.
 @param block The block to be called with the created SPArtistBrowse object. 
 */
+(void)browseArtistAtURL:(NSURL *)artistURL inSession:(SPSession *)aSession type:(sp_artistbrowse_type)browseMode callback:(void (^)(SPArtistBrowse *artistBrowse))block;

/** Initializes a new SPArtistBrowse from the given SPArtist. 
 
 @warning It is strongly recommended that you don't use `SP_ARTISTBROWSE_FULL`
 as the browse type, as this will download metadata for every single album and track from the given
 artist, which is both a lengthy and memory-intensive operation. Please use 
 `SP_ARTISTBROWSE_NO_TRACKS` (which downloads artist information, their albums and top tracks) or
 `SP_ARTISTBROWSE_NO_ALBUMS` (which only downloads artist information and top tracks) instead.
 
 @warning If you pass in an invalid artist URL (i.e., any URL not
 starting `spotify:artist:`, this method will return `nil`.
 
 @param anArtist The SPArtist to make an SPArtistBrowse for.
 @param aSession The SPSession the browse should exist in.
 @param browseMode The type of artist browse to perform.
 @return Returns the created SPArtistBrowse object. 
 */
-(id)initWithArtist:(SPArtist *)anArtist inSession:(SPSession *)aSession type:(sp_artistbrowse_type)browseMode;

///----------------------------
/// @name Properties
///----------------------------

/** Returns `YES` if the artist metadata has finished loading. */ 
@property (nonatomic, readonly, getter=isLoaded) BOOL loaded;

/** Returns the error that occurred during loading, or `nil` if no error occurred. */
@property (nonatomic, readonly, copy) NSError *loadError;

/** Returns the session the artist's metadata is loaded in. */
@property (nonatomic, readonly, strong) SPSession *session;

///----------------------------
/// @name Metadata
///----------------------------

/** Returns a list of albums by this artist, or `nil` if the metadata isn't loaded yet. */
@property (nonatomic, readonly, strong) NSArray *albums;

/** Returns the browse operation's artist. */
@property (nonatomic, readonly, strong) SPArtist *artist;

/** Returns the artist's biography, or `nil` if the metadata isn't loaded yet. */
@property (nonatomic, readonly, copy) NSString *biography;

/** Returns the first artist portrait image, or `nil` if the metadata isn't loaded yet or there are no images. */
@property (nonatomic, readonly, strong) SPImage *firstPortrait;

/** Returns the artist's portrait images, or `nil` if the metadata isn't loaded yet. */
@property (nonatomic, readonly, strong) NSArray *portraits;

/** Returns a list of related artists for this artist, or `nil` if the metadata isn't loaded yet. */
@property (nonatomic, readonly, strong) NSArray *relatedArtists;

/** Returns a list of tracks by this artist, or `nil` if the metadata isn't loaded yet. 
 @deprecated 
 @warning This property is deprecated.
 */
@property (nonatomic, readonly, strong) NSArray *tracks;

/** Returns a list of "top hit" tracks by this artist, or `nil` if the metadata isn't loaded yet. */
@property (nonatomic, readonly, strong) NSArray *topTracks;

@end
