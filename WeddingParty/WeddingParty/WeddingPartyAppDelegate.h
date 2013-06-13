//
//  WeddingPartyAppDelegate.h
//  WeddingParty
//
//  Created by MTG on 5/17/13.
//  Copyright (c) 2013 MTG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainPicturePageViewController.h"
#import <Three20/Three20.h>
#import <FacebookSDK/FacebookSDK.h>


@interface WeddingPartyAppDelegate : UIResponder <UIApplicationDelegate>

extern NSString *const FBSessionStateChangedNotification;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MainPicturePageViewController *mainViewController;

@property (weak, nonatomic) NSString *UserFirstName;

@property (weak, nonatomic) NSString *UserLastName;

@property (weak, nonatomic) NSString *UserFBProfilePictureID;

- (void)openSession;

@end
