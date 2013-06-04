//
//  GalleryPageInterface.m
//  WeddingParty
//
//  Created by MTG on 5/26/13.
//  Copyright (c) 2013 MTG. All rights reserved.
//

#import "Photo.h"

@interface Photo ()

@end

@implementation Photo

@synthesize caption;
@synthesize urlLarge;
@synthesize urlSmall;
@synthesize urlThumb;
@synthesize photoSource;
@synthesize size;
@synthesize index;

- (id)initWithCaption:(NSString *)Acaption urlLarge:(NSString *)AurlLarge urlSmall:(NSString *)AurlSmall urlThumb:(NSString *)AurlThumb size:(CGSize)Asize {
    if ((self = [super init])) {
        self.caption = Acaption;
        self.urlLarge = AurlLarge;
        self.urlSmall = AurlSmall;
        self.urlThumb = AurlThumb;
        self.size = Asize;
        self.index = NSIntegerMax;
        self.photoSource = nil;
    }
    return self;
}

- (void) dealloc {
    self.caption = nil;
    self.urlLarge = nil;
    self.urlSmall = nil;
    self.urlThumb = nil;
}

#pragma mark TTPhoto

- (NSString*)URLForVersion:(TTPhotoVersion)version {
    switch (version) {
        case TTPhotoVersionLarge:
            return self.urlLarge;
        case TTPhotoVersionMedium:
            return self.urlLarge;
        case TTPhotoVersionSmall:
            return self.urlSmall;
        case TTPhotoVersionThumbnail:
            return self.urlThumb;
        default:
            return nil;
    }
}

@end