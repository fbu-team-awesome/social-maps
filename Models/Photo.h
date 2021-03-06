//
//  Photo.h
//  social-maps
//
//  Created by Britney Phan on 8/2/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <NYTPhotoViewer/NYTPhoto.h>

@interface Photo : NSObject <NYTPhoto>

@property (strong, nonatomic, nonnull) PFFile *file;
@property (strong, nonatomic, nonnull) NSString *userObjectId;

- (nonnull instancetype) initWithPFFile:(nonnull PFFile *)file userObjectId:(nonnull NSString *)objectId;

@end
