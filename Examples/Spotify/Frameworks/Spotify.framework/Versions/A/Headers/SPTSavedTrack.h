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
#import "SPTTrack.h"

/** This class represents a track in the Your Music Library.

 API Model: https://developer.spotify.com/web-api/object-model/#saved-track-object
 */
@interface SPTSavedTrack : SPTTrack <SPTJSONObject>

///----------------------------
/// @name Properties
///----------------------------

/** The date when the track was saved. */
@property (nonatomic, readonly, copy) NSDate *addedAt;

@end
