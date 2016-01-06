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
#import "SPTDiskCaching.h"

/**
 * @brief The `SPTDiskCache` class implements the `SPTDiskCaching` protocol and provides a caching mechanism based on memory mapped files.
 * @see `SPTDiskCaching`
 */
@interface SPTDiskCache : NSObject <SPTDiskCaching>

/**
 * @brief Initialize the disk cache with capacity.
 * @param capacity The maximum capacity of the disk cache, in bytes.
 */
- (instancetype)initWithCapacity:(NSUInteger)capacity;

/**
 * @brief Evict cache data.
 * @discussion Deletes cached data until the space occupied is <= `capacity`
 * @param error An error pointer that will contain an error if a problem occurred.
 * @return `YES` if eviction was successful, `NO` otherwise.
 */
- (BOOL)evict:(NSError **)error;

/**
 * @brief Clear all cached data.
 * @param error An error pointer that will contain an error if a problem occurred.
 * @return `YES` if successful, `NO` otherwise.
 */
- (BOOL)clear:(NSError **)error;

/**
 * @brief The size of all cached data.
 * @note In addition to actual cached data, this includes bookkeeping overhead.
 * @return The total number of bytes used by the disk cache.
 */
- (NSUInteger)size;

@property (nonatomic, readonly) NSUInteger capacity;

@end
