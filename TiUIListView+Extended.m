//
//  TiUIListView.m
//  nappui
//
//  Created by JongEun Lee on 13. 11. 13..
//
//

#import "JRSwizzle.h"
#import <objc/runtime.h>
#import "TiUIListView+Extended.h"
static char const * const ObjectHeaderTagKey = "ObjectHeaderTag";
static char const * const ObjectFooterTagKey = "ObjectFooterTag";

@interface TiUIListView ()
-(void)dealloc;
@end


@implementation TiUIListView (Extended)
@dynamic tableFooterPullView;
@dynamic tableHeaderPullView;


- (id)tableFooterPullView{
    return objc_getAssociatedObject(self, ObjectFooterTagKey);
}

- (void)setTableFooterPullView:(id)footerPullView{
    objc_setAssociatedObject(self, ObjectFooterTagKey, footerPullView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)tableHeaderPullView{
    return objc_getAssociatedObject(self, ObjectHeaderTagKey);
}

- (void)setTableHeaderPullView:(id)headerPullView{
    objc_setAssociatedObject(self, ObjectHeaderTagKey, headerPullView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)load{
//    Method original, swizzled;
//    original = class_getInstanceMethod(self, @selector(dealloc));
//    swizzled = class_getInstanceMethod(self, @selector(swizzeld_dealloc));
//    method_exchangeImplementations(original, swizzled);
    
    NSError *error = nil;
    [TiUIListView jr_swizzleMethod:@selector(dealloc) withMethod:@selector(swizzeld_dealloc) error:&error];
    
    if (error != nil) {
        NSLog(@"[ERROR] %@", [error localizedDescription]);
    }
    
    
    NSLog(@"[DEBUG] ListView load - swizzeld");
}



- (void)swizzeld_dealloc
{
    NSLog(@"[DEBUG] ListView dealloc - swizzeld");
    RELEASE_TO_NIL(self.tableHeaderPullView);
    RELEASE_TO_NIL(self.tableFooterPullView);
    [self dealloc];
}

- (void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    [super frameSizeChanged:frame bounds:bounds];
    
    if (self.tableHeaderPullView!=nil)
    {
        self.tableHeaderPullView.frame = CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height);
        TiViewProxy *proxy = [self.proxy valueForUndefinedKey:@"headerPullView"];
        [TiUtils setView:[proxy view] positionRect:[self.tableHeaderPullView bounds]];
        [proxy windowWillOpen];
        [proxy layoutChildren:NO];
    }
    
    if( self.tableFooterPullView!=nil)
    {
        self.tableFooterPullView.frame = CGRectMake(0.0f, MAX(self.tableView.bounds.size.height,[self sizeForTableView:self.tableView])-10, self.tableView.bounds.size.width, self.tableView.bounds.size.height);
        TiViewProxy *proxy = [self.proxy valueForUndefinedKey:@"footerPullView"];
        [TiUtils setView:[proxy view] positionRect:[self.tableFooterPullView bounds]];
        [proxy windowWillOpen];
        [proxy layoutChildren:NO];
    }
}

UIRefreshControl *_refreshControl = nil;

-(void)setRefreshControl_:(id)args
{
    BOOL isRefreshControl = [TiUtils boolValue:args def:NO];
    
    if (isRefreshControl == YES)
    {
        //        if(_refreshControl == nil){
        _refreshControl = [[[UIRefreshControl alloc]init] autorelease];
        [_refreshControl addTarget:self action:@selector(refreshStart) forControlEvents:UIControlEventValueChanged];
        [[self tableView] addSubview:_refreshControl];
        //        }
    }else {
        if(_refreshControl !=nil ){
            [_refreshControl removeFromSuperview];
            RELEASE_TO_NIL(_refreshControl);
        }
    }
}

-(void)setRefreshControlColor_:(id)args
{
    TiColor *val = [TiUtils colorValue:args];
    
    if (val != nil)
    {
        _refreshControl.tintColor = [[val _color] retain];
    }
}

-(void)refreshStart:(id)args
{
    [_refreshControl beginRefreshing];
    
    if ([self.proxy _hasListeners:@"refreshstart"])
    {
        [self.proxy fireEvent:@"refreshstart"];
    }
}

-(void)refreshStart
{
    [_refreshControl beginRefreshing];
    
    if (self.tableView.contentOffset.y == 0) {
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(void){
            
            self.tableView.contentOffset = CGPointMake(0, -_refreshControl.frame.size.height);
            
        } completion:^(BOOL finished){
            
        }];
        
    }
    
    if ([self.proxy _hasListeners:@"refreshstart"])
    {
        [self.proxy fireEvent:@"refreshstart"];
    }
}

-(void)refreshFinish:(id)args
{
    [_refreshControl endRefreshing];
}

-(void)setScrollable_:(id)args
{
	UITableView *table = [self tableView];
	[table setScrollEnabled:[TiUtils boolValue:args]];
}

-(void)setSeparatorStyle_:(id)arg
{
	[[self tableView] setSeparatorStyle:[TiUtils intValue:arg]];
}

-(void)setSeparatorColor_:(id)arg
{
	TiColor *color = [TiUtils colorValue:arg];
	[[self tableView] setSeparatorColor:[color _color]];
}



-(void)setHeaderPullView_:(id)value
{
	ENSURE_TYPE_OR_NIL(value,TiViewProxy);
	if (value==nil)
	{
		[self.tableHeaderPullView removeFromSuperview];
		RELEASE_TO_NIL(self.tableHeaderPullView);
	}
	else
	{
        if (self.tableView.frame.size.width==0)
        {
            [self performSelector:@selector(setHeaderPullView_:) withObject:value afterDelay:0.1];
            return;
        }
		self.tableHeaderPullView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
		self.tableHeaderPullView.backgroundColor = [UIColor clearColor];
		UIView *view = [value view];
		[[self tableView] addSubview:self.tableHeaderPullView];
		[self.tableHeaderPullView addSubview:view];
		[TiUtils setView:view positionRect:[self.tableHeaderPullView bounds]];
		[value windowWillOpen];
		[value layoutChildren:NO];
	}
}

-(void)setContentInsets_:(id)value withObject:(id)props
{
	UIEdgeInsets insets = [TiUtils contentInsets:value];
	BOOL animated = [TiUtils boolValue:@"animated" properties:props def:NO];
    void (^setInset)(void) = ^{
        [self.tableView setContentInset:insets];
    };
    if (animated) {
        double duration = [TiUtils doubleValue:@"duration" properties:props def:300]/1000;
        [UIView animateWithDuration:duration animations:setInset];
    }
    else {
        setInset();
    }
}


#define CGSizesMaxWidth(sz1, sz2)             MAX((sz1).width, (sz2).width)
#define CGSizesAddHeights(sz1, sz2)           (sz1).height + (sz2).height

- (CGFloat)sizeForTableView:(UITableView *)tableView {
    CGSize tableViewSize = CGSizeMake(0, 0);
    NSInteger numberOfSections = [tableView numberOfSections];
    for (NSInteger section = 0; section < numberOfSections; section++) {
        // Factor in the size of the section header
        CGRect rect = [tableView rectForHeaderInSection:section];
        tableViewSize = CGSizeMake(CGSizesMaxWidth(tableViewSize, rect.size), CGSizesAddHeights(tableViewSize, rect.size));
        
        // Factor in the size of the section
        rect = [tableView rectForSection:section];
        tableViewSize = CGSizeMake(CGSizesMaxWidth(tableViewSize, rect.size), CGSizesAddHeights(tableViewSize, rect.size));
        
        // Factor in the size of the footer
        rect = [tableView rectForFooterInSection:section];
        tableViewSize = CGSizeMake(CGSizesMaxWidth(tableViewSize, rect.size), CGSizesAddHeights(tableViewSize, rect.size));
    }
    return tableViewSize.height;
}

-(void)setFooterPullView_:(id)value
{
	ENSURE_TYPE_OR_NIL(value,TiViewProxy);
	if (value==nil)
	{
		[self.tableFooterPullView removeFromSuperview];
		RELEASE_TO_NIL(self.tableFooterPullView);
	}
	else
	{
        if (self.tableView.frame.size.width==0)
        {
            [self performSelector:@selector(setFooterPullView_:) withObject:value afterDelay:0.1];
            return;
        }
		self.tableFooterPullView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, MAX(self.tableView.bounds.size.height,[self sizeForTableView:self.tableView])-10, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
		self.tableFooterPullView.backgroundColor = [UIColor clearColor];
        self.tableFooterPullView.userInteractionEnabled = NO;
		UIView *view = [value view];
		[[self tableView] addSubview:self.tableFooterPullView];
		[self.tableFooterPullView addSubview:view];
		[TiUtils setView:view positionRect:[self.tableFooterPullView bounds]];
		[value windowWillOpen];
		[value layoutChildren:NO];
	}
}

#pragma Scroll View Delegate

- (NSDictionary *) eventObjectForScrollView: (UIScrollView *) scrollView
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[TiUtils pointToDictionary:scrollView.contentOffset],@"contentOffset",
			[TiUtils sizeToDictionary:scrollView.contentSize], @"contentSize",
			[TiUtils sizeToDictionary:self.tableView.bounds.size], @"size",
			nil];
}

- (void)fireScrollEvent:(UIScrollView *)scrollView {
	if ([self.proxy _hasListeners:@"scroll"])
	{
		[self.proxy fireEvent:@"scroll" withObject:[self eventObjectForScrollView:scrollView]];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (scrollView.isDragging || scrollView.isDecelerating)
	{
        [self fireScrollEvent:scrollView];
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    [self fireScrollEvent:scrollView];
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if([self.proxy _hasListeners:@"dragstart"])
	{
        [self.proxy fireEvent:@"dragstart" withObject:nil];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if ([self.proxy _hasListeners:@"dragend"])
	{
		[self.proxy fireEvent:@"dragend" withObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:decelerate],@"decelerate",nil]]	;
	}
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	if ([self.proxy _hasListeners:@"scrollend"])
	{
		[self.proxy fireEvent:@"scrollend" withObject:[self eventObjectForScrollView:scrollView]];
	}
}



@end
