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
#import "SPTJSONDecoding.h"
#import "SPTTypes.h"
#import "SPTImage.h"

@class SPTUser;

/** Represents a "partial" playlist on the Spotify service. You can promote this
 to a full playlist object using `SPTPlaylistSnapshot`.

 API Model: https://developer.spotify.com/web-api/object-model/#playlist-object-simplified
 
 Playlist Guide: https://developer.spotify.com/web-api/working-with-playlists/
 */
@interface SPTPartialPlaylist : SPTJSONObjectBase<SPTPartialObject, SPTTrackProvider>





///----------------------------
/// @name Properties
///----------------------------

/** The name of the playlist. */
@property (nonatomic, readonly, copy) NSString *name;

/** The Spotify URI of the playlist. */
@property (nonatomic, readonly, copy) NSURL *uri;

/** The playable Spotify URI for the playlist. */
@property (nonatomic, readonly, copy) NSURL *playableUri;

/** The owner of the playlist. */
@property (nonatomic, readonly) SPTUser *owner;

/** `YES` if the playlist is collaborative (i.e., can be modified by anyone), otherwise `NO`. */
@property (nonatomic, readonly) BOOL isCollaborative;

/** `YES` if the playlist is public (i.e., can be seen by anyone), otherwise `NO`. */
@property (nonatomic, readonly) BOOL isPublic;

/** The number of tracks in the playlist. */
@property (nonatomic, readonly) NSUInteger trackCount;

/** Returns a list of playlist image in various sizes, as `SPTImage` objects.
 
 Will be `nil` if the playlist doesn't have a custom image.
 */
@property (nonatomic, readonly, copy) NSArray *images;

/** Convenience method that returns the smallest available playlist image.
 
 Will be `nil` if the playlist doesn't have a custom image.
 */
@property (nonatomic, readonly) SPTImage *smallestImage;

/** Convenience method that returns the largest available playlist image.
 
 Will be `nil` if the playlist doesn't have a custom image.
 */
@property (nonatomic, readonly) SPTImage *largestImage;




///------------------------------
/// @name Parsers / Deserializers
///------------------------------

+ (instancetype)partialPlaylistFromDecodedJSON:(id)decodedObject
										 error:(NSError **)error;

@end
