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

@implementation NSBubbleData

#pragma mark - Properties

@synthesize date = _date;
@synthesize type = _type;
@synthesize view = _view;
@synthesize insets = _insets;
@synthesize avatar = _avatar;
@synthesize userFullName = _userFullName;
@synthesize customField = _customField;

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

+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type image:(UIImage *)image username:(NSString *)userFullName
{
    return [self dataWithText:text date:date type:type withFont:[UIFont systemFontOfSize:[UIFont systemFontSize]] withFontColor:[UIColor grayColor] image:image username:userFullName];
}


+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type withFont:(UIFont*)customFont withFontColor:(UIColor*)customColor image:(UIImage *)image username:(NSString *)userFullName

{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithText:text date:date type:type withFont:customFont withFontColor:customColor image:image username:userFullName] autorelease];
#else
    return [[NSBubbleData alloc] initWithText:text date:date type:type withFont:customFont withFontColor:customColor image:image username:userFullName];
#endif
}

- (id)initWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type withFont:(UIFont*)customFont withFontColor:(UIColor*)customColor image:(UIImage *)image username:(NSString *)userFullName
{
    if (customFont == nil) {
            customFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    }
    
    if (customColor == nil) {
        customColor = [UIColor grayColor];
    }
    
    CGSize size = [(text ? text : @"") sizeWithFont:customFont constrainedToSize:CGSizeMake(220, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.text = (text ? text : @"");
    label.font = customFont;
    label.textColor = customColor;
    label.backgroundColor = [UIColor clearColor];
    
#if !__has_feature(objc_arc)
    [label autorelease];
#endif
    
    UIEdgeInsets insets = (type == BubbleTypeMine ? textInsetsMine : textInsetsSomeone);
    return [self initWithView:label date:date type:type insets:insets image:image username:userFullName];
    
}

- (id)initWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type image:(UIImage *)image username:(NSString *)userFullName
{
    UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    return [self initWithText:text date:date type:type withFont:font withFontColor:[UIColor grayColor] image:image username:userFullName];
}

#pragma mark - Image bubble

const UIEdgeInsets imageInsetsMine = {11, 13, 16, 22};
const UIEdgeInsets imageInsetsSomeone = {11, 18, 16, 14};

+ (id)dataWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type username:(NSString *)userFullName
{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithImage:image date:date type:type username:userFullName] autorelease];
#else
    return [[NSBubbleData alloc] initWithImage:image date:date type:type username:userFullName];
#endif    
}

- (id)initWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type username:(NSString *)userFullName 
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
    return [self initWithView:imageView date:date type:type insets:insets image:image username:userFullName];
}

#pragma mark - Encoding

- (void) encodeWithCoder:(NSCoder *)encoder {
    NSLog(@"NSBubbleData encodeWithCoder");
    
    UIEdgeInsets local = self.insets;
    [encoder encodeObject:self.date forKey:kDateKey];
    [encoder encodeObject:[[NSNumber alloc] initWithInt:self.type] forKey:kBubbleTypeKey];
    [encoder encodeObject:self.view forKey:kViewKey];
    [encoder encodeObject:[NSValue value:&local withObjCType:@encode(UIEdgeInsets)] forKey:kInsetsKey];
    [encoder encodeObject:self.avatar forKey:kImageKey];
    [encoder encodeObject:self.userFullName forKey:kUserFullNameKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSLog(@"NSBubbleData initWithCoder");
    
    NSDate *date = [decoder decodeObjectForKey:kDateKey];
    NSNumber *typeNumber = [decoder decodeObjectForKey:kBubbleTypeKey];
    NSBubbleType type = [typeNumber intValue];
    UIView *view = [decoder decodeObjectForKey:kViewKey];
    NSValue *insetsValue = [decoder decodeObjectForKey:kInsetsKey];
    UIEdgeInsets localInsets;
    [insetsValue getValue:&localInsets];
    UIImage *image = [decoder decodeObjectForKey:kImageKey];
    NSString *userFullName = [decoder decodeObjectForKey:kUserFullNameKey];
    
    return [self initWithView:view date:date type:type insets:localInsets image:image username:userFullName];
}



#pragma mark - Custom view bubble

+ (id)dataWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets image:(UIImage *)image username:(NSString *)userFullName
{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithView:view date:date type:type insets:insets image:image username:userFullName] autorelease];
#else
    return [[NSBubbleData alloc] initWithView:view date:date type:type insets:insets image:image username:userFullName];
#endif    
}

- (id)initWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets image:(UIImage *)image username:(NSString *)userFullName
{
    self = [super init];
    if (self)
    {
#if !__has_feature(objc_arc)
        _view = [view retain];
        _date = [date retain];
        _userFullName = [userFullName retain];
        _avatar = [image retain];
#else
        _view = view;
        _date = date;
        _userFullName = userFullName;
        _avatar = image;
#endif
        _type = type;
        _insets = insets;
    }
    return self;
}

@end
