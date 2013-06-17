//
//  UINavigationController+autototate.m
//  WeddingParty
//
//  Created by MTG on 6/17/13.
//  Copyright (c) 2013 MTG. All rights reserved.
//

#import "UINavigationController+autototate.h"

@implementation UINavigationController (autototate)

- (BOOL)shouldAutorotate
{
    return [[self.viewControllers lastObject] shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

@end
