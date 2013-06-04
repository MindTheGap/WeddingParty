//
//  MainLoggedInPageViewController.m
//  WeddingParty
//
//  Created by MTG on 5/24/13.
//  Copyright (c) 2013 MTG. All rights reserved.
//

#import "MainLoggedInPageViewController.h"
#import "WeddingPartyAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "PhotoSet.h"
#import "GreetingsViewController.h"

@interface MainLoggedInPageViewController ()


@property (weak, nonatomic) IBOutlet UILabel *WelcomeUserText;

@property (weak, nonatomic) IBOutlet FBProfilePictureView *UserFBProfilePicture;


@end

@implementation MainLoggedInPageViewController


- (IBAction)GalleryButtonClick:(UIButton *)sender
{
    TTPhotoViewController *photoViewController = [[TTPhotoViewController alloc] init];
    photoViewController.photoSource = [PhotoSet samplePhotoSet];
    
    [[TTURLRequestQueue mainQueue] setMaxContentLength:0];
    [photoViewController.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:photoViewController animated:YES];

}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
    
    WeddingPartyAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.UserFBProfilePicture.profileID = [appDelegate UserFBProfilePictureID];
    self.WelcomeUserText.text = [appDelegate WelcomeUserText];
    
    
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    NSLog(@"loginViewShowingLoggedOutUser");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSLog(@"LoggedOnFBPage - viewDidLoad");
    
        
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


@end
