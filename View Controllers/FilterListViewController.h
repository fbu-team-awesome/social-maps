//
//  FilterListViewController.h
//  social-maps
//
//  Created by Bevin Benson on 7/31/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterDelegate

- (void)filterSelectionDone;

@end

@interface FilterListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id<FilterDelegate> delegate;

@end
