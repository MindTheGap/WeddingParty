//
//  UIBubbleTableViewCell.m
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import "UIBubbleTableViewCell.h"
#import "NSBubbleData.h"
#import <QuartzCore/QuartzCore.h>

@interface UIBubbleTableViewCell ()

@property (nonatomic, retain) UIView *customView;
@property (nonatomic, retain) UIImageView *bubbleImage;
@property (nonatomic, retain) UIImageView *avatarImage;

- (void) setupInternalData;

@end

@implementation UIBubbleTableViewCell

@synthesize data = _data;
@synthesize customView = _customView;
@synthesize bubbleImage = _bubbleImage;
@synthesize showAvatar = _showAvatar;
@synthesize avatarImage = _avatarImage;

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
	[self setupInternalData];
}

#if !__has_feature(objc_arc)
- (void) dealloc
{
    [_data release];
	_data = nil;
    [_customView release];
    _customView = nil;
    [super dealloc];
}
#endif


- (void)setDataInternal:(NSBubbleData *)value
{
#if !__has_feature(objc_arc)
	[value retain];
	[_data release];
#endif
	_data = value;
	[self setupInternalData];
}

- (void) setupInternalData
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!self.bubbleImage)
    {
        self.bubbleImage = [[UIImageView alloc] init];
        [self addSubview:self.bubbleImage];
    }
    
    NSBubbleType type = self.data.type;

    CGFloat width = self.data.view.frame.size.width;
    CGFloat height = self.data.view.frame.size.height;

    CGFloat x = (type == BubbleTypeSomeoneElse) ? 0 : self.frame.size.width - width - self.data.insets.left - self.data.insets.right;
    CGFloat y = 0;
    
    [self.customView removeFromSuperview];
    self.customView = self.data.view;
    
    self.imageView.image = [UIImage imageNamed:@"like.png"];
    [self.imageView setHidden:YES];
    
    UILabel *likeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -15, 25, 20)];
    [likeLabel setTextAlignment:NSTextAlignmentCenter];
    [likeLabel setBackgroundColor:[UIColor clearColor]];
    [likeLabel setFont:[UIFont systemFontOfSize:13]];
    [likeLabel setAlpha:0.0];
    [likeLabel setText:[NSString stringWithFormat:@"%d",[self.data.UserIdsWhoLiked count]]];
    self.numberOfLikesLabel = likeLabel;
    [self.imageView addSubview:likeLabel];
    
//    if ([self.data.view isKindOfClass:[UIButton class]])
//    {
//        [self addSubview:self.data.view];
//    }
    
    // Adjusting the x coordinate for avatar
    if (self.showAvatar && [self.data.view isKindOfClass:[UILabel class]])
    {
        [self.avatarImage removeFromSuperview];
#if !__has_feature(objc_arc)
        self.avatarImage = [[[UIImageView alloc] initWithImage:(self.data.avatar ? self.data.avatar : [UIImage imageNamed:@"missingAvatar.png"])] autorelease];
#else
        self.avatarImage = [[UIImageView alloc] initWithImage:(self.data.avatar ? self.data.avatar : [UIImage imageNamed:@"missingAvatar.png"])];
#endif
        self.avatarImage.layer.cornerRadius = 9.0;
        self.avatarImage.layer.masksToBounds = YES;
        self.avatarImage.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.2].CGColor;
        self.avatarImage.layer.borderWidth = 1.0;
        self.avatarImage.contentMode = UIViewContentModeCenter;
        
        CGFloat avatarX = (type == BubbleTypeSomeoneElse) ? 2 : self.frame.size.width - 52;
        CGFloat avatarY = self.frame.size.height - 50;
        
        self.avatarImage.frame = CGRectMake(avatarX, avatarY, 50, 50);
        [self addSubview:self.avatarImage];
        
        if ([self.data.view isKindOfClass:[UILabel class]])
        {
            UILabel *label22 = (UILabel *)self.data.view;
            [label22 setBackgroundColor:[UIColor clearColor]];
            [self addSubview:label22];
        }
        
        CGFloat delta = self.frame.size.height - (self.data.insets.top + self.data.insets.bottom + self.data.view.frame.size.height);
        if (delta > 0) y = delta;
        
        if (type == BubbleTypeSomeoneElse) x += 54;
        if (type == BubbleTypeMine) x -= 54;
    }
    
    if ([self.customView isKindOfClass:[UIImageView class]])
    {
        UIImage* imageBorderImg = [[UIImage imageNamed:@"image_frame.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:24];
        UIImageView* whiteBorderView = [[UIImageView alloc] initWithImage:imageBorderImg];
        int borderX = x;
        if (borderX >0) {
            borderX+=10;
        }
        else {
            borderX+=2;
        }
        whiteBorderView.frame = CGRectMake(borderX+self.data.insets.left - self.data.insets.right, self.data.insets.top - self.data.insets.bottom+4, width + self.data.insets.left + self.data.insets.right-8, height + self.data.insets.top + self.data.insets.bottom-2);
        
        [self.contentView addSubview:whiteBorderView];
    
    }
    
    self.customView.frame = CGRectMake(x + self.data.insets.left, y + self.data.insets.top, width, height);

    if ([self.data.view isKindOfClass:[UILabel class]] == NO)
    {
        [self addSubview:self.customView];
    }
    

    if (type == BubbleTypeSomeoneElse)
    {
        self.bubbleImage.image = [[UIImage imageNamed:@"bubbleSomeone.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:14];

    }
    else {
        self.bubbleImage.image = [[UIImage imageNamed:@"bubbleMine.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:14];
    }

    self.bubbleImage.frame = CGRectMake(x, y, width + self.data.insets.left + self.data.insets.right, height + self.data.insets.top + self.data.insets.bottom);
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake( 54+self.bubbleImage.frame.size.width, self.bubbleImage.frame.origin.y + self.bubbleImage.frame.size.height - 26, 23, 24 ); // your positioning here
    if ([self.data.UserIdsWhoLiked count] > 0)
    {
        [self.numberOfLikesLabel setAlpha:0.7];
        [self.imageView setHidden:NO];
    }
}

@end
