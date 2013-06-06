//
//  MessageModelFromServer.h
//  WeddingParty
//
//  Created by MTG on 6/4/13.
//  Copyright (c) 2013 MTG. All rights reserved.
//

#import "JSONModel.h"

@interface MessageModelFromServer : JSONModel

@property (strong, nonatomic) NSMutableArray *MessagesList;

@property (assign, nonatomic) int Action;

@end
