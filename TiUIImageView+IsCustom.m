//
//  TiUIImageView+IsCustom.m
//  linqlemodule
//
//  Created by yomybaby on 12. 12. 13..
//
//

#import "TiUIImageView+IsCustom.h"

@implementation TiUIImageView (IsCustom)

-(UIViewContentMode)contentModeForImageView
{
    
    NSString * modestr = [TiUtils stringValue:[self.proxy valueForKey:@"contentMode"]];
    if(modestr)
    {
        if ([@"aspectfit" isEqualToString:modestr]) {
            return UIViewContentModeScaleAspectFit;
        }
        else if ([@"aspectfill" isEqualToString:modestr]) {
            imageView.clipsToBounds = YES;
            return UIViewContentModeScaleAspectFill;
        }
        else if ([@"center" isEqualToString:modestr]) {
            imageView.clipsToBounds = YES;
            return UIViewContentModeCenter;
        }
        else {
            return UIViewContentModeScaleAspectFit;
        }
    }
    
    
    if (TiDimensionIsAuto(width) || TiDimensionIsAutoSize(width) || TiDimensionIsUndefined(width) ||
        TiDimensionIsAuto(height) || TiDimensionIsAutoSize(height) || TiDimensionIsUndefined(height)) {
        return UIViewContentModeScaleAspectFit;
    }
    else {
        return UIViewContentModeScaleToFill;
    }
}

@end
