//
//  NYTPhotoViewController.m
//  Pods
//
//  Created by Brian Capps on 2/11/15.
//
//

#import "NYTPhotoViewController.h"
#import "NYTPhoto.h"
#import "NYTScalingImageView.h"

@interface NYTPhotoViewController () <UIScrollViewDelegate>

@property (nonatomic) id <NYTPhoto> photo;

@property (nonatomic) NYTScalingImageView *scalingImageView;
@property (nonatomic) UITapGestureRecognizer *doubleTapGestureRecognizer;
@property (nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;

@end

@implementation NYTPhotoViewController

#pragma mark - NSObject

- (void)dealloc {
    _scalingImageView.delegate = nil;
}

#pragma mark - UIViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithPhoto:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.scalingImageView.frame = self.view.bounds;
    [self.view addSubview:self.scalingImageView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.scalingImageView.frame = self.view.bounds;
}

#pragma mark - NYTPhotoViewController

- (instancetype)initWithPhoto:(id <NYTPhoto>)photo {
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        _photo = photo;
        
        _scalingImageView = [[NYTScalingImageView alloc] initWithImage:photo.image frame:CGRectZero];
        _scalingImageView.delegate = self;
        
        [self setupGestureRecognizers];
    }
    
    return self;
}

#pragma mark - Gesture Recognizers

- (void)setupGestureRecognizers {
    self.doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTapWithGestureRecognizer:)];
    self.doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:self.doubleTapGestureRecognizer];
    
    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressWithGestureRecognizer:)];
    [self.view addGestureRecognizer:self.longPressGestureRecognizer];
}

- (void)didDoubleTapWithGestureRecognizer:(UITapGestureRecognizer *)recognizer {
    CGPoint pointInView = [recognizer locationInView:self.scalingImageView.internalImageView];
    
    CGFloat previousZoomScale = self.scalingImageView.zoomScale;
    CGFloat newZoomScale = MIN(previousZoomScale * 1.5, self.scalingImageView.maximumZoomScale);
    
    //If we've reached the maximum zoom scale, zoom back out.
    if (previousZoomScale == self.scalingImageView.maximumZoomScale) {
        newZoomScale = self.scalingImageView.minimumZoomScale;
    }
    
    CGSize scrollViewSize = self.scalingImageView.bounds.size;
    
    CGFloat width = scrollViewSize.width / newZoomScale;
    CGFloat height = scrollViewSize.height / newZoomScale;
    CGFloat originX = pointInView.x - (width / 2.0);
    CGFloat originY = pointInView.y - (height / 2.0);
    
    CGRect rectToZoomTo = CGRectMake(originX, originY, width, height);
    
    [self.scalingImageView zoomToRect:rectToZoomTo animated:YES];
}

- (void)didLongPressWithGestureRecognizer:(UILongPressGestureRecognizer *)recognizer {
    if ([self.delegate respondsToSelector:@selector(photoViewController:didLongPressWithGestureRecognizer:)]) {
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            [self.delegate photoViewController:self didLongPressWithGestureRecognizer:recognizer];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.scalingImageView.internalImageView;
}

@end