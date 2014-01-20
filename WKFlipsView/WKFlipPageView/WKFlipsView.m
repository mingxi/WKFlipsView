//
//  WKFlipsView.m
//  WKFlipsView
//
//  Created by 秦 道平 on 13-12-9.
//  Copyright (c) 2013年 秦 道平. All rights reserved.
//

#import "WKFlipsView.h"


@implementation WKFlipsView
@dynamic pageIndex;
- (id)initWithFrame:(CGRect)frame atPageIndex:(int)pageIndex withCacheIdentity:(NSString *)cacheIdentity{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _cache=[[_WKFlipsViewCache alloc]initWithIdentity:cacheIdentity];
        _reusedPageViewDictionary=[[NSMutableDictionary alloc]init];
        _currentPageView=[[UIView alloc]initWithFrame:self.bounds];
        [self addSubview:_currentPageView];
        self.pageIndex=pageIndex;
        _flippingLayersView=[[WKFlipsLayerView alloc] initWithFlipsView:self];
        [self addSubview:_flippingLayersView];
        _flippingLayersView.hidden=YES;
        UIPanGestureRecognizer* panGeture=[[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(flippingPanGesture:)] autorelease];
        [self addGestureRecognizer:panGeture];
    }
    return self;
}
-(void)dealloc{
    [_reusedPageViewDictionary release];
    [_currentPageView release];
    [_cache release];
    //[_testCacheView release];
    [super dealloc];
}
#pragma mark - page
-(void)registerClass:(Class)class forPageWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (![class isSubclassOfClass:[WKFlipPageView class]])
        return;
    if (_reusedPageViewDictionary[reuseIdentifier])
        return;
    WKFlipPageView* pageView=[[class alloc]init];
    pageView.frame=self.bounds;
    _reusedPageViewDictionary[reuseIdentifier]=pageView;
    [pageView release];
}
-(WKFlipPageView*)dequeueReusablePageWithReuseIdentifier:(NSString *)reuseIdentifier{
    WKFlipPageView* pageView= _reusedPageViewDictionary[reuseIdentifier];
    [pageView prepareForReuse];
    return pageView;
}
#pragma mark - action
-(void)reloadPages{    
    [_flippingLayersView buildLayers];
}
#pragma mark pageIndex
-(int)pageIndex{
    return _pageIndex;
}
///设置正在显示的页面,会更改正在显示的内容
-(void)setPageIndex:(int)pageIndex{
//    if (_pageIndex && _pageIndex==pageIndex)
//        return;
    for (UIView* view in self.currentPageView.subviews) {
        [view removeFromSuperview];
    }
    _pageIndex=pageIndex;
    ///这里的pageView也从deque中获取，所以是一个实例，如果其他地方在创建贴图时也调用了下面这个方法，会导致实例进行更新，所以正在实际显示的页面会被修改.这就要求，在设置pageIndex的前面就应该调用完成创建贴图的过程
    if (pageIndex>=0 && pageIndex<[self.dataSource numberOfPagesForFlipsView:self]){
        WKFlipPageView* pageView=[self.dataSource flipsView:self pageAtPageIndex:pageIndex];
        ///TODO:这里可能需要禁止动画
        [self.currentPageView addSubview:pageView];
    }
}
-(WKFlipPageView*)currentFlipPageView{
    if(self.currentPageView.subviews.count>0){
        return (WKFlipPageView*)self.currentPageView.subviews[0];
    }
    return nil;
}
-(void)flipToPageIndex:(int)pageIndex{
    if (pageIndex<0 || pageIndex>=[self.dataSource numberOfPagesForFlipsView:self]){
        return;
    }
    [_flippingLayersView flipToPageIndex:pageIndex];
}
-(void)flipToPageIndex:(int)pageIndex completion:(void (^)())completion{
    if (pageIndex<0 || pageIndex>=[self.dataSource numberOfPagesForFlipsView:self]){
        return;
    }
    [_flippingLayersView flipToPageIndex:pageIndex completion:^(BOOL completed) {
    }];
}
#pragma mark create update and detele
-(void)deleteCurrentPage{
    ///删除数据
    [self.delegate flipwView:self willDeletePageAtPageIndex:self.pageIndex];
    ///删除缓存
    [self.cache removeAtPageIndex:self.pageIndex];
    ///重建页面
    [self reloadPages];
}
#pragma mark - cache
#pragma mark - touches
-(void)flippingPanGesture:(UIPanGestureRecognizer*)recognizer{
    if (recognizer.state==UIGestureRecognizerStateBegan){
        [self.flippingLayersView dragBegan];
    }
    else if (recognizer.state==UIGestureRecognizerStateCancelled|| recognizer.state==UIGestureRecognizerStateEnded){
        [self.flippingLayersView dragEnded];
    }
    else if (recognizer.state==UIGestureRecognizerStateChanged){
        CGPoint translation=[recognizer translationInView:self];
        [self.flippingLayersView draggingWithTranslation:translation];
    }
}
#pragma mark - Test
///更新换乘图片显示
//-(void)_test_update_cache_for_page:(WKFlipPageView*)pageView{
//    for (UIView* view in _testCacheView.subviews) {
//        [view removeFromSuperview];
//    }
//    UIImageView* imageViewTop=[[[UIImageView alloc]initWithImage:pageView.cacheImageHTop] autorelease];
//    CGRect imageViewTopFrame=imageViewTop.frame;
//    imageViewTopFrame.origin.x=100.0f;
//    imageViewTopFrame.origin.y=200.0f;
//    imageViewTop.frame=imageViewTopFrame;
//    [_testCacheView addSubview:imageViewTop];
//    UIImageView* imageViewBottom=[[[UIImageView alloc]initWithImage:pageView.cacheImageHBottom] autorelease];
//    CGRect imageViewBottomFrame=imageViewBottom.frame;
//    imageViewBottomFrame.origin.x=100.0f;
//    imageViewBottomFrame.origin.y=CGRectGetMaxY(imageViewTopFrame);
//    imageViewBottom.frame=imageViewBottomFrame;
//    [_testCacheView addSubview:imageViewBottom];
//}
@end
