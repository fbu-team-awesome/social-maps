//
//  SearchBarView.h
//  social-maps
//
//  Created by Bevin Benson on 8/10/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlaces/GooglePlaces.h>

@protocol SearchBarViewDelegate

- (void)textChanged:(id)sender;
- (void)cancelClicked:(id)sender;

@end

@interface SearchBarView : UIView

@property (nonatomic, weak) id<SearchBarViewDelegate> delegate;

@end
