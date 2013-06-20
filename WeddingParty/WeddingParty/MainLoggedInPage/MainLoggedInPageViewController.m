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

@property (weak, nonatomic) IBOutlet UIImageView *mainBannerPicture;
@property (weak, nonatomic) IBOutlet UIButton *GalleryButton;

@property (weak, nonatomic) IBOutlet UIButton *GreetingsButton;

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

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskPortraitUpsideDown | UIInterfaceOrientationMaskPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
    
    WeddingPartyAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.UserFBProfilePicture.profileID = [appDelegate UserFBProfilePictureID];
    self.WelcomeUserText.text = [NSString stringWithFormat:@"%@, %@ %@", NSLocalizedString(@"Welcome", nil), [appDelegate UserFirstName], [appDelegate UserLastName]];
    
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([language compare:@"en"] == NSOrderedSame)
        [self.WelcomeUserText setTextAlignment:NSTextAlignmentLeft];
    else //he
        [self.WelcomeUserText setTextAlignment:NSTextAlignmentRight];
    
    self.UserFBProfilePicture.layer.cornerRadius = 9.0;
    self.UserFBProfilePicture.layer.masksToBounds = YES;
    self.UserFBProfilePicture.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.2].CGColor;
    self.UserFBProfilePicture.layer.borderWidth = 1.0;
    
    if ([language compare:@"en"] == NSOrderedSame)
        self.mainBannerPicture.image = [UIImage imageNamed:@"main_banner.jpg"];
    else //he
        self.mainBannerPicture.image = [UIImage imageNamed:@"main_banner_he.jpg"];

    self.mainBannerPicture.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.2].CGColor;
    self.mainBannerPicture.layer.borderWidth = 1.0;
    
    [self.GalleryButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.GalleryButton setTitle:NSLocalizedString(@"Gallery", nil) forState:UIControlStateNormal];
    
    [self.GreetingsButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.GreetingsButton setTitle:NSLocalizedString(@"Greetings", nil) forState:UIControlStateNormal];
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
