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

/** The operation was successful. */
FOUNDATION_EXPORT NSInteger const SPTErrorCodeNoError;

/** The operation failed due to an unspecified issue. */
FOUNDATION_EXPORT NSInteger const SPTErrorCodeFailed;

/** Audio streaming could not be initialised. */
FOUNDATION_EXPORT NSInteger const SPTErrorCodeInitFailed;

/** Audio streaming could not be initialized because of an incompatible API version. */
FOUNDATION_EXPORT NSInteger const SPTErrorCodeWrongAPIVersion;

/** An unexpected NULL pointer was passed as an argument to a function. */
FOUNDATION_EXPORT NSInteger const SPTErrorCodeNullArgument;

/** An unexpected argument value was passed to a function. */
FOUNDATION_EXPORT NSInteger const SPTErrorCodeInvalidArgument;

/** Audio streaming has not yet been initialised for this application. */
FOUNDATION_EXPORT NSInteger const SPTErrorCodeUninitialized;

/** Audio streaming has already been initialised for this application. */
FOUNDATION_EXPORT NSInteger const SPTErrorCodeAlreadyInitialized;

/** Login to Spotify failed because of invalid credentials. */
FOUNDATION_EXPORT NSInteger const SPTErrorCodeBadCredentials;

/** The operation requires a Spotify Premium account. */
FOUNDATION_EXPORT NSInteger const SPTErrorCodeNeedsPremium;

/** The Spotify user is not allowed to log in from this country. */
FOUNDATION_EXPORT NSInteger const SPTErrorCodeTravelRestriction;

/** The application has been banned by Spotify. */
FOUNDATION_EXPORT NSInteger const SPTErrorCodeApplicationBanned;

/** An unspecified login error occurred. */
FOUNDATION_EXPORT NSInteger const SPTErrorCodeGeneralLoginError;

/** The operation is not supported. */
FOUNDATION_EXPORT NSInteger const SPTErrorCodeUnsupported;

/** The operation is not supported if the device is not the active playback device. */
FOUNDATION_EXPORT NSInteger const SPTErrorCodeNotActiveDevice;

/** An unspecified playback error occurred. */
FOUNDATION_EXPORT NSInteger const SPTErrorCodeGeneralPlaybackError;

/** The application is rate-limited if it requests the playback of too many tracks within a given amount of time. */
FOUNDATION_EXPORT NSInteger const SPTErrorCodePlaybackRateLimited;

/** The track you're trying to play is unavailable for the current user, or was unable to start. */
FOUNDATION_EXPORT NSInteger const SPTErrorCodeTrackUnavailable;
