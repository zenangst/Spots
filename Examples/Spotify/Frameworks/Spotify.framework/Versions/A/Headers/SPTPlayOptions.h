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

/** This object contains information about how to start playback
 */
@interface SPTPlayOptions : NSObject

/** Which track to play, defaults to 0 - first track. */
@property (nonatomic, readwrite) int trackIndex;

/** From which time (in seconds) in the current track do we start playing, defaults to 0.0f - start of track. */
@property (nonatomic, readwrite) NSTimeInterval startTime;

@end
