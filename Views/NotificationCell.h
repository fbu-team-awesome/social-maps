//
//  NotificationCell.h
//  social-maps
//
//  Created by César Francisco Barraza on 8/6/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FollowEvent.h"

@interface NotificationCell : UITableViewCell
- (void)setEvent:(FollowEvent *)event;
@end
