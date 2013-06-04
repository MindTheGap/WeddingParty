//
//  PhotoSet.h
//  WeddingParty
//
//  Created by MTG on 5/27/13.
//  Copyright (c) 2013 MTG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Three20/Three20.h"

@interface PhotoSet : TTURLRequestModel <TTPhotoSource> {
    NSString *_title;
    NSArray *_photos;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, retain) NSArray *photos;

+ (PhotoSet *)samplePhotoSet;

@end