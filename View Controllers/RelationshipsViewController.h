//
//  RelationshipsViewController.h
//  social-maps
//
//  Created by César Francisco Barraza on 7/19/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum RelationshipType : NSUInteger
{
    RTFollowers,
    RTFollowing
}
RelationshipType;

@interface RelationshipsViewController : UIViewController
- (void)setUser:(PFUser *)user withRelationshipType:(RelationshipType)relationshipType;
@end
