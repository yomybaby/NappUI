//
//  TiUIImageView+IsCustom.h
//  linqlemodule
//
//  Created by yomybaby 
//
//

#import "TiUIView.h"
#import "TiUIListView.h"

@interface TiUIListView (IsCustom) : TiUIView <UITableViewDelegate, UIScrollViewDelegate,  UITableViewDataSource, UIGestureRecognizerDelegate, TiScrolling >{
@private
    UIView * tableHeaderPullView;
    UIView * tableFooterPullView;
}


@end
