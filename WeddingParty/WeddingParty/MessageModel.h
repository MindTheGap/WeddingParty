//
//  MessageModel.h
//  WeddingParty
//
//  Created by MTG on 6/4/13.
//  Copyright (c) 2013 MTG. All rights reserved.
//

#import "JSONModel.h"

@interface MessageModel : JSONModel

enum ActionType {
    RetreiveLastMessages,
    RetreivePastMessages,
    PublishMessage
};

@property (assign, nonatomic) int MessageId;

@property (assign, nonatomic) int UserId;

@property (strong, nonatomic) NSString* Data;

@property (assign, nonatomic) int Action;

@end
