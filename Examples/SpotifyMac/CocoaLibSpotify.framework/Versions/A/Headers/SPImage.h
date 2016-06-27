//
//  SPImage.h
//  CocoaLibSpotify
//
//  Created by Daniel Kennett on 2/20/11.
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

/** Represents an image from the Spotify service. */

#import <Foundation/Foundation.h>
#import "CocoaLibSpotifyPlatformImports.h"

@class SPSession;

static NSUInteger const SPImageIdLength = 20;

@interface SPImage : NSObject <SPAsyncLoading, SPDelayableAsyncLoading>

///----------------------------
/// @name Creating and Initializing Images
///----------------------------

/** Creates an SPImage from the given ID. 
 
 This convenience method creates an SPImage object if one doesn't exist, or 
 returns a cached SPImage if one already exists for the given ID.
 
 @warning This method *must* be called on the libSpotify thread. See the
 "Threading" section of the library's readme for more information.
 
 @param imageId The image ID to create an SPImage for.
 @param aSession The SPSession the image should exist in.
 @return Returns the created SPImage object. 
 */
+(SPImage *)imageWithImageId:(const byte *)imageId inSession:(SPSession *)aSession;

/** Creates an SPImage from the given URL. 
 
 This convenience method creates an SPImage object if one doesn't exist, or 
 returns a cached SPImage if one already exists for the given URL.
 
 @param imageURL The image URL to create an SPImage for.
 @param aSession The SPSession the image should exist in.
 @param block The block to be called with the created SPImage object. 
 */
+(void)imageWithImageURL:(NSURL *)imageURL inSession:(SPSession *)aSession callback:(void (^)(SPImage *image))block;

/** Initializes a new SPImage from the given struct and ID. 
 
 @warning This method *must* be called on the libSpotify thread. See the
 "Threading" section of the library's readme for more information.
 
 @warning For better performance and built-in caching, it is recommended
 you create SPImage objects using +[SPImage imageWithImageId:inSession:].
 
 @param anImage The sp_image struct to create an SPImage for, or NULL if the image hasn't been loaded yet.
 @param anId The ID of the image.
 @param aSession The SPSession the image should exist in.
 @return Returns the created SPImage object. 
 */
-(id)initWithImageStruct:(sp_image *)anImage imageId:(const byte *)anId inSession:(SPSession *)aSession;

///----------------------------
/// @name Loading Images
///----------------------------

/** Begins loading the image if it hasn't already been loaded. 
 
 This is called automatically if you request the image property. */
-(void)startLoading;

///----------------------------
/// @name Properties
///----------------------------

/** Returns an NSImage or UIImage representation of the image, or `nil` if the image has yet to be loaded. */
@property (nonatomic, readonly, strong) SPPlatformNativeImage *image;

/** Returns the ID of the image. */
@property (nonatomic, readonly) const byte *imageId;

/** Returns `YES` if the image has finished loading and all data is available. */ 
@property (nonatomic, readonly, getter=isLoaded) BOOL loaded;

/** Returns the session the image was loaded in. */
@property (nonatomic, readonly, assign) __unsafe_unretained SPSession *session;

/** Returns the opaque structure used by the C LibSpotify API, or NULL if the image has yet to be loaded.
 
 @warning This method *must* be called on the libSpotify thread. See the
 "Threading" section of the library's readme for more information.
 
 @warning This should only be used if you plan to directly use the 
 C LibSpotify API. The behaviour of CocoaLibSpotify is undefined if you use the C
 API directly on items that have CocoaLibSpotify objects associated with them. 
 */
@property (nonatomic, readonly) sp_image *spImage;

/** Returns the Spotify URL of the image. */
@property (nonatomic, readonly, copy) NSURL *spotifyURL;

@end
