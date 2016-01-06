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

/// Defines the various types albums can be in relation to a given artist.
typedef NS_ENUM(NSUInteger, SPTAlbumType) {
	/// Specifies that the given album is a "standard" album.
	SPTAlbumTypeAlbum,
	/// Specifies that the given album is a single.
	SPTAlbumTypeSingle,
	/// Specifies that the given album is a compilation album.
	SPTAlbumTypeCompilation,
	/// Specifies that the given album is an "appears on" album that the artist appears on, but didn't author.
	SPTAlbumTypeAppearsOn
};

@class SPTImage;

/** Represents a "partial" album on the Spotify service. You can promote this to a full album object using `SPTAlbum`.

 API Model: https://developer.spotify.com/web-api/object-model/#album-object-simplified
 */
@interface SPTPartialAlbum : SPTJSONObjectBase <SPTPartialObject>





///----------------------------
/// @name Properties
///----------------------------

/** The id of the track. */
@property (nonatomic, readonly, copy) NSString *identifier;

/** The name of the album. */
@property (nonatomic, readonly, copy) NSString *name;

/** The Spotify URI of the album. */
@property (nonatomic, readonly, copy) NSURL *uri;

/** A playable Spotify URI for this album. */
@property (nonatomic, readonly, copy) NSURL *playableUri;

/** The HTTP open.spotify.com URL of the album. */
@property (nonatomic, readonly, copy) NSURL *sharingURL;

/** Returns a list of album covers in various sizes, as `SPTImage` objects. */
@property (nonatomic, readonly, copy) NSArray *covers;

/** Convenience method that returns the smallest available cover image. */
@property (nonatomic, readonly) SPTImage *smallestCover;

/** Convenience method that returns the largest available cover image. */
@property (nonatomic, readonly) SPTImage *largestCover;

/** Returns the album type of this album. */
@property (nonatomic, readonly) SPTAlbumType type;

/** An array of ISO 3166 country codes in which the album is available. */
@property (nonatomic, readonly, copy) NSArray *availableTerritories;





///------------------------------
/// @name Parsers / Deserializers
///------------------------------

+ (instancetype)partialAlbumFromDecodedJSON:(id)decodedObject
									  error:(NSError **)error;

@end
