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
#import "HUD.h"
#import "MessageModelToServer.h"
#import "MessageModelFromServer.h"


@interface GreetingsViewController ()
{
    IBOutlet UIBubbleTableView *bubbleTable;
    IBOutlet UIView *textInputView;
    IBOutlet UITextField *textField;
    
    NSMutableArray *bubbleData;
}

@property (strong, nonatomic) MessageModelFromServer *messageModelFromServer;

@end

@implementation GreetingsViewController
- (IBAction)blessButtonClicked:(id)sender {
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
    MessageModelToServer *mm = [[MessageModelToServer alloc] init];
    mm.Action = 2;
    mm.Data = [textField text];
    mm.UserFullName = @"Chen Avnery";
    
    NSBubbleData *bubbleMessage = [NSBubbleData dataWithText:[textField text] date:[NSDate dateWithTimeIntervalSinceNow:-300] type:BubbleTypeSomeoneElse];
    bubbleMessage.avatar = nil;
    [bubbleData addObject:bubbleMessage];

    [bubbleTable reloadData];
    
    NSString *jsonString = [mm toJSONString];
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://54.242.242.228:4296/"]];
    [request setValue:jsonString forHTTPHeaderField:@"json"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
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
             
             [HUD showAlertWithTitle:@"Error" text:@"Error receiving information"];
         }
         else if (error != nil && error.code == NSURLErrorTimedOut)
         {
             NSLog(@"publish: error code is timed out");
             
             [HUD showAlertWithTitle:@"Error" text:@"Timed out, server is down?"];
         }
         else if (error != nil)
         {
             NSLog(@"publish: error is: %@" , [error localizedDescription]);
             
             [HUD showAlertWithTitle:@"Error" text:[error localizedDescription]];
         }
     }];
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
}

- (void)reload:(id)sender
{
    [self loadLastMessages];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadLastMessages];
}

- (void)loadLastMessages
{
    //show loader view
    [HUD showUIBlockingIndicatorWithText:@"Loading"];
    
    MessageModelToServer *mm = [[MessageModelToServer alloc] init];
    mm.Action = 0;
    mm.UserFullName = @"Chen Avnery";
    
    NSString *jsonString = [mm toJSONString];
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://54.242.242.228:4296/"]];
    [request setValue:jsonString forHTTPHeaderField:@"json"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         [HUD hideUIBlockingIndicator];
         
         if ([data length] > 0 && error == nil)
         {
             NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             
             self.messageModelFromServer = [[MessageModelFromServer alloc] initWithString:string error:nil];
             
             NSLog(@"Got action: %d",[self.messageModelFromServer Action]);
             NSLog(@"%@",[self.messageModelFromServer MessagesList]);
             
             bubbleData = [[NSMutableArray alloc] init];
             
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
                 
                 NSBubbleData *bubbleForMessage = [NSBubbleData dataWithText:[message Data] date:[NSDate dateWithTimeIntervalSinceNow:-300] type:BubbleTypeSomeoneElse];
                 bubbleForMessage.avatar = nil;
                 [bubbleData addObject:bubbleForMessage];
             }
             
             [bubbleTable reloadData];
             
         }
         else if ([data length] == 0 && error == nil)
         {
             NSLog(@"data length is zero and no error");
             
             [HUD showAlertWithTitle:@"Error" text:@"Error receiving information"];
         }
         else if (error != nil && error.code == NSURLErrorTimedOut)
         {
             NSLog(@"error code is timed out");
             
             [HUD showAlertWithTitle:@"Error" text:@"Timed out, server is down?"];
         }
         else if (error != nil)
         {
             NSLog(@"error is: %@" , [error localizedDescription]);
             
             [HUD showAlertWithTitle:@"Error" text:[error localizedDescription]];
         }
     }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];

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
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [bubbleData objectAtIndex:row];
}

#pragma mark - Keyboard events

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = textInputView.frame;
        frame.origin.y -= kbSize.height;
        textInputView.frame = frame;
        
        frame = bubbleTable.frame;
        frame.size.height -= kbSize.height;
        bubbleTable.frame = frame;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = textInputView.frame;
        frame.origin.y += kbSize.height;
        textInputView.frame = frame;
        
        frame = bubbleTable.frame;
        frame.size.height += kbSize.height;
        bubbleTable.frame = frame;
    }];
}

#pragma mark - Actions

- (IBAction)sayPressed:(id)sender
{
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    
    NSBubbleData *sayBubble = [NSBubbleData dataWithText:textField.text date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
    [bubbleData addObject:sayBubble];
    [bubbleTable reloadData];
    
    textField.text = @"";
    [textField resignFirstResponder];
}


@end
