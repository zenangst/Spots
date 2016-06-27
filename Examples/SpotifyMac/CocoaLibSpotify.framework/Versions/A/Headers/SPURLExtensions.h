//
//  SPURLExtensions.h
//  CocoaLibSpotify
//
//  Created by Daniel Kennett on 3/26/11.
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

/** Adds convenience methods to NSURL for working with Spotify URLs. */

#import <Foundation/Foundation.h>
#import "CocoaLibSpotifyPlatformImports.h"

@interface NSURL (SPURLExtensions)

/** Convert an sp_link from the C LibSpotify API into an NSURL object. 
 
 @param link The sp_link to convert.
 @return Returns the created NSURL, or `nil` if the link is invalid.
 */
+(NSURL *)urlWithSpotifyLink:(sp_link *)link;

/** Create an sp_link for the C LibSpotify API from an NSURL object.
 
 @return The created sp_link, or NULL if the URL is not a valid Spotify URL.
 If not NULL, this _must_ be freed with `sp_link_release()` when you're done.
 */
-(sp_link *)createSpotifyLink;

/** Returns the sp_linktype for the C LibSpotify API.
 
 Possible values:
 
 - SP_LINKTYPE_INVALID
 - SP_LINKTYPE_TRACK
 - SP_LINKTYPE_ALBUM
 - SP_LINKTYPE_ARTIST
 - SP_LINKTYPE_SEARCH
 - SP_LINKTYPE_PLAYLIST 
 - SP_LINKTYPE_PROFILE 
 - SP_LINKTYPE_STARRED 
 - SP_LINKTYPE_LOCALTRACK
 */
-(sp_linktype)spotifyLinkType;

+(NSString *)urlDecodedStringForString:(NSString *)encodedString;
+(NSString *)urlEncodedStringForString:(NSString *)plainOldString;

@end
