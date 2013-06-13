//
//  GreetingsViewController.m
//  WeddingParty
//
//  Created by MTG on 5/29/13.
//  Copyright (c) 2013 MTG. All rights reserved.
//

#import "GreetingsViewController.h"
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"
#import "JSONModelLib.h"
#import "MessageModelToServer.h"
#import "MessageModelFromServer.h"
#import "WeddingPartyAppDelegate.h"
#import "Toast+UIView.h"

#define kMessageModelKey @"MessageModel"
#define kBubbleDataKey @"BubbleData"

@interface GreetingsViewController ()
{
    IBOutlet UIBubbleTableView *bubbleTable;
    IBOutlet UIView *textInputView;
    IBOutlet UITextField *textField;
    
    BOOL bLoadedFile;
    
    __weak IBOutlet UIView *mainViewOfTV;
   
    __weak IBOutlet NSLayoutConstraint *keyboardHeightConstraint;
    
    NSBubbleData *lastBubbleSelected;
}

@property (strong, nonatomic) MessageModelFromServer *messageModelFromServer;

@property (strong, nonatomic) NSMutableArray *bubbleData;

@property (strong, nonatomic) NSMutableDictionary *userIdToProfileImage;

@property (strong, nonatomic) NSString *userId;

@property (strong, nonatomic) NSString *userFullName;

@end

@implementation GreetingsViewController

@synthesize bubbleData = _bubbleData;
@synthesize messageModelFromServer = _messageModelFromServer;
@synthesize userIdToProfileImage = _userIdToProfileImage;
@synthesize userId = _userId;
@synthesize userFullName = _userFullName;

- (NSMutableArray *)bubbleData
{
    if (_bubbleData) return _bubbleData;
    
    NSLog(@"entered getter for bubbleData");
    NSString *bubbleDataPath = [self saveFilePath];
    NSData *codedData = [[NSData alloc] initWithContentsOfFile:bubbleDataPath];
    if (codedData == nil)
    {
        NSLog(@"bubbleData couldn't decode, returning nil");
        return nil;
    }
    
    bLoadedFile = YES;
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
    _bubbleData = [unarchiver decodeObjectForKey:kBubbleDataKey];
    [unarchiver finishDecoding];

    return _bubbleData;
}

- (MessageModelFromServer *)messageModelFromServer
{
    if (_messageModelFromServer) return _messageModelFromServer;
    
    NSLog(@"entered getter for messageModelFromServer");
    NSString *bubbleDataPath = [self saveFilePath];
    NSData *codedData = [[NSData alloc] initWithContentsOfFile:bubbleDataPath];
    if (codedData == nil)
    {
        NSLog(@"messageModelFromServer couldn't decode, returning nil");
        return nil;
    }
    
    bLoadedFile = YES;
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
    _messageModelFromServer = [unarchiver decodeObjectForKey:kMessageModelKey];
    [unarchiver finishDecoding];
    
    return _messageModelFromServer;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)BlessButtonClick:(UIButton *)sender
{
    NSString *textFromUser = [[textField text] copy];
    
    MessageModelToServer *mm = [[MessageModelToServer alloc] init];
    mm.Action = 2;
    mm.Data = textFromUser;
    mm.UserFullName = [self userFullName];
    mm.UserId = [self userId];
    
    UIImage *image = [[self userIdToProfileImage] objectForKey:[self userId]];
    if (image == nil)
    {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?", [self userId]]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        image = [[UIImage alloc] initWithData:data];
        [[self userIdToProfileImage] setObject:image forKey:[self userId]];
    }

    
    NSBubbleData *bubbleMessage = [NSBubbleData dataWithText:textFromUser date:[NSDate dateWithTimeIntervalSinceNow:-300] type:BubbleTypeSomeoneElse withFont:nil withFontColor:[UIColor blackColor] image:image username:[self userFullName]];
    [self.bubbleData addObject:bubbleMessage];
    
    textField.text = @"";
    [textField resignFirstResponder];
    
    [bubbleTable reloadData];
    
    NSString *jsonString = [mm toJSONString];
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://54.242.242.228:4296/"]];
    [request setValue:jsonString forHTTPHeaderField:@"json"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:5];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] > 0 && error == nil)
         {
             NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             
             self.messageModelFromServer = [[MessageModelFromServer alloc] initWithString:string error:nil];
             
             NSLog(@"Got action: %d",[self.messageModelFromServer Action]);
             NSLog(@"%@",[self.messageModelFromServer MessagesList]);
             
             if ([self.messageModelFromServer Action] == 2)
                 return; // put V near the message
             
         }
         else if ([data length] == 0 && error == nil)
         {
             NSLog(@"publish: data length is zero and no error");
             
             textField.text = textFromUser;
             [[self bubbleData] removeLastObject];
             
             [self.view makeToast:@"something went wrong"];
         }
         else if (error != nil && error.code == NSURLErrorTimedOut)
         {
             NSLog(@"publish: error code is timed out");
             
             textField.text = textFromUser;
             [[self bubbleData] removeLastObject];
             
             [self.view makeToast:@"Could not reach the server"];
         }
         else if (error != nil)
         {
             NSLog(@"publish: error is: %@" , [error localizedDescription]);
             
             textField.text = textFromUser;
             [[self bubbleData] removeLastObject];
             
             [self.view makeToast:[error localizedDescription]];
         }
     }];
}

- (void)didSelectNSBubbleDataCell:(NSBubbleData *)dataCell
{
    UILabel *label = (UILabel *)dataCell.view;
    NSLog(@"dataCell text: %@",[label text]);
    
    lastBubbleSelected = dataCell;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"Reload.png"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"Reload-inv.png"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(reload:) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 32, 32)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg1.jpg"]];
    [backgroundImageView setFrame:bubbleTable.frame];
    
    bubbleTable.backgroundView = backgroundImageView;
//    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapLike:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [bubbleTable addGestureRecognizer:doubleTapGesture];
}

- (void)doubleTapLike:(id)sender
{
    [self.view makeToast:nil
                duration:2.0
                position:@"center"
                   image:[UIImage imageNamed:@"heartlike.png"]];
    
    

}

//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    cell.imageView.userInteractionEnabled = YES;
//    cell.imageView.tag = indexPath.row;
//    
//    UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myFunction:)];
//    tapped.numberOfTapsRequired = 1;
//    [cell.imageView addGestureRecognizer:tapped];
//}

- (void)reload:(id)sender
{
    [self loadLastMessages];
    
    
}


- (void)viewDidAppear:(BOOL)animated
{
//    UITapGestureRecognizer *singleFingerTap =
//    [[UITapGestureRecognizer alloc] initWithTarget:self
//                                            action:@selector(handleSingleTap:)];
//
//    [mainViewOfTV addGestureRecognizer:singleFingerTap];
    
    self.userIdToProfileImage = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    WeddingPartyAppDelegate *appDelegate = (WeddingPartyAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self setUserId:[appDelegate UserFBProfilePictureID]];
    [self setUserFullName:[NSString stringWithFormat:@"%@ %@",[appDelegate UserFirstName], [appDelegate UserLastName]]];
    
    [self loadLastMessages];
    
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    
    [recognizer cancelsTouchesInView];
}


- (void)loadLastMessages
{
    if ([self.bubbleData count] == 0)
    {
        // display toast with an activity spinner
        [self.view makeToastActivity];
    }

    MessageModelToServer *mm = [[MessageModelToServer alloc] init];
    mm.Action = 0;
    mm.UserId = [self userId];
    mm.UserFullName = [self userFullName];
    
    NSString *jsonString = [mm toJSONString];
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://54.242.242.228:4296/"]];
    [request setValue:jsonString forHTTPHeaderField:@"json"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         [self.view hideToastActivity];
         
         if ([data length] > 0 && error == nil)
         {
             NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             
             self.messageModelFromServer = [[MessageModelFromServer alloc] initWithString:string error:nil];
             
             NSLog(@"Got action: %d",[self.messageModelFromServer Action]);
             NSLog(@"%@",[self.messageModelFromServer MessagesList]);
             
             if (self.bubbleData == nil)
                 self.bubbleData = [[NSMutableArray alloc] init];
             
             for (int i = 0; i < [[self.messageModelFromServer MessagesList] count]; i++)
             {
                 NSDictionary *messageDictionary = (NSDictionary*)[[self.messageModelFromServer MessagesList] objectAtIndex:i];
                 
                 NSError *errorParsing;
                 MessageModelToServer *message = [[MessageModelToServer alloc] initWithDictionary:messageDictionary error:&errorParsing];
                 if (errorParsing)
                 {
                     NSLog(@"init with dictionary has an error: %@", [errorParsing localizedDescription]);
                     return;
                 }
                 
                 BOOL bFoundMessage = NO;
                 int count = [self.bubbleData count];
                 NSLog(@"bubbleData count = %d", count);
                 for (int j = 0; j < count; j++)
                 {
//                     NSLog(@"searching for bubble");
                     NSBubbleData *oldMsg = [[self bubbleData] objectAtIndex:j];
//                     NSLog(@"got oldMsg");
                     UILabel *oldMsgLabel = (UILabel *)[oldMsg view];
                     NSString *msgData = [message Data];
//                     NSLog(@"msgData: %@", msgData);
                     NSString *oldMsgData = [oldMsgLabel text];
//                     NSLog(@"oldMsgData: %@", oldMsgData);
                     NSString *msgUserName = [message UserFullName];
//                     NSLog(@"msgUserName: %@", msgUserName);
                     NSString *oldMsgUserName = [oldMsg userFullName];
//                     NSLog(@"oldMsgUserName: %@", oldMsgUserName);
                     if (([msgData compare:oldMsgData] == NSOrderedSame) && ([msgUserName compare:oldMsgUserName] == NSOrderedSame))
                     {
//                         NSLog(@"found bubble!");
                         bFoundMessage = YES;
                     }
                 }
                 
                 if (bFoundMessage == NO)
                 {
//                     NSLog(@"adding bubble with text: %@", [message Data]);
//                     NSLog(@"Bubble was created!");
                     UIImage *image = [[self userIdToProfileImage] objectForKey:[message UserId]];
                     if (image == nil)
                     {
                         NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?", [message UserId]]];
                         NSData *data = [NSData dataWithContentsOfURL:url];
                         image = [[UIImage alloc] initWithData:data];
                         [[self userIdToProfileImage] setObject:image forKey:[message UserId]];

                     }
                     
                     NSBubbleData *bubbleForMessage = [NSBubbleData dataWithText:[message Data] date:[NSDate dateWithTimeIntervalSinceNow:-300] type:BubbleTypeSomeoneElse withFont:nil withFontColor:[UIColor blackColor] image:image username:[message UserFullName]];

//                     NSLog(@"Added Avatar!");
                     [self.bubbleData addObject:bubbleForMessage];
//                     NSLog(@"Added bubble!");
                 }
             }
             
             NSLog(@"Entering reloadData");
             
             [bubbleTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];

             NSLog(@"After reloadData");
             
         }
         else if ([data length] == 0 && error == nil)
         {
             NSLog(@"data length is zero and no error");
             
             [self.view makeToast:@"Error receiving information."];
         }
         else if (error != nil && error.code == NSURLErrorTimedOut)
         {
             NSLog(@"error code is timed out");
             
             [self.view makeToast:@"Timed out, server is down?"];
         }
         else if (error != nil)
         {
             NSLog(@"error is: %@" , [error localizedDescription]);
             
             [self.view makeToast:[error localizedDescription]];
         }
     }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // back button was pressed
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound)
    {
        [self saveDataToDisk];
    }
    
    NSLog(@"Deleting file...");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[self saveFilePath] error:NULL];
//

    
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //handle save and load
    NSString *myPath = [self saveFilePath];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:myPath];
	if (fileExists)
	{
		NSArray *values = [[NSArray alloc] initWithContentsOfFile:myPath];
		self.messageModelFromServer = [values objectAtIndex:0];
        self.bubbleData = [values objectAtIndex:1];
	}
    
	UIApplication *myApp = [UIApplication sharedApplication];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:myApp];

    
    bubbleTable.bubbleDataSource = self;
    
    // The line below sets the snap interval in seconds. This defines how the bubbles will be grouped in time.
    // Interval of 120 means that if the next messages comes in 2 minutes since the last message, it will be added into the same group.
    // Groups are delimited with header which contains date and time for the first message in the group.
    
    bubbleTable.snapInterval = 120;
    
    // The line below enables avatar support. Avatar can be specified for each bubble with .avatar property of NSBubbleData.
    // Avatars are enabled for the whole table at once. If particular NSBubbleData misses the avatar, a default placeholder will be set (missingAvatar.png)
    bubbleTable.showAvatars = YES;
    
    // Uncomment the line below to add "Now typing" bubble
    // Possible values are
    //    - NSBubbleTypingTypeSomebody - shows "now typing" bubble on the left
    //    - NSBubbleTypingTypeMe - shows "now typing" bubble on the right
    //    - NSBubbleTypingTypeNone - no "now typing" bubble
    
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
        // Keyboard events
    
    [bubbleTable reloadData];
    [bubbleTable scrollToBottomAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    
}

- (NSString *) saveFilePath
{
	NSArray *path =
	NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
	return [[path objectAtIndex:0] stringByAppendingPathComponent:@"weddingparty.plist"];
    
}

- (void)saveDataToDisk
{
    NSLog(@"applicationDidEnterBackground, about to save");
    NSString *dataPath = [self saveFilePath];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.messageModelFromServer forKey:kMessageModelKey];
    [archiver encodeObject:self.bubbleData forKey:kBubbleDataKey];
    [archiver finishEncoding];
    [data writeToFile:dataPath atomically:YES];
    
    NSLog(@"saved!");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self saveDataToDisk];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    NSLog(@"Entered rowsForBubbleTable with count %d", [self.bubbleData count]);
    return [self.bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    NSLog(@"Entered bubbleTableView:dataForRow with row %d", row);
    return [self.bubbleData objectAtIndex:row];
}

#pragma mark - Keyboard events

- (void)keyboardWasShown:(NSNotification*)notification
{
    
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    
    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    CGFloat height = isPortrait ? keyboardFrame.size.height : keyboardFrame.size.width;
    NSLog(@"The keyboard height is: %f", height);
    
    NSLog(@"Updating constraints.");
    // Because the "space" is actually the difference between the bottom lines of the 2 views,
    // we need to set a negative constant value here.
    keyboardHeightConstraint.constant = -height;
    [self.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
        [bubbleTable scrollToBottomAnimated:YES];
    }];
    
}

- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    keyboardHeightConstraint.constant = 0;
    [self.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
    
    

}



@end
