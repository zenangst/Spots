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

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Spotify/Spotify.h>

@class SPTAuthViewController;

/** A ViewController for managing the login flow inside your app. */
@protocol SPTAuthViewDelegate

/**
 The user logged in successfully.

 @param authenticationViewController The view controller.
 @param session The session object with the new credentials. (Note that the session object in
	the `SPTAuth` object passed upon initialization is also updated)
 */
- (void) authenticationViewController:(SPTAuthViewController *)authenticationViewController didLoginWithSession:(SPTSession *)session;

/**
 An error occured while logging in
 
 @param authenticationViewController The view controller.
 @param error The error (Note that the session object in the `SPTAuth` object passed upon initialization
	is cleared.)
 */
- (void) authenticationViewController:(SPTAuthViewController *)authenticationViewController didFailToLogin:(NSError *)error;

/**
 User closed the login dialog.
 @param authenticationViewController The view controller.
 */
- (void) authenticationViewControllerDidCancelLogin:(SPTAuthViewController *)authenticationViewController;

@end

/**
 A authentication view controller

 To present the authentication dialog on top of your view controller, do like this:
 
 ```
	authvc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
	authvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	self.modalPresentationStyle = UIModalPresentationCurrentContext;
	self.definesPresentationContext = YES;
	[self presentViewController:authvc animated:NO completion:nil];
 ```
 */
@interface SPTAuthViewController : UIViewController

/**
 The delegate which will receive the result of the authentication.
 */
@property (nonatomic, assign) id<SPTAuthViewDelegate> delegate;

/**
 Enable the signup flow while logging in, this is off by default.
 */
@property (nonatomic, readwrite) BOOL hideSignup;

/**
 Creates an authentication view controller for the default application using the authentication information from
 `SPTAuth.defaultInstance`

 @return The authentication view controller.
 */
+ (SPTAuthViewController*) authenticationViewController;

/**
 Creates an authentication view controller for a specific application.

 @param auth The authentication object, containing the app configuration, pass `nil` if you want to use the
	authentication information from `SPTAuth.defaultInstance`
 @return The authentication view controller.
 */
+ (SPTAuthViewController*) authenticationViewControllerWithAuth:(SPTAuth *)auth;

/**
 Removes all authentication related cookies from the UIWebView.
 
 @param callback Called when cookies are cleared.
 */
- (void) clearCookies:(void (^)())callback;

@end
