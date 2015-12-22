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

/**
 @brief SPTSession is a class that represents a user session authenticated through the Spotify OAuth service.
 @discussion For persisting the session, you may use `NSKeyedArchiver` to obtain an `NSData` instance, which can
  be stored securely using Keychain Services.
 @note A session is valid for a certain period of time, and may be renewed without user intervention using `SPTAuth`.
 @see SPTAuth
 */
@interface SPTSession : NSObject <NSSecureCoding>

///----------------------------
/// @name Initialisation
///----------------------------

/**
 @brief The deignated initializer for `SPTSession`.
 @param userName The username of the user.
 @param accessToken The access token of the user.
 @param expirationDate The expiration date of the access token.
 @return An initialized `SPTSession` object.
 */
- (instancetype)initWithUserName:(NSString *)userName accessToken:(NSString *)accessToken expirationDate:(NSDate *)expirationDate;

/**
 @brief The deignated initializer for `SPTSession`.
 @param userName The username of the user.
 @param accessToken The access token of the user.
 @param encryptedRefreshToken The encrypted refresh token of the user.
 @param expirationDate The expiration date of the access token.
 @return An initialized `SPTSession` object.
 */
- (instancetype)initWithUserName:(NSString *)userName accessToken:(NSString *)accessToken encryptedRefreshToken:(NSString *)encryptedRefreshToken expirationDate:(NSDate *)expirationDate;

/**
 @brief Initializer that takes an `NSTimeInterval` until the access token expires, instead of an `NSDate`.
 @param userName The username of the user.
 @param accessToken The access token of the user.
 @param timeInterval The time interval until the access token expires.
 @return An initialized `SPTSession` object.
 */
- (instancetype)initWithUserName:(NSString *)userName accessToken:(NSString *)accessToken expirationTimeInterval:(NSTimeInterval)timeInterval;

///----------------------------
/// @name Properties
///----------------------------

/**
 @brief Returns whether the session is still valid.
 @discussion Determining validity is done by comparing the current date and time with the expiration date of the `SPTSession` object.
 @return `YES` if valid, otherwise `NO`.
 */
- (BOOL)isValid;

/** @brief The canonical username of the authenticated user. */
@property (nonatomic, copy, readonly) NSString *canonicalUsername;

/** @brief The access token of the authenticated user. */
@property (nonatomic, copy, readonly) NSString *accessToken;

/** @brief The encrypted refresh token. */
@property (nonatomic, copy, readonly) NSString *encryptedRefreshToken;

/** @brief The expiration date of the access token. */
@property (nonatomic, copy, readonly) NSDate *expirationDate;

/** @brief The access token type. */
@property (nonatomic, copy, readonly) NSString *tokenType;

@end
