//
//  NSBubbleData.h
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <Foundation/Foundation.h>

typedef enum _NSBubbleType
{
    BubbleTypeMine = 0,
    BubbleTypeSomeoneElse = 1
} NSBubbleType;

@interface NSBubbleData : NSObject

@property (readonly, nonatomic, strong) NSDate *date;
@property (readonly, nonatomic) NSBubbleType type;
@property (readonly, nonatomic, strong) UIView *view;
@property (readonly, nonatomic) UIEdgeInsets insets;
@property (strong, nonatomic) NSString *userFullName;
@property (strong, nonatomic) UIImage *avatar;
@property (nonatomic, strong) NSObject *customField;
@property (strong, nonatomic) NSMutableArray *UserIdsWhoLiked;
@property (strong, nonatomic) NSString *text;

- (id)initWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type image:(UIImage *)image username:(NSString *)userFullName userIdsWhoLiked:(NSMutableArray *)UserIdsWhoLiked;
- (id)initWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type withFont:(UIFont*)customFont withFontColor:(UIColor*)color image:(UIImage *)image username:(NSString *)userFullName userIdsWhoLiked:(NSMutableArray *)UserIdsWhoLiked;
+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type image:(UIImage *)image username:(NSString *)userFullName userIdsWhoLiked:(NSMutableArray *)UserIdsWhoLiked;
+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type withFont:(UIFont*)customFont withFontColor:(UIColor*)color image:(UIImage *)image username:(NSString *)userFullName userIdsWhoLiked:(NSMutableArray *)UserIdsWhoLiked;
- (id)initWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type username:(NSString *)userFullName userIdsWhoLiked:(NSMutableArray *)UserIdsWhoLiked;
+ (id)dataWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type username:(NSString *)userFullName userIdsWhoLiked:(NSMutableArray *)UserIdsWhoLiked;
- (id)initWithView:(UIView *)view date:(NSDate *)date text:(NSString *)text type:(NSBubbleType)type insets:(UIEdgeInsets)insets image:(UIImage *)image username:(NSString *)userFullName userIdsWhoLiked:(NSMutableArray *)UserIdsWhoLiked;
+ (id)dataWithView:(UIView *)view date:(NSDate *)date text:(NSString *)text type:(NSBubbleType)type insets:(UIEdgeInsets)insets image:(UIImage *)image username:(NSString *)userFullName userIdsWhoLiked:(NSMutableArray *)UserIdsWhoLiked;

@end
