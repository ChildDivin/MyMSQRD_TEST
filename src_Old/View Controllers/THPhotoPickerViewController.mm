//
//  FSPhotoPickerViewController.m
//  videoApp
//
//  Created by Clayton Rieck on 4/8/15.
//
//

#import "THPhotoPickerViewController.h"
//#include "ofApp.h"

#import "THFacePickerCollectionViewCell.h"
#import "THFacesCollectionViewDataSource.h"
#import "MBProgressHUD.h"

static NSString * const kTHFacePickerViewControllerTitle = @"Face Selector";
static NSString * const kTHDeleteButtonSingleItemTitle = @"Delete Item";
static NSString * const kTHDeleteButtonMultiItemTitle = @"Delete Items";

static NSArray * const kTHLoadingDetails = @[@"You're gonna look great!", @"Ooo how handsome", @"Your alias is on the way!", @"Better than Mrs. Doubtfire"];

static const CGSize kTHCellSize = (CGSize){100.0f, 100.0f};
static const CGFloat kTHItemSpacing = 2.0f;
static const UIEdgeInsets kTHCollectionViewEdgeInsets = (UIEdgeInsets){0.0f, 8.0f, 8.0f, 8.0f};

@interface THPhotoPickerViewController ()
<UIAlertViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate>
{
    //ofApp *mainApp;
}

@property (nonatomic) UICollectionView *facesCollectionView;
@property (nonatomic) THFacesCollectionViewDataSource *dataSource;
@property (nonatomic) UIButton *deleteButton;
@property (nonatomic) UIImage *takenPhoto;

@end

@implementation THPhotoPickerViewController

- (instancetype)init
{
    self = [super init];
    if ( self ) {
        //mainApp = (ofApp *)ofGetAppPtr();
        self.title = kTHFacePickerViewControllerTitle;
    }
    return self;
}

- (void)setupMenuButtons
{
    /*UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissVC)];
    [dismissButton setTintColor:[UIColor redColor]];
    self.navigationItem.leftBarButtonItem = dismissButton;*/
    
    UIBarButtonItem * dismissButton1 = [[UIBarButtonItem alloc] initWithTitle:@"Dissmiss" style:UIBarButtonItemStylePlain target:self  action:@selector(dismissVC)];
    [dismissButton1 setTintColor:[UIColor redColor]];
    self.navigationItem.leftBarButtonItem = dismissButton1;
    
    
    UIBarButtonItem * cameraButton = [[UIBarButtonItem alloc] initWithTitle:@"Camera" style:UIBarButtonItemStylePlain target:self  action:@selector(presentCameraPicker)];
    [cameraButton setTintColor:[UIColor redColor]];
    self.navigationItem.rightBarButtonItem = cameraButton;
}

- (void)setupDeleteButton
{
    const CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
    
    _deleteButton = [[UIButton alloc] initWithFrame:self.navigationController.navigationBar.frame];
    [_deleteButton addTarget:self action:@selector(deleteSelectedItems) forControlEvents:UIControlEventTouchUpInside];
    _deleteButton.backgroundColor = [UIColor colorWithRed:0.9f green:0.3f blue:0.26f alpha:1.0f];
    _deleteButton.transform = CGAffineTransformMakeTranslation(0.0f, -navBarHeight);
    _deleteButton.hidden = YES;
    _deleteButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.navigationController.navigationBar addSubview:_deleteButton];
}

- (void)setupCollectionView
{
    const CGRect collectionViewFrame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    const CGSize headerViewSize = CGSizeMake(self.view.frame.size.width, 30.0f);
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.headerReferenceSize = headerViewSize;
    flowLayout.itemSize = kTHCellSize;
    flowLayout.minimumInteritemSpacing = kTHItemSpacing;
    flowLayout.minimumLineSpacing = kTHItemSpacing;
    
    _facesCollectionView = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:flowLayout];
    _facesCollectionView.backgroundColor = [UIColor whiteColor];
    _facesCollectionView.contentInset = kTHCollectionViewEdgeInsets;
    _facesCollectionView.delegate = self;
    _dataSource = [[THFacesCollectionViewDataSource alloc] initWithCollectionView:_facesCollectionView];
    _facesCollectionView.dataSource = _dataSource;
    _facesCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_facesCollectionView];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 0.5f;
    longPress.numberOfTouchesRequired = 1;
    longPress.delaysTouchesBegan = YES; // prevent didHighlightItemAtIndexPath from being called first
    [_facesCollectionView addGestureRecognizer:longPress];
}

- (void)dealloc
{
    _facesCollectionView = nil;
   // mainApp = NULL;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupMenuButtons];
    [self setupCollectionView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupDeleteButton]; // prevents bug where button doesn't appear after taking a photo and trying to delete a saved photo
}

#pragma mark - Private

- (void)dismissVC
{
    [self.dataSource resetCellStates];
    
    //mainApp->setupCam([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)presentCameraPicker
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
}

- (NSString *)randomLoadingDetail
{
    const NSInteger lowerBound = 0;
    const NSInteger upperBound = kTHLoadingDetails.count;
    const NSInteger randomPosition = lowerBound + arc4random() % (upperBound - lowerBound);
    return kTHLoadingDetails[randomPosition];
}

- (void)showLoadingHUD
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading Face";
    hud.detailsLabelText = [self randomLoadingDetail];
}

- (void)showDeleteButton:(BOOL)show
{
    CGAffineTransform targetTransform;
    if ( show ) {
        [self.deleteButton setHidden:!show];
        targetTransform = CGAffineTransformMakeTranslation(0.0f, 0.0f);
    }
    else {
        targetTransform = CGAffineTransformMakeTranslation(0.0f, -self.navigationController.navigationBar.frame.size.height);
    }
    
    [UIView animateWithDuration:0.1f
                     animations:^{
                         self.deleteButton.transform = targetTransform;
                     }
                     completion:^(BOOL finished){
                         [self.deleteButton setHidden:!show];
                     }];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    BOOL save = NO;
    if ( buttonIndex == 1 ) {
        save = YES;
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [self showLoadingHUD];
        [self.dataSource loadFace:self.takenPhoto saveImage:save withCompletion:^{
            self.takenPhoto = nil;
            [self dismissVC];
        }];
    }];
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.takenPhoto = (UIImage *)[info[UIImagePickerControllerOriginalImage] copy]; // need to copy or else you'll try to load the reference to the image which will be deallocated outside of this scope
    
   // mainApp->cam.close();
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Save Photo For Later?"
                                                        message:@"Saving will allow you to use this face later on"
                                                       delegate:self
                                              cancelButtonTitle:@"No Thanks"
                                              otherButtonTitles:@"Right On!", nil];
    [alertView show];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self showLoadingHUD];
    
    dispatch_async(dispatch_queue_create("imageLoadingQueue", NULL), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( indexPath.section == 0 ) {
               // mainApp->loadFace(mainApp->faces.getPath(indexPath.row));
            }
            else {
                NSString *imageName = [self.dataSource savedImageNameAtIndexPath:indexPath];
                //ofImage savedImage;
                //ofxiOSUIImageToOFImage([self.dataSource imageFromDocumentsDirectoryNamed:imageName], savedImage);
                //mainApp->loadOFImage(savedImage);
            }
            
            [self dismissVC];
        });
    });
}

#pragma mark - UIGestureRecognizer Selectors

- (void)longPress:(UIGestureRecognizer *)gesture
{
    switch ( gesture.state ) {
        case UIGestureRecognizerStateBegan: {
            const CGPoint gesturePoint = [gesture locationInView:self.facesCollectionView];
            NSIndexPath *pointIndexPath = [self.facesCollectionView indexPathForItemAtPoint:gesturePoint];
            
            if ( pointIndexPath ) {
                
                if ( pointIndexPath.section == 1 ) { // should only be able to delete saved images taken via camera
                    
                    THFacePickerCollectionViewCell *selectedCell = (THFacePickerCollectionViewCell *)[self.facesCollectionView cellForItemAtIndexPath:pointIndexPath];
                    [selectedCell highlightSelected:!selectedCell.highlightSelected];
                    
                    if ( selectedCell.highlightSelected ) {
                        [self.dataSource addIndexPathToDelete:pointIndexPath];
                    }
                    else {
                        [self.dataSource removeIndexPathToDelete:pointIndexPath];
                    }
                    
                    const NSInteger itemsToDelete = [self.dataSource numberOfItemsToDelete];
                    if ( itemsToDelete > 0 ) {
                        
                        if ( itemsToDelete > 1 ) {
                            [self.deleteButton setTitle:kTHDeleteButtonMultiItemTitle forState:UIControlStateNormal];
                        }
                        else {
                            [self.deleteButton setTitle:kTHDeleteButtonSingleItemTitle forState:UIControlStateNormal];
                        }
                        
                        if ( self.deleteButton.isHidden ) {
                            [self showDeleteButton:YES];
                        }
                    }
                    else {
                        if ( !self.deleteButton.isHidden ) {
                            [self showDeleteButton:NO];
                        }
                    }
                }
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateChanged:
        default:
            break;
    }
}

#pragma mark - UIButton Selectors

- (void)deleteSelectedItems
{
    [self.dataSource deleteSelectedItems:^{
        [self showDeleteButton:NO];
    }];
}

@end
