//
//  Photo.m
//  social-maps
//
//  Created by Britney Phan on 8/2/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "Photo.h"

@implementation Photo

- (nonnull instancetype) initWithPFFile:(PFFile *)file userObjectId:(NSString *)objectId {
    Photo *newPhoto = [Photo new];
    newPhoto.file = file;
    newPhoto.userObjectId = objectId;
    
    return newPhoto;
}

@end
