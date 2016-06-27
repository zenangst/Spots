//
//  SPPlaylistContainer.h
//  CocoaLibSpotify
//
//  Created by Daniel Kennett on 2/19/11.
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

/** This class represents a list of playlists. In practice, it is only found when dealing with a user's playlist 
 list and can't be created manually. */

#import <Foundation/Foundation.h>
#import "CocoaLibSpotifyPlatformImports.h"

@class SPUser;
@class SPSession;
@class SPPlaylist;
@class SPPlaylistFolder;

@interface SPPlaylistContainer : NSObject <SPAsyncLoading, SPDelayableAsyncLoading>

///----------------------------
/// @name Properties
///----------------------------

/** Returns the opaque structure used by the C LibSpotify API. 
 
 @warning This method *must* be called on the libSpotify thread. See the
 "Threading" section of the library's readme for more information.
 
 @warning This should only be used if you plan to directly use the 
 C LibSpotify API. The behaviour of CocoaLibSpotify is undefined if you use the C
 API directly on items that have CocoaLibSpotify objects associated with them. 
 */
@property (nonatomic, readonly, assign) sp_playlistcontainer *container;

/* Returns `YES` if the playlist container has loaded all playlist and folder data, otherwise `NO`. */
@property (nonatomic, readonly, getter=isLoaded) BOOL loaded;

/** Returns the owner of the playlist list. */
@property (nonatomic, readonly, strong) SPUser *owner;

/** Returns an array of SPPlaylist and/or SPPlaylistFolders representing the owner's playlist list. */
@property (nonatomic, readonly, strong) NSArray *playlists;

/** Returns a flattened array of the `SPPlaylist` objects in the playlists tree, without folders. 
 
 This array is computed each time this method is called, so be careful if you're in a performance-critical section.
*/
-(NSArray *)flattenedPlaylists;

/** Returns the session the list is loaded in. */
@property (nonatomic, readonly, assign) __unsafe_unretained SPSession *session;

///----------------------------
/// @name Working with Playlists and Folders
///----------------------------

/** Create a new, empty folder. 
 
 @param name The name of the new folder.
 @param block The callback block to call when the operation is complete.
 */
-(void)createFolderWithName:(NSString *)name callback:(void (^)(SPPlaylistFolder *createdFolder, NSError *error))block;

/** Create a new, empty playlist. 
 
 @param name The name of the new playlist. Must be shorter than 256 characters and not consist of only whitespace.
 @param block The callback block to call when the operation is complete.
 */
-(void)createPlaylistWithName:(NSString *)name callback:(void (^)(SPPlaylist *createdPlaylist))block;

/** Remove the given playlist or folder. 
 
 @param playlistOrFolder The Playlist or Folder to remove.
 @param block The callback block to execute when the operation has completed.
 */
-(void)removeItem:(id)playlistOrFolder callback:(SPErrorableOperationCallback)block;

/** Move a playlist or folder to another location in the list. 
 
 @warning This operation can fail, for example if you give invalid indexes or try to move 
 a folder into itself. Please make sure you check the result in the completion callback.
 
 @param playlistOrFolder A playlist or folder to move.
 @param newIndex The desired destination index in the destination parent folder (or root list if there's no parent).
 @param aParentFolderOrNil The new parent folder, or nil if there is no parent.
 @param block The callback block to call when the operation is complete.
 */
-(void)moveItem:(id)playlistOrFolder
		toIndex:(NSUInteger)newIndex 
	ofNewParent:(SPPlaylistFolder *)aParentFolderOrNil
	   callback:(SPErrorableOperationCallback)block;

/** Subscribe to the given playlist.

 The operation will fail if the given playlist is owned by the current user or is 
 already subscribed (i.e., you can't subscribe to a playlist twice). To unsubscibe,
 user `-[SPPlaylistContainer removeItem:callback:]`.

 @param playlist The Playlist to subscribe to.
 @param block The callback block to execute when the operation has completed.
 */
-(void)subscribeToPlaylist:(SPPlaylist *)playlist callback:(SPErrorableOperationCallback)block;

@end
