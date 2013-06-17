//
//  GreetingsViewController.m
//  WeddingParty
//
//  Created by MTG on 5/29/13.
//  Copyright (c) 2013 MTG. All rights reserved.
//

#import "TopHitsViewController.h"
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

@interface TopHitsViewController ()
{
    IBOutlet UIBubbleTableView *bubbleTable;
    
    BOOL bLoadedFile;
    
    NSBubbleData *lastBubbleSelected;
}

@property (strong, nonatomic) MessageModelFromServer *messageModelFromServer;

@property (strong, nonatomic) NSMutableArray *bubbleData;

@property (strong, nonatomic) NSMutableDictionary *userIdToProfileImage;

@property (strong, nonatomic) NSString *userId;

@property (strong, nonatomic) NSString *userFullName;

@end

@implementation TopHitsViewController

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


- (void)AddLikeSendMessage:(NSBubbleData *)bubbleMessage
{
    MessageModelToServer *mm = [[MessageModelToServer alloc] init];
    mm.Action = 3;
    mm.Data = [bubbleMessage text];
    mm.UserFullName = [bubbleMessage userFullName];
    mm.UserId = [self userId];
    mm.UserIdsWhoLiked = nil;
    
    NSString *jsonString = [mm toJSONString];
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUnicodeStringEncoding];
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
             NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF16LittleEndianStringEncoding];
             
             self.messageModelFromServer = [[MessageModelFromServer alloc] initWithString:string error:nil];
             
             NSLog(@"Got action: %d",[self.messageModelFromServer Action]);
             NSLog(@"%@",[self.messageModelFromServer MessagesList]);
             
             if ([self.messageModelFromServer Action] == 3)
                 return; // put V near the message
             
         }
         else if ([data length] == 0 && error == nil)
         {
             NSLog(@"addLike: data length is zero and no error");
             
             [self.view makeToast:@"something went wrong"];
         }
         else if (error != nil && error.code == NSURLErrorTimedOut)
         {
             NSLog(@"addLIke: error code is timed out");
             
             [self.view makeToast:@"Could not reach the server"];
         }
         else if (error != nil)
         {
             NSLog(@"addLike: error is: %@" , [error localizedDescription]);
             
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
                duration:0.6
                position:@"center"
                   image:[UIImage imageNamed:@"heartlike.png"]];
    
    if ([lastBubbleSelected.UserIdsWhoLiked indexOfObject:[self userId]] == NSNotFound)
    {
        [lastBubbleSelected.UserIdsWhoLiked addObject:[self userId]];
        [bubbleTable reloadData];
        
        [self AddLikeSendMessage:lastBubbleSelected];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    self.userIdToProfileImage = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    WeddingPartyAppDelegate *appDelegate = (WeddingPartyAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self setUserId:[appDelegate UserFBProfilePictureID]];
    [self setUserFullName:[NSString stringWithFormat:@"%@ %@",[appDelegate UserFirstName], [appDelegate UserLastName]]];
    
    [self loadTopHitsMessages];
    
}

- (void)loadTopHitsMessages
{
    if ([self.bubbleData count] == 0)
    {
        // display toast with an activity spinner
        [self.view makeToastActivity];
    }

    MessageModelToServer *mm = [[MessageModelToServer alloc] init];
    mm.Action = 4;
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
         [self.view performSelectorOnMainThread:@selector(hideToastActivity) withObject:nil waitUntilDone:YES];
         
         if ([data length] > 0 && error == nil)
         {
             NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF16LittleEndianStringEncoding];
             
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
                     NSBubbleData *oldMsg = [[self bubbleData] objectAtIndex:j];
                     UILabel *oldMsgLabel = (UILabel *)[oldMsg view];
                     NSString *msgData = [message Data];
                     NSString *oldMsgData = [oldMsgLabel text];
                     NSString *msgUserName = [message UserFullName];
                     NSString *oldMsgUserName = [oldMsg userFullName];
                     if (([msgData compare:oldMsgData] == NSOrderedSame) && ([msgUserName compare:oldMsgUserName] == NSOrderedSame))
                     {
                         bFoundMessage = YES;
                         [oldMsg setUserIdsWhoLiked:[message UserIdsWhoLiked]];
                     }
                 }
                 
                 if (bFoundMessage == NO)
                 {
                     UIImage *image = [[self userIdToProfileImage] objectForKey:[message UserId]];
                     if (image == nil)
                     {
                         NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?", [message UserId]]];
                         NSData *data = [NSData dataWithContentsOfURL:url];
                         image = [[UIImage alloc] initWithData:data];
                         [[self userIdToProfileImage] setObject:image forKey:[message UserId]];

                     }
                     
                     NSBubbleData *bubbleForMessage = [NSBubbleData dataWithText:[message Data] date:[NSDate dateWithTimeIntervalSinceNow:-300] type:BubbleTypeSomeoneElse withFont:nil withFontColor:[UIColor blackColor] image:image username:[message UserFullName] userIdsWhoLiked:[message UserIdsWhoLiked]];
                     [self.bubbleData addObject:bubbleForMessage];
                 }
             }
             
             NSLog(@"Entering reloadData");
             
             self.bubbleData = [NSMutableArray arrayWithArray:[self.bubbleData sortedArrayUsingComparator:^NSComparisonResult(NSBubbleData *a, NSBubbleData *b) {
                 int first = [[(NSBubbleData *)a UserIdsWhoLiked] count];
                 int second = [[(NSBubbleData *)b UserIdsWhoLiked] count];
                 return first < second;
             }]];
             
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
////    
    NSLog(@"Deleting file...");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[self saveFilePath] error:NULL];
//////

    
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
    
//    bubbleTable.snapInterval = -1;
    
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
   
}

- (NSString *) saveFilePath
{
	NSArray *path =
	NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
	return [[path objectAtIndex:0] stringByAppendingPathComponent:@"weddingpartytophits.plist"];
    
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

@end
