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
#import "SPTListPage.h"

/** This object represents a list of featured playlists created from the `SPTBrowse` class

 API Docs: https://developer.spotify.com/web-api/get-list-featured-playlists/
 
 See: `SPTBrowse`
 */
@interface SPTFeaturedPlaylistList : SPTListPage





///-----------------
/// @name Properties
///-----------------

/** If there's a message associated with the paginated list. */
@property (nonatomic, readonly) NSString *message;






///---------------------------
/// @name API Response Parsers
///---------------------------

+ (instancetype)featuredPlaylistListFromData:(NSData *)data
								withResponse:(NSURLResponse *)response
									   error:(NSError **)error;

+ (instancetype)featuredPlaylistListFromDecodedJSON:(id)decodedObject
											  error:(NSError **)error;

@end
