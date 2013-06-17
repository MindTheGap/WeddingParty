//
//  UINavigationController+autototate.h
//  WeddingParty
//
//  Created by MTG on 6/17/13.
//  Copyright (c) 2013 MTG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (autototate)

- (BOOL)shouldAutorotate;
- (NSUInteger)supportedInterfaceOrientations;

@end
