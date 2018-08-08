//
//  Photo.m
//  social-maps
//
//  Created by Britney Phan on 8/2/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "Photo.h"
#import "PFUser+ExtendedUser.h"
#import "ParseImageHelper.h"

@interface Photo ()

@property (nonatomic, readwrite, nullable) UIImage *image;
@property (nonatomic, readwrite, nullable) NSData *imageData;
@property (nonatomic, readwrite, nullable) UIImage *placeholderImage;
@property (nonatomic, readwrite, nullable) NSAttributedString *attributedCaptionTitle;
@property (nonatomic, readwrite, nullable) NSAttributedString *attributedCaptionSummary;
@property (nonatomic, readwrite, nullable) NSAttributedString *attributedCaptionCredit;

@end

@implementation Photo

- (nonnull instancetype) initWithPFFile:(PFFile *)file userObjectId:(NSString *)objectId {
    Photo *newPhoto = [Photo new];
    newPhoto.file = file;
    newPhoto.userObjectId = objectId;
    
    [file getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        newPhoto.imageData = data;
        newPhoto.image = [UIImage imageWithData:data];
    }];
    newPhoto.placeholderImage = nil;
    NSDictionary *attrs= @{
                           NSForegroundColorAttributeName: [UIColor whiteColor],
                           NSFontAttributeName: [UIFont fontWithName:@"Avenir Next" size:18.0]
                           };
    newPhoto.attributedCaptionTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Uploaded by %@",[PFUser retrieveUserWithId:objectId].displayName] attributes: attrs ];

    newPhoto.attributedCaptionSummary = nil;
    newPhoto.attributedCaptionCredit = nil;
    
    return newPhoto;
}

@end
