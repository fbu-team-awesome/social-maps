//
//  MapMarkerWindow.m
//  social-maps
//
//  Created by Britney Phan on 7/26/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "MapMarkerWindow.h"

@implementation MapMarkerWindow 

- (IBAction)didTapView:(id)sender {
    [self.delegate didTapInfo:self.place];
}

+ (UIView *) instanceFromNib{
    return (UIView *)[[NSBundle mainBundle] loadNibNamed:@"MarkerWindow" owner:self options:nil];
}

@end
