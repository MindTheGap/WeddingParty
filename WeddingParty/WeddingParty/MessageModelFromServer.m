//
//  MessageModelFromServer.m
//  WeddingParty
//
//  Created by MTG on 6/6/13.
//  Copyright (c) 2013 MTG. All rights reserved.
//

#import "MessageModelFromServer.h"

@implementation MessageModelFromServer

#define kMessagesKey       @"Messages"

- (void) encodeWithCoder:(NSCoder *)encoder {
//    NSLog(@"MessageModelFromServer encodeWithCoder");

    [encoder encodeObject:self.MessagesList forKey:kMessagesKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
//    NSLog(@"MessageModelFromServer initWithCoder");

    NSMutableArray *messagesArray = [decoder decodeObjectForKey:kMessagesKey];
    return [self initWithMessages:messagesArray];
}

- (id)initWithMessages:(NSMutableArray *)messages
{
//    NSLog(@"MessageModelFromServer initWithMessages");

    self.MessagesList = messages;
    return self;
}

@end
