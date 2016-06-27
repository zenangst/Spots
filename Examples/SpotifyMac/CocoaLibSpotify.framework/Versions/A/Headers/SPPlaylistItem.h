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

/** This class represents an item in a playlist, be it a track, artist, album or something else. */

#import <Foundation/Foundation.h>
#import "CocoaLibSpotifyPlatformImports.h"

@class SPPlaylist;
@class SPUser;

@interface SPPlaylistItem : NSObject {
	BOOL _unread;
}

///----------------------------
/// @name Querying The Item
///----------------------------

/** Returns the `Class` of the item this object represents. */
@property (nonatomic, unsafe_unretained, readonly) Class itemClass;

/** Returns the Spotify URI of the item this object represents. */
@property (nonatomic, readonly) NSURL *itemURL;

/** Returns the `sp_linktype` of the item this object represents. */
@property (nonatomic, readonly) sp_linktype itemURLType;

/** Returns the item this object represents.
 
 The item is typically a track, artist, album or playlist.
 */
@property (nonatomic, readonly, strong) id <SPPlaylistableItem, SPAsyncLoading> item;

///----------------------------
/// @name Metadata
///----------------------------

/** Returns the creator of the item this object represents. 
 
 This value is used in the user's inbox playlist and playlists that are or
 were collaborative, and represents the user that added the track to the
 playlist.
 */
@property (nonatomic, readonly, strong) SPUser *creator;

/** Returns the date that the item this object represents was added to the playlist. 
 
 This value is used in the user's inbox playlist and playlists that are or
 were collaborative, and represents the date and time the track was
 added to the playlist.
 */
@property (nonatomic, readonly, copy) NSDate *dateAdded;

/** Returns the message attached to the item this object represents. 
 
 This value is used in the user's inbox playlist and reflects the message
 the sender attached to the item when sending it.
 */
@property (nonatomic, readonly, copy) NSString *message;

/** Returns the "unread" status of the item this object represents. 
 
 This value is only normally used in the user's inbox playlist. In the
 Spotify client, unread tracks have a blue dot by them in the inbox.
 */
@property (nonatomic, readwrite, getter = isUnread) BOOL unread;

@end
