//
//  MessageModelToServer
//  WeddingParty
//
//  Created by MTG on 6/4/13.
//  Copyright (c) 2013 MTG. All rights reserved.
//

#import "JSONModel.h"

@interface MessageModelToServer : JSONModel

enum ActionType {
    RetreiveLastMessages,
    RetreivePastMessages,
    PublishMessage
};

@property (strong, nonatomic) NSString* Data;
@property (assign, nonatomic) int Action;
@property (assign, nonatomic) int UserId;
@property (strong, nonatomic) NSString* UserFullName;




@end
