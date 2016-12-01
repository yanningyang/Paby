//
//  SGPhotoViewController.m
//  SGSecurityAlbum
//
//  Created by soulghost on 10/7/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "SGUIKit.h"
#import "SGPhotoViewController.h"
#import "SGPhotoBrowser.h"
#import "SGPhotoView.h"
#import "SGPhotoModel.h"
#import "SGPhotoToolBar.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "MBProgressHUD+SGExtension.h"

@interface SGPhotoViewController ()

@property (nonatomic, assign) BOOL isBarHidden;
@property (nonatomic, weak) SGPhotoView *photoView;
@property (nonatomic, weak) SGPhotoToolBar *toolBar;

@end

@implementation SGPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    sg_ws();
    [self.photoView setSingleTapHandlerBlock:^{
//        [weakSelf toggleBarState];
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.photoView.backgroundColor = [UIColor clearColor];
}

- (void)setupView {
    SGPhotoView *photoView = [[SGPhotoView alloc] initWithFrame:[self getPhotoViewFrame]];
    self.photoView = photoView;
    self.photoView.controller = self;
    self.photoView.browser = self.browser;
    self.photoView.index = self.index;
    [self.view addSubview:photoView];
    SGPhotoToolBar *tooBar = [[SGPhotoToolBar alloc] initWithFrame:[self getBarFrame]];
    self.toolBar = tooBar;
    [self.view addSubview:tooBar];
    sg_ws();
    [self.toolBar setButtonActionHandlerBlock:^(UIBarButtonItem *sender) {
        switch (sender.tag) {
            case SGPhotoToolBarTrashTag:
                [weakSelf trashAction];
                break;
            case SGPhotoToolBarExportTag:
//                [weakSelf exportAction];
                [weakSelf shareAction];
                break;
            default:
                break;
        }
    }];
}

- (void)layoutViews {
    self.photoView.frame = [self getPhotoViewFrame];
    [self.photoView layoutImageViews];
    self.toolBar.frame = [self getBarFrame];
}

- (CGRect)getPhotoViewFrame {
    CGFloat x = -PhotoGutt;
    CGFloat y = 0;
    CGFloat w = self.view.bounds.size.width + 2 * PhotoGutt;
    CGFloat h = self.view.bounds.size.height;
    return CGRectMake(x, y, w, h);
}

- (CGRect)getBarFrame {
    CGFloat barW = self.view.bounds.size.width;
    CGFloat barH = 44;
    CGFloat barX = 0;
    CGFloat barY = self.view.bounds.size.height - barH;
    return CGRectMake(barX, barY, barW, barH);
}

- (void)toggleBarState {
    self.isBarHidden = !self.isBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:self.isBarHidden withAnimation:NO];
    [self.navigationController setNavigationBarHidden:self.isBarHidden animated:YES];
    [UIView animateWithDuration:0.35 animations:^{
        self.toolBar.alpha = self.isBarHidden ? 0 : 1.0f;
    }];
}

#pragma mark - ToolBar Action
- (void)trashAction {
    [[[SGBlockActionSheet alloc] initWithTitle:@"Please Confirm Delete" callback:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            SGPhotoModel *model = self.photoView.currentPhoto;
            [SGPhotoBrowser deleteImageWithURL:model.photoURL];
            [SGPhotoBrowser deleteImageWithURL:model.thumbURL];
            if (self.browser.deleteHandler) {
                self.browser.deleteHandler(model.index);
            }
            [self.navigationController popViewControllerAnimated:YES];
            NSAssert(self.browser.reloadHandler != nil, @"you must implement 'reloadHandler' block to reload files while delete");
            self.browser.reloadHandler();
            [self.browser reloadData];
        }
    } cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitlesArray:nil] showInView:self.view];
}

- (void)exportAction {
    [[[SGBlockActionSheet alloc] initWithTitle:@"Save To Where" callback:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            ALAssetsLibrary *lib = [ALAssetsLibrary new];
            UIImage *image = self.photoView.currentImageView.innerImageView.image;
            [MBProgressHUD showMessage:@"Saving"];
            [lib writeImageToSavedPhotosAlbum:image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showSuccess:@"Succeeded"];
            }];
        }
    } cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitlesArray:@[@"Photo Library"]] showInView:self.view];
}

- (void)shareAction {
    
    // Show activity view controller
    NSMutableArray *items = [NSMutableArray arrayWithObject:_photoView.currentImageView.innerImageView.image];

    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    activity.excludedActivityTypes = @[UIActivityTypeAirDrop, UIActivityTypeMail, UIActivityTypePrint, UIActivityTypeMessage, UIActivityTypePostToVimeo, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePostToTwitter, UIActivityTypePostToFacebook, UIActivityTypeOpenInIBooks, UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList, UIActivityTypeCopyToPasteboard, UIActivityTypeSaveToCameraRoll];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        UIPopoverPresentationController *popover = activity.popoverPresentationController;
        if (popover) {
            popover.sourceView = self.toolBar;
            popover.sourceRect = CGRectMake([UIScreen mainScreen].bounds.size.width-20, 0, 10, 10);
            popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
    }
    
//    // Show loading spinner after a couple of seconds
//    double delayInSeconds = 2.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        if (activityViewController) {
//            [self showProgressHUDWithMessage:nil];
//        }
//    });
    
    [self presentViewController:activity animated:YES completion:nil];
}

#pragma mark - dealloc
- (void)orientationDidChanged:(UIDeviceOrientation)orientation {
    [self layoutViews];
}

@end
