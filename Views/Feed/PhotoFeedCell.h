//
//  PhotoFeedCell.h
//  social-maps
//
//  Created by César Francisco Barraza on 8/1/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoAdditionEvent.h"

@interface PhotoFeedCell : UITableViewCell
- (void)setEvent:(PhotoAdditionEvent *)event;
@end
