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
#import "SPTJSONDecoding.h"
#import "SPTPartialObject.h"
#import "SPTTypes.h"
#import "SPTPartialAlbum.h"

/** Represents a "partial" track on the Spotify service. You can promote this
 to a full track object using `SPTTrack`.
 
 API Model: https://developer.spotify.com/web-api/object-model/#track-object-simplified
 
 API Docs: https://developer.spotify.com/web-api/track-endpoints/
 */
@interface SPTPartialTrack : SPTJSONObjectBase<SPTPartialObject, SPTTrackProvider>





///----------------------------
/// @name Properties
///----------------------------

/** The id of the track. */
@property (nonatomic, readonly, copy) NSString *identifier;

/** The name of the track. */
@property (nonatomic, readonly, copy) NSString *name;

/** A playable Spotify URI for this track. */
@property (nonatomic, readonly, copy) NSURL *playableUri;

/** The HTTP open.spotify.com URL of the track. */
@property (nonatomic, readonly, copy) NSURL *sharingURL;

/** The duration of the track. */
@property (nonatomic, readonly) NSTimeInterval duration;

/** The artists of the track, as `SPTPartialArtist` objects. */
@property (nonatomic, readonly, copy) NSArray *artists;

/** The disc number of the track. I.e., if it's the first disc on the album this will be `1`. */
@property (nonatomic, readonly) NSInteger discNumber;

/** Returns `YES` if the track is flagged as explicit, otherwise `NO`. */
@property (nonatomic, readonly) BOOL flaggedExplicit;

/** Returns `YES` if the track is flagged as playable, otherwise `NO`, if no market is passed to the api call, this will default to `YES`. */
@property (nonatomic, readonly) BOOL isPlayable;

/** Returns `YES` if the track has a playable status, only available if market passed to the api call. */
@property (nonatomic, readonly) BOOL hasPlayable;

/** An array of ISO 3166 country codes in which the album is available. */
@property (nonatomic, readonly, copy) NSArray *availableTerritories;

/** The HTTP URL of a 30-second preview MP3 of the track. */
@property (nonatomic, readonly, copy) NSURL *previewURL;

/** The track number of the track. I.e., if it's the first track on the album this will be `1`. */
@property (nonatomic, readonly) NSInteger trackNumber;

/** The album this track belongs to. */
@property (nonatomic, readonly, strong) SPTPartialAlbum *album;



///-------------------------------
/// @name Response parsing methods
///-------------------------------

/**
 Convert a parsed HTTP response into an SPTPartialTrack object
 
 @param decodedObject The decoded JSON object structure.
 @param error An optional pointer to an `NSError` that will receive the error code if operation failed.
 */
+ (instancetype)partialTrackFromDecodedJSON:(id)decodedObject
									  error:(NSError **)error;


@end
