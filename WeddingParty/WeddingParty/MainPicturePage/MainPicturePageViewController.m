//
//  MainPicturePageViewController.m
//  WeddingParty
//
//  Created by MTG on 5/17/13.
//  Copyright (c) 2013 MTG. All rights reserved.
//

#import "MainPicturePageViewController.h"
#import "MainLoggedInPageViewController.h"
#import "WeddingPartyAppDelegate.h"

@interface MainPicturePageViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *mainPictureImageView;


@end

@implementation MainPicturePageViewController

- (void)handleViewFetchedUserInfo:(id<FBGraphUser>)user
                         animated:(BOOL)animated
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"MainLoggedInNavigationController"];
        
    WeddingPartyAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate setUserFBProfilePictureID:user.id];
    [appDelegate setWelcomeUserText:[NSString stringWithFormat:@"Welcome, %@",user.first_name]];
    
    [self presentViewController:navController animated:animated completion:nil];


}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"MainPicturePage - ViewWillAppear");
    

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}


- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    [self handleViewFetchedUserInfo:user animated:NO];
}



@end
