//
//  ResultsTableViewController.h
//  social-maps
//
//  Created by Britney Phan on 7/18/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlaces/GooglePlaces.h>
@protocol ResultsViewDelegate;

@interface ResultsTableViewController : UIViewController
@property (strong,nonatomic) id<ResultsViewDelegate> delegate;

@end


@protocol ResultsViewDelegate
-(void) didSelectPlace: (GMSPlace *) place;
@end
