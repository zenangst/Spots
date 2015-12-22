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
#import "SPTRequest.h"

@class SPTImage;

/** Represents a user's product level. */
typedef NS_ENUM(NSUInteger, SPTProduct) {
	/** The user has a Spotify Free account. */
	SPTProductFree,
	/** The user has a Spotify Unlimited account. */
	SPTProductUnlimited,
	/** The user has a Spotify Premium account. */
	SPTProductPremium,
	/** The user's product level is unknown. */
	SPTProductUnknown
};

/** This class represents a user on the Spotify service.
 
 API Model: https://developer.spotify.com/web-api/object-model/#user-object-private
 
 API Console: https://developer.spotify.com/web-api/console/user%20profiles/
 */
@interface SPTUser : SPTJSONObjectBase





///----------------------------
/// @name Properties
///----------------------------

/** The full display name of the user.
 
 Will be `nil` unless your session has been granted the
 `SPTAuthUserReadPrivateScope` scope.
 */
@property (nonatomic, readonly, copy) NSString *displayName;

/** The canonical user name of the user. Not necessarily appropriate
 for UI use.
 */
@property (nonatomic, readonly, copy) NSString *canonicalUserName;

/** An ISO 3166 country code of the user's account. */
@property (nonatomic, readonly, copy) NSString *territory;

/** The user's email address.
 
 Will be `nil` unless your session has been granted the
 `SPTAuthUserReadEmailScope` scope.
 */
@property (nonatomic, readonly, copy) NSString *emailAddress;

/** The Spotify URI of the user. */
@property (nonatomic, readonly, copy) NSURL *uri;

/** The HTTP open.spotify.com URL of the user. */
@property (nonatomic, readonly, copy) NSURL *sharingURL;

/** Returns a list of user images in various sizes, as `SPTImage` objects.
 
 Will be `nil` unless your session has been granted the
 `SPTAuthUserReadPrivateScope` scope.
 */
@property (nonatomic, readonly, copy) NSArray *images;

/** Convenience method that returns the smallest available user image.
 
 Will be `nil` unless your session has been granted the
 `SPTAuthUserReadPrivateScope` scope.
 */
@property (nonatomic, readonly) SPTImage *smallestImage;

/** Convenience method that returns the largest available user image.
 
 Will be `nil` unless your session has been granted the
 `SPTAuthUserReadPrivateScope` scope.
 */
@property (nonatomic, readonly) SPTImage *largestImage;

/** The product of the user. For example, only Premium users can stream audio.
 
 Will be `SPTProductUnknown` unless your session has been granted the
 `SPTAuthUserReadPrivateScope` scope.
 */
@property (nonatomic, readonly) SPTProduct product;

/** The number of followers this user has. */
@property (nonatomic, readonly) long followerCount;






///-------------------------------
/// @name Request creation methods
///-------------------------------

/**
 Create a NSURLRequest for requesting the current user

 See: https://developer.spotify.com/web-api/console/get-current-user/
 
 @param accessToken A valid and authenticated access token.
 @param error An optional pointer to an `NSError` that will receive the error code if operation failed.
 */
+ (NSURLRequest *)createRequestForCurrentUserWithAccessToken:(NSString *)accessToken error:(NSError **)error;

/**
 Request current user
 
 See: https://developer.spotify.com/web-api/console/get-current-user/
 
 @param accessToken A valid and authenticated access token.
 @param block The block to be called when the operation is complete. The block will pass a Spotify SDK metadata object on success, otherwise an error.
 */
+(void)requestCurrentUserWithAccessToken:(NSString *)accessToken callback:(SPTRequestCallback)block;

/**
 Request a user profile
 
 See: https://developer.spotify.com/web-api/console/get-users-profile/
 
 @param username The username of the user to request
 @param accessToken A valid and authenticated access token, or `nil`
 @param block The block to be called when the operation is complete. The block will pass a Spotify SDK metadata object on success, otherwise an error.
 */
+(void)requestUser:(NSString *)username withAccessToken:(NSString *)accessToken callback:(SPTRequestCallback)block;





///-------------------------------
/// @name Response parsing methods
///-------------------------------

/**
 Convert a HTTP response into a SPTUser object
 
 See: https://developer.spotify.com/web-api/object-model/#user-object-private and https://developer.spotify.com/web-api/object-model/#user-object-public
 
 @param data The response body
 @param response The response headers
 @param error An optional pointer to an `NSError` that will receive the error code if operation failed.
 */
+ (instancetype)userFromData:(NSData *)data
				withResponse:(NSURLResponse *)response
					   error:(NSError **)error;


/**
 Convert a decoded response into a SPTUser object
 
 See: https://developer.spotify.com/web-api/object-model/#user-object-private and https://developer.spotify.com/web-api/object-model/#user-object-public
 
 @param decodedObject The decoded JSON object structure.
 @param error An optional pointer to an `NSError` that will receive the error code if operation failed.
 */
+ (instancetype)userFromDecodedJSON:(id)decodedObject
							  error:(NSError **)error;

@end
