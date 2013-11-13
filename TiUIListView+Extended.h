//
//  TiUIListView.h
//  nappui
//
//  Created by JongEun Lee on 13. 11. 13..
//
//

#import "TiBase.h"
#import "TiUIListView.h"
#import "TiUIListViewProxy.h"

@interface TiUIListView (Extended) <UITableViewDelegate, UIScrollViewDelegate,  UITableViewDataSource, UIGestureRecognizerDelegate, TiScrolling >

@property (nonatomic, retain) UIView * tableHeaderPullView;
@property (nonatomic, retain) UIView * tableFooterPullView;

@end