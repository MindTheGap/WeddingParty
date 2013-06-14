//
//  MessageModelToServer
//  WeddingParty
//
//  Created by MTG on 6/4/13.
//  Copyright (c) 2013 MTG. All rights reserved.
//

#import "JSONModel.h"

@interface MessageModelToServer : JSONModel <NSCoding>

enum ActionType {
    RetreiveLastMessages,
    RetreivePastMessages,
    PublishMessage,
    AddLike
};

@property (strong, nonatomic) NSString* Data;
@property (assign, nonatomic) int Action;
@property (strong, nonatomic) NSString *UserId;
@property (strong, nonatomic) NSString* UserFullName;
@property (strong, nonatomic) NSMutableArray *UserIdsWhoLiked;




@end
