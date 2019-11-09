//
//  YBIBToolCustomHandler.m
//  YBImageBrowserDemo
//
//  Created by Zomfice on 2019/11/9.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "YBIBToolCustomHandler.h"
#import "YBIBImageData.h"
#import "YBIBUtilities.h"
#import "YBIBCopywriter.h"

@interface YBIBToolCustomHandler ()
@property (nonatomic, strong) UIPageControl * pageControl;
@property (nonatomic, strong) YBIBSheetView *sheetView;
@property (nonatomic, strong) YBIBSheetAction *saveAction;
@end

@implementation YBIBToolCustomHandler

@synthesize yb_containerView = _yb_containerView;
@synthesize yb_currentData = _yb_currentData;
@synthesize yb_containerSize = _yb_containerSize;
@synthesize yb_currentPage = _yb_currentPage;
@synthesize yb_totalPage = _yb_totalPage;
@synthesize yb_currentOrientation = _yb_currentOrientation;

- (void)yb_containerViewIsReadied {
    [self.yb_containerView addSubview:self.pageControl];
    CGSize size = self.yb_containerSize(self.yb_currentOrientation());
    UIEdgeInsets padding = YBIBPaddingByBrowserOrientation(self.yb_currentOrientation());
    self.pageControl.center = CGPointMake(size.width / 2.0, size.height - padding.bottom - 20);
}

- (void)yb_hide:(BOOL)hide {
    YBIBImageData *data = self.yb_currentData();
    if (hide) {
        self.pageControl.hidden = YES;
    } else {
        self.pageControl.hidden = NO;
    }
}

- (BOOL)currentDataShouldHideSaveButton {
    id<YBIBDataProtocol> data = self.yb_currentData();
    BOOL allow = [data respondsToSelector:@selector(yb_allowSaveToPhotoAlbum)] && [data yb_allowSaveToPhotoAlbum];
    BOOL can = [data respondsToSelector:@selector(yb_saveToPhotoAlbum)];
    return !(allow && can);
}

- (void)showSheetView {
    if ([self currentDataShouldHideSaveButton]) {
        [self.sheetView.actions removeObject:self.saveAction];
    } else {
        if (![self.sheetView.actions containsObject:self.saveAction]) {
            [self.sheetView.actions addObject:self.saveAction];
        }
    }
    [self.sheetView showToView:self.yb_containerView orientation:self.yb_currentOrientation()];
}

- (void)yb_respondsToLongPress {
    [self showSheetView];
}

- (void)yb_pageChanged {
    self.pageControl.numberOfPages = self.yb_totalPage();
    self.pageControl.currentPage = self.yb_currentPage();
}

- (void)yb_orientationWillChangeWithExpectOrientation:(UIDeviceOrientation)orientation {
    [self.sheetView hideWithAnimation:NO];
}

- (YBIBSheetAction *)saveAction {
    if (!_saveAction) {
        __weak typeof(self) wSelf = self;
        _saveAction = [YBIBSheetAction actionWithName:[YBIBCopywriter sharedCopywriter].saveToPhotoAlbum action:^(id<YBIBDataProtocol> data) {
            __strong typeof(wSelf) self = wSelf;
            if (!self) return;
            if ([data respondsToSelector:@selector(yb_saveToPhotoAlbum)]) {
                [data yb_saveToPhotoAlbum];
            }
            [self.sheetView hideWithAnimation:YES];
        }];
    }
    return _saveAction;
}


- (UIPageControl *)pageControl{
    if (!_pageControl) {
        _pageControl = [UIPageControl new];
        _pageControl.enabled = NO;
        _pageControl.backgroundColor = [UIColor cyanColor];
    }
    return _pageControl;
}

- (YBIBSheetView *)sheetView {
    if (!_sheetView) {
        _sheetView = [YBIBSheetView new];
        __weak typeof(self) wSelf = self;
        [_sheetView setCurrentdata:^id<YBIBDataProtocol>{
            __strong typeof(wSelf) self = wSelf;
            if (!self) return nil;
            return self.yb_currentData();
        }];
    }
    return _sheetView;
}

@end
