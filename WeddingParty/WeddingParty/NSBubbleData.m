//
//  NSBubbleData.m
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import "NSBubbleData.h"
#import <QuartzCore/QuartzCore.h>

#define kDateKey            @"Date"
#define kBubbleTypeKey      @"BubbleType"
#define kViewKey            @"View"
#define kInsetsKey          @"Insets"
#define kImageKey           @"Image"
#define kUserFullNameKey    @"UserFullName"
#define kUserIdsWhoLikedKey @"UserIdsWhoLiked"
#define kTextKey            @"Text"

@implementation NSBubbleData

#pragma mark - Properties

@synthesize date = _date;
@synthesize type = _type;
@synthesize view = _view;
@synthesize insets = _insets;
@synthesize avatar = _avatar;
@synthesize userFullName = _userFullName;
@synthesize customField = _customField;
@synthesize UserIdsWhoLiked = _UserIdsWhoLiked;
@synthesize text = _text;

#pragma mark - Lifecycle

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [_date release];
	_date = nil;
    [_view release];
    _view = nil;
    
    self.avatar = nil;

    [super dealloc];
}
#endif

#pragma mark - Text bubble

const UIEdgeInsets textInsetsMine = {5, 10, 11, 17};
const UIEdgeInsets textInsetsSomeone = {5, 15, 11, 10};

+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type image:(UIImage *)image username:(NSString *)userFullName userIdsWhoLiked:(NSMutableArray *)UserIdsWhoLiked
{
    return [self dataWithText:text date:date type:type withFont:[UIFont systemFontOfSize:[UIFont systemFontSize]] withFontColor:[UIColor grayColor] image:image username:userFullName userIdsWhoLiked:UserIdsWhoLiked];
}


+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type withFont:(UIFont*)customFont withFontColor:(UIColor*)customColor image:(UIImage *)image username:(NSString *)userFullName userIdsWhoLiked:(NSMutableArray *)UserIdsWhoLiked

{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithText:text date:date type:type withFont:customFont withFontColor:customColor image:image username:userFullName userIdsWhoLiked:UserIdsWhoLiked] autorelease];
#else
    return [[NSBubbleData alloc] initWithText:text date:date type:type withFont:customFont withFontColor:customColor image:image username:userFullName userIdsWhoLiked:UserIdsWhoLiked];
#endif
}

- (id)initWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type withFont:(UIFont*)customFont withFontColor:(UIColor*)customColor image:(UIImage *)image username:(NSString *)userFullName userIdsWhoLiked:(NSMutableArray *)UserIdsWhoLiked
{
    if (customFont == nil) {
            customFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    }
    
    if (customColor == nil) {
        customColor = [UIColor grayColor];
    }
    
    self.text = text;
    
    NSString *tempFormat = [NSString stringWithFormat:@"%@:\n%@",userFullName,text];
    NSMutableAttributedString *userFullNameUnderline = [[NSMutableAttributedString alloc] initWithString:(tempFormat ? tempFormat : @"")];
    int len = (userFullName ? [userFullName length] : 0);
    [userFullNameUnderline addAttribute:NSUnderlineStyleAttributeName value:@1 range:NSMakeRange(0, len)];
    [userFullNameUnderline addAttribute:NSFontAttributeName value:customFont range:NSMakeRange(0, [tempFormat length])];
    
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize size = [(text ? [userFullNameUnderline string] : @"") sizeWithFont:customFont constrainedToSize:CGSizeMake(220, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    [label setFrame:CGRectMake(0, 0, size.width, size.height+10)];
        
    [label setAttributedText:userFullNameUnderline];
    
//    label.text = (text ? text : @"");
//    label.font = customFont;
//    label.textColor = customColor;
//    label.backgroundColor = [UIColor clearColor];
    
#if !__has_feature(objc_arc)
    [label autorelease];
#endif
    
    UIEdgeInsets insets = (type == BubbleTypeMine ? textInsetsMine : textInsetsSomeone);
    return [self initWithView:label date:date text:text type:type insets:insets image:image username:userFullName userIdsWhoLiked:UserIdsWhoLiked];
    
}

- (id)initWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type image:(UIImage *)image username:(NSString *)userFullName userIdsWhoLiked:(NSMutableArray *)UserIdsWhoLiked
{
    UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    return [self initWithText:text date:date type:type withFont:font withFontColor:[UIColor grayColor] image:image username:userFullName userIdsWhoLiked:UserIdsWhoLiked];
}

#pragma mark - Image bubble

const UIEdgeInsets imageInsetsMine = {11, 13, 16, 22};
const UIEdgeInsets imageInsetsSomeone = {11, 18, 16, 14};

+ (id)dataWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type username:(NSString *)userFullName userIdsWhoLiked:(NSMutableArray *)UserIdsWhoLiked
{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithImage:image date:date type:type username:userFullName userIdsWhoLiked:UserIdsWhoLiked] autorelease];
#else
    return [[NSBubbleData alloc] initWithImage:image date:date type:type username:userFullName userIdsWhoLiked:UserIdsWhoLiked];
#endif    
}

- (id)initWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type username:(NSString *)userFullName userIdsWhoLiked:(NSMutableArray *)UserIdsWhoLiked
{
    CGSize size = image.size;
    if (size.width > 220)
    {
        size.height /= (size.width / 220);
        size.width = 220;
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    imageView.image = image;
    
#if !__has_feature(objc_arc)
    [imageView autorelease];
#endif
    
    UIEdgeInsets insets = (type == BubbleTypeMine ? imageInsetsMine : imageInsetsSomeone);
    return [self initWithView:imageView date:date text:nil type:type insets:insets image:image username:userFullName userIdsWhoLiked:UserIdsWhoLiked];
}

#pragma mark - Encoding

- (void) encodeWithCoder:(NSCoder *)encoder {
//    NSLog(@"NSBubbleData encodeWithCoder");
    
    UIEdgeInsets local = self.insets;
    [encoder encodeObject:self.date forKey:kDateKey];
    [encoder encodeObject:self.text forKey:kTextKey];
    [encoder encodeObject:[[NSNumber alloc] initWithInt:self.type] forKey:kBubbleTypeKey];
    [encoder encodeObject:self.view forKey:kViewKey];
    [encoder encodeObject:[NSValue value:&local withObjCType:@encode(UIEdgeInsets)] forKey:kInsetsKey];
    [encoder encodeObject:self.avatar forKey:kImageKey];
    [encoder encodeObject:self.userFullName forKey:kUserFullNameKey];
    [encoder encodeObject:self.UserIdsWhoLiked forKey:kUserIdsWhoLikedKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
//    NSLog(@"NSBubbleData initWithCoder");
    
    NSDate *date = [decoder decodeObjectForKey:kDateKey];
    NSString *text = [decoder decodeObjectForKey:kTextKey];
    NSNumber *typeNumber = [decoder decodeObjectForKey:kBubbleTypeKey];
    NSBubbleType type = [typeNumber intValue];
    UIView *view = [decoder decodeObjectForKey:kViewKey];
    NSValue *insetsValue = [decoder decodeObjectForKey:kInsetsKey];
    UIEdgeInsets localInsets;
    [insetsValue getValue:&localInsets];
    UIImage *image = [decoder decodeObjectForKey:kImageKey];
    NSString *userFullName = [decoder decodeObjectForKey:kUserFullNameKey];
    NSMutableArray *UserIdsWhoLiked = [decoder decodeObjectForKey:kUserIdsWhoLikedKey];
    
    return [self initWithView:view date:date text:text type:type insets:localInsets image:image username:userFullName userIdsWhoLiked:UserIdsWhoLiked];
}



#pragma mark - Custom view bubble

+ (id)dataWithView:(UIView *)view date:(NSDate *)date text:(NSString *)text type:(NSBubbleType)type insets:(UIEdgeInsets)insets image:(UIImage *)image username:(NSString *)userFullName userIdsWhoLiked:(NSMutableArray *)UserIdsWhoLiked
{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithView:view date:date text:text type:type insets:insets image:image username:userFullName userIdsWhoLiked:UserIdsWhoLiked] autorelease];
#else
    return [[NSBubbleData alloc] initWithView:view date:date text:text type:type insets:insets image:image username:userFullName userIdsWhoLiked:UserIdsWhoLiked];
#endif    
}

- (id)initWithView:(UIView *)view date:(NSDate *)date text:(NSString *)text type:(NSBubbleType)type insets:(UIEdgeInsets)insets image:(UIImage *)image username:(NSString *)userFullName userIdsWhoLiked:(NSMutableArray *)UserIdsWhoLiked
{
    self = [super init];
    if (self)
    {
#if !__has_feature(objc_arc)
        _view = [view retain];
        _date = [date retain];
        _userFullName = [userFullName retain];
        _avatar = [image retain];
        _UserIdsWhoLiked = [UserIdsWhoLiked retain];
        _text = text;
#else
        _view = view;
        _date = date;
        _userFullName = userFullName;
        _avatar = image;
        _UserIdsWhoLiked = UserIdsWhoLiked;
        _text = text;
#endif
        _type = type;
        _insets = insets;
    }
    return self;
}

@end
