//
//  TiUIImageView+IsCustom.m
//  linqlemodule
//
//  Created by yomybaby
//
//

#import "TiUIListViewProxy+IsCustom.h"

@implementation TiUIListViewProxy (IsCustom)

-(void)refreshFinish:(id)args
{
    TiThreadPerformOnMainThread(^{[(TiUIListView*)[self view] refreshFinish:args];}, NO);
}

-(void)refreshStart:(id)args
{
    TiThreadPerformOnMainThread(^{[(TiUIListView*)[self view] refreshStart];}, NO);
}

-(void)setContentInsets:(id)args
{
	ENSURE_UI_THREAD(setContentInsets,args);
	id arg1;
	id arg2;
	if ([args isKindOfClass:[NSDictionary class]])
	{
		arg1 = args;
		arg2 = [NSDictionary dictionary];
	}
	else
	{
		arg1 = [args objectAtIndex:0];
		arg2 = [args count] > 1 ? [args objectAtIndex:1] : [NSDictionary dictionary];
	}
	[[self view] performSelector:@selector(setContentInsets_:withObject:) withObject:arg1 withObject:arg2];
}

@end
