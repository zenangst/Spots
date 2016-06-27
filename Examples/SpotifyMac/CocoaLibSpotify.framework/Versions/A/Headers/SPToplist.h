//
//  SPToplist.h
//  CocoaLibSpotify
//
//  Created by Daniel Kennett on 4/28/11.
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

/** Represents toplist, or a list of tracks based on popularity, on the Spotify service. 
 
 There are two kinds of toplists - user toplists and locale toplists. A user toplist gives a 
 user's most popular tracks, artists and albums if they've enabled Spotify social. A locale 
 toplist gives most popular tracks, artists and albums by region (or globally), and can 
 be seen as a popularity chart for that region.
 */

#import <Foundation/Foundation.h>
#import "CocoaLibSpotifyPlatformImports.h"

@class SPUser;
@class SPSession;

@interface SPToplist : NSObject <SPAsyncLoading>

///----------------------------
/// @name Creating and Initializing Toplists
///----------------------------

/** Create a global toplist.
 
 This convenience method is simply returns a new, autoreleased SPToplist
 object. No caching is performed.
 
 @param aSession The session the toplist should be created in.
 @return Returns the created toplist.
 */
+(SPToplist *)globalToplistInSession:(SPSession *)aSession;

/** Create a regional toplist.
 
 This convenience method is simply returns a new, autoreleased SPToplist
 object. No caching is performed.
 
 @param toplistLocale The locale to create a toplist for. This must be a locale Spotify is currently available in to get anything meaningful.
 @param aSession The session the toplist should be created in.
 @return Returns the created toplist.
 */
+(SPToplist *)toplistForLocale:(NSLocale *)toplistLocale inSession:(SPSession *)aSession;

/** Create a user toplist.
 
 This convenience method is simply returns a new, autoreleased SPToplist
 object. No caching is performed.
 
 @param user The user name to create a toplist for. This must be a user who has enabled Spotify social to get anything meaningful.
 @param aSession The session the toplist should be created in.
 @return Returns the created toplist.
 */
+(SPToplist *)toplistForUserWithName:(NSString *)user inSession:(SPSession *)aSession;

/** Create toplist for the currently logged in user.
 
 This convenience method is simply returns a new, autoreleased SPToplist
 object. No caching is performed.
 
 @param aSession The session the toplist should be created in.
 @return Returns the created toplist.
 */
+(SPToplist *)toplistForCurrentUserInSession:(SPSession *)aSession;

/** Initialize a locale toplist. 
 
 @param toplistLocale The locale to create a toplist for, or `nil` for the global toplist. This must be a locale Spotify is currently available in to get anything meaningful.
 @param aSession The session the toplist should be created in.
 @return Returns the created toplist.
 */
-(id)initLocaleToplistWithLocale:(NSLocale *)toplistLocale inSession:(SPSession *)aSession;

/** Initialize a user toplist. 
 
 @param user The user name to create a toplist for, or `nil` for the currently logged-in user. This must be a user who has enabled Spotify social to get anything meaningful.
 @param aSession The session the toplist should be created in.
 @return Returns the created toplist.
 */
-(id)initUserToplistWithUsername:(NSString *)user inSession:(SPSession *)aSession;

///----------------------------
/// @name Properties
///----------------------------

/** Returns the albums in the toplist in descending order of popularity. */
@property (nonatomic, readonly, strong) NSArray *albums;

/** Returns the artists in the toplist in descending order of popularity. */
@property (nonatomic, readonly, strong) NSArray *artists;

/** Returns `YES` if the toplist has finished loading. */ 
@property (nonatomic, readonly, getter=isLoaded) BOOL loaded;

/** Returns the error that occurred during loading, or `nil` if no error occurred. */
@property (nonatomic, readonly, copy) NSError *loadError;

/** Returns the locale of the toplist, if the toplist is a locale toplist. */
@property (nonatomic, readonly, strong) NSLocale *locale;

/** Returns the tracks in the toplist in descending order of popularity. */
@property (nonatomic, readonly, strong) NSArray *tracks;

/** Returns the session the toplist is loaded in. */
@property (nonatomic, readonly, strong) SPSession *session;

/** Returns the username of the toplist, if the toplist is a user toplist. */
@property (nonatomic, readonly, copy) NSString *username;

@end
