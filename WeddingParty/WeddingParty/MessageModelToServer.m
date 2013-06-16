//
//  MessageModel.m
//  WeddingParty
//
//  Created by MTG on 6/4/13.
//  Copyright (c) 2013 MTG. All rights reserved.
//

#import "MessageModelToServer.h"

@implementation MessageModelToServer

#define kDataKey            @"Data"
#define kActionKey          @"Action"
#define kUserIdKey          @"UserId"
#define kUserFullNameKey    @"UserFullName"
#define kUserIdsWhoLikedKey @"UserIdsWhoLiked"

- (void) encodeWithCoder:(NSCoder *)encoder {
//    NSLog(@"MessageModelToServer encodeWithCoder");

    [encoder encodeObject:self.Data forKey:kDataKey];
    [encoder encodeObject:[[NSNumber alloc] initWithInt:self.Action] forKey:kActionKey];
    [encoder encodeObject:self.UserId forKey:kUserIdKey];
    [encoder encodeObject:self.UserFullName forKey:kUserFullNameKey];
    [encoder encodeObject:self.UserIdsWhoLiked forKey:kUserIdsWhoLikedKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
//    NSLog(@"MessageModelToServer initWithCoder");
    NSString *Data = [decoder decodeObjectForKey:kDataKey];
    NSNumber *Action = [decoder decodeObjectForKey:kActionKey];
    NSString *UserId = [decoder decodeObjectForKey:kUserIdKey];
    NSString *UserFullName = [decoder decodeObjectForKey:kUserFullNameKey];
    NSMutableArray *UserIdsWhoLiked = [decoder decodeObjectForKey:kUserIdsWhoLikedKey];
    return [self initWithData:Data action:[Action intValue] userId:UserId userFullName:UserFullName userIdsWhoLiked:UserIdsWhoLiked];
}

- (id)initWithData:(NSString *)data action:(int)action userId:(NSString *)userId userFullName:(NSString *)userFullName userIdsWhoLiked:(NSMutableArray *)UserIdsWhoLiked
{
//    NSLog(@"MessageModelToServer initWithData");

    self.Data = data;
    self.Action = action;
    self.UserId = userId;
    self.UserFullName = userFullName;
    self.UserIdsWhoLiked = UserIdsWhoLiked;
    return self;
}

@end
