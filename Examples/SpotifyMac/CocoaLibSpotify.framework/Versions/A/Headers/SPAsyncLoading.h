//
//  SPAsyncLoadingObserver.h
//  CocoaLibSpotify Mac Framework
//
//  Created by Daniel Kennett on 12/04/2012.
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

#import <Foundation/Foundation.h>

static NSTimeInterval const kSPAsyncLoadingDefaultTimeout = 20.0;

/** Provides standard protocol for CocoaLibSpotify metadata objects to load. */

@protocol SPAsyncLoading <NSObject>

/** Returns `YES` if the reciever has loaded its metadata, otherwise `NO`. Must be KVO-compliant. */
@property (readonly, nonatomic, getter = isLoaded) BOOL loaded;

@end

typedef enum SPAsyncLoadingPolicy {
	SPAsyncLoadingImmediate = 0, /* Immediately load items on login. */
	SPAsyncLoadingManual /* Only load items when -startLoading is called. */
} SPAsyncLoadingPolicy;

/** Provides a standard protocol for CocoaLibSpotify metadata objects to load later. */

@protocol SPDelayableAsyncLoading <SPAsyncLoading, NSObject>

/** Starts the loading process. Has no effect if the loading process has already been started. */
-(void)startLoading;

@end

/** Helper class providing a simple callback mechanism for when objects are loaded. */ 

@interface SPAsyncLoading : NSObject

/** Call the provided callback block when all passed items are loaded or the
 given timeout is reached.
 
  This will trigger a load if the item's session's loading policy is `SPAsyncLoadingManual`.
 
 The callback block will be triggered immediately if no items are provided 
 or all provided items are already loaded.
 
 @param itemOrItems A single item of an array of items conforming to the `SPAsyncLoading` protocol.
 @param timeout Time to allow before timing out. This should be the maximum reasonable time your application can wait, or `kSPAsyncLoadingDefaultTimeout`.
 @param block The block to call when all given items are loaded or the timeout is reached.
 */
+(void)waitUntilLoaded:(id)itemOrItems timeout:(NSTimeInterval)timeout then:(void (^)(NSArray *loadedItems, NSArray *notLoadedItems))block;

@end
