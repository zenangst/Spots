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

/** Represents a "partial" artist on the Spotify service. You can promote this
 to a full artist object using `SPTArtist`.
 
 API Model: https://developer.spotify.com/web-api/object-model/#artist-object-simplified
 */
@interface SPTPartialArtist : SPTJSONObjectBase<SPTPartialObject>





///-----------------
/// @name Properties
///-----------------

/** The id of the artist. */
@property (nonatomic, readonly, copy) NSString *identifier;

/** A playable Spotify URI for this artist. */
@property (nonatomic, readonly, copy) NSURL *playableUri;

/** The HTTP open.spotify.com URL of the artist. */
@property (nonatomic, readonly, copy) NSURL *sharingURL;





///------------------------------
/// @name Parsers / Deserializers
///------------------------------

+ (instancetype)partialArtistFromDecodedJSON:(id)decodedObject
									   error:(NSError **)error;

@end
