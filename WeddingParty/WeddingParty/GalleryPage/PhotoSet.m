//
//  PhotoSet.m
//  WeddingParty
//
//  Created by MTG on 5/27/13.
//  Copyright (c) 2013 MTG. All rights reserved.
//

#import "PhotoSet.h"
#import "Photo.h"

#define NUMBER_OF_PICS 44

@implementation PhotoSet
@synthesize title = _title;
@synthesize photos = _photos;

- (id) initWithTitle:(NSString *)title photos:(NSArray *)photos {
    if ((self = [super init])) {
        self.title = title;
        self.photos = photos;
        for(int i = 0; i < _photos.count; ++i) {
            Photo *photo = [_photos objectAtIndex:i];
            photo.photoSource = self;
            photo.index = i;
        }
    }
    return self;
}

- (void) dealloc {
    self.title = nil;
    self.photos = nil;
}

#pragma mark TTModel

- (BOOL)isLoading {
    return FALSE;
}

- (BOOL)isLoaded {
    return TRUE;
}

#pragma mark TTPhotoSource

- (NSInteger)numberOfPhotos {
    return _photos.count;
}

- (NSInteger)maxPhotoIndex {
    return _photos.count-1;
}

- (id<TTPhoto>)photoAtIndex:(NSInteger)photoIndex {
    if (photoIndex < _photos.count) {
        return [_photos objectAtIndex:photoIndex];
    } else {
        return nil;
    }
}

static PhotoSet *samplePhotoSet = nil;

+ (PhotoSet *) samplePhotoSet {
    @synchronized(self) {
        if (samplePhotoSet == nil) {
            
            NSMutableArray *photosArray = [[NSMutableArray alloc] initWithCapacity:NUMBER_OF_PICS];
            for (int fileIndex = 1; fileIndex < NUMBER_OF_PICS; fileIndex++)
            {
                UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg",fileIndex]];
                Photo *photo = [[Photo alloc] initWithCaption:@"" urlLarge:nil urlSmall:[NSString stringWithFormat:@"bundle://%d.jpg",fileIndex] urlThumb:[NSString stringWithFormat:@"bundle://%d.jpg",fileIndex] size:image.size];
                if (photo)
                {
                    [photosArray addObject:photo];
                }
                else
                    NSLog(@"photo == nil");
            }
            
            samplePhotoSet = [[self alloc] initWithTitle:@"Wedding Gallery" photos:photosArray];

//            Photo *mathNinja = [[Photo alloc] initWithCaption:@"Math Ninja"
//                                                      urlLarge:@"http://www.raywenderlich.com/downloads/math_ninja_large.png"
//                                                     urlSmall:@"bundle://math_ninja_small.png"
//                                                      urlThumb:@"bundle://math_ninja_thumb.png"
//                                                          size:CGSizeMake(1024, 768)];
//            Photo *instantPoetry = [[Photo alloc] initWithCaption:@"Instant Poetry"
//                                                          urlLarge:@"http://www.raywenderlich.com/downloads/instant_poetry_large.png"
//                                                          urlSmall:@"bundle://instant_poetry_small.png"
//                                                          urlThumb:@"bundle://instant_poetry_thumb.png"
//                                                              size:CGSizeMake(1024, 748)];
//            Photo *rpgCalc = [[Photo alloc] initWithCaption:@"RPG Calc"
//                                                    urlLarge:@"http://www.raywenderlich.com/downloads/rpg_calc_large.png"
//                                                    urlSmall:@"bundle://rpg_calc_small.png"
//                                                    urlThumb:@"bundle://rpg_calc_thumb.png"
//                                                        size:CGSizeMake(640, 920)];
//            Photo *levelMeUp = [[Photo alloc] initWithCaption:@"Level Me Up"
//                                                      urlLarge:@"http://www.raywenderlich.com/downloads/level_me_up_large.png"
//                                                      urlSmall:@"bundle://level_me_up_small.png"
//                                                      urlThumb:@"bundle://level_me_up_thumb.png"
//                                                          size:CGSizeMake(1024, 768)];
//            NSArray *photos = [NSArray arrayWithObjects:mathNinja, instantPoetry, rpgCalc, levelMeUp, nil];
//            samplePhotoSet = [[self alloc] initWithTitle:@"My Apps" photos:photos];
        }
    }
    return samplePhotoSet;
}




@end