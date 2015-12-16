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

/** An object that supports decoding from JSON. */
@protocol SPTJSONObject <NSObject>

/** Initialise the object with the given decoded JSON response from the web API
  (typically an `NSDictionary`, but not always).
 
 @param decodedObject The decoded representation of the object.
 @param error An error pointer that will contain an error if a problem occurred. 
 @return Returns the initalised object, or `nil` if a problem occurred.
 */
-(id)initWithDecodedJSONObject:(id)decodedObject error:(NSError **)error;

/** Returns the original decoded object (typically an `NSDictionary`, but not always)
 that was used to create the object. Useful for serialising. */
@property (nonatomic, readonly, copy) id decodedJSONObject;

@end

/** Helper class for decoding JSON from the Spotify web API. You shouldn't need to use this 
 in your application — use `SPTRequest` instead. */
@interface SPTJSONDecoding : NSObject

///----------------------------
/// @name JSON Decoding
///----------------------------

/** Convert an object decoded from JSON into a Spotify SDK metadata object.
 
 @param decodedJson The object decoded from JSON.
 @param error A pointer to an error object that will be filled if an error occurs.
 @return The generated object, or `nil` if an error occurs.
 */
+(id)SPObjectFromDecodedJSON:(id)decodedJson error:(NSError **)error;

/** Convert an object from the given JSON data into a Spotify SDK metadata object.

 @param json The JSON data.
 @param error A pointer to an error object that will be filled if an error occurs.
 @return The generated object, or `nil` if an error occurs.
 */
+(id)SPObjectFromEncodedJSON:(NSData *)json error:(NSError **)error;


/** Convert an object decoded from JSON into a partial Spotify SDK metadata object.

 @param decodedJson The object decoded from JSON.
 @param error A pointer to an error object that will be filled if an error occurs.
 @return The generated object, or `nil` if an error occurs.
 */
+(id)partialSPObjectFromDecodedJSON:(id)decodedJson error:(NSError **)error;

/** Convert an object from the given JSON data into a partial Spotify SDK metadata object.

 @param json The JSON data.
 @param error A pointer to an error object that will be filled if an error occurs.
 @return The generated object, or `nil` if an error occurs.
 */
+(id)partialSPObjectFromEncodedJSON:(NSData *)json error:(NSError **)error;

@end

/** Base object for JSON based models. */
@interface SPTJSONObjectBase : NSObject<SPTJSONObject>

@property (nonatomic, readwrite, copy) id decodedJSONObject;

@end

