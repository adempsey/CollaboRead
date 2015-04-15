//
//  CRScansMenuViewController.m
//  CollaboRead
//
//  Created by Hannah Clark on 1/22/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "CRScansMenuViewController.h"
#import "CRColors.h"
#import "CRTitledImageCollectionCell.h"
#import "CRScan.h"
#import "CRSlice.h"

#define kScanMenuMargin 5
#define KActivitySize 35

@interface CRScansMenuViewController ()

/*!
 @brief View to display scans
 */
@property (nonatomic, strong) UICollectionView *collectionView;
/*!
 @brief Currently selected index in collection view
 */
@property (nonatomic, strong) NSIndexPath *selectedIndex;
/*!
 @brief Activity indicator to display while collectionview loads
 */
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
/*!
 Helper function to change view size in animated manner
 @param params
 Parameters passed to setFrame:animated
 */
-(void)changeFrame:(NSDictionary *) params;

@end

@implementation CRScansMenuViewController

static NSString * const reuseIdentifier = @"scanCell";

- (instancetype)initWithScans:(NSArray *)scans
{
    self = [super init];
    if (self) {
        self.scans = scans;
        self.selectedIndex = [NSIndexPath indexPathForItem:0 inSection:0];
    }
    return self;
}

- (void)loadView
{
	[super loadView];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = CR_COLOR_TINT;
    view.clipsToBounds = YES;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(kScanMenuMargin, kScanMenuMargin, view.frame.size.width - 2 * kScanMenuMargin, view.frame.size.height - 2 * kScanMenuMargin) collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = CR_COLOR_PRIMARY;
    // Register cell classes
    [self.collectionView registerClass:[CRTitledImageCollectionCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [view addSubview:self.collectionView];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((view.frame.size.width - KActivitySize)/2, (view.frame.size.height - KActivitySize)/2, KActivitySize, KActivitySize)];
    self.activityIndicator.hidesWhenStopped = YES;
    [self.activityIndicator stopAnimating];
    [view addSubview:self.activityIndicator];
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.scans == nil) {
        self.scans = [[NSArray alloc] init];
    }
}

- (void)setHighlights:(NSArray *)highlights
{
    _highlights = highlights;
    [self.collectionView reloadData];
}

- (void)setScans:(NSArray *)scans
{
    _scans = scans;
    [self.collectionView reloadData];
}

- (void)setViewFrame:(CGRect)frame animated:(BOOL)animated
{
    [self.activityIndicator startAnimating];
    self.activityIndicator.frame = CGRectMake((frame.size.width - KActivitySize)/2, (frame.size.width - KActivitySize)/2, KActivitySize, KActivitySize);
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:NSStringFromCGRect(frame), @"frame", [NSNumber numberWithBool:animated], @"animated", nil];
    [self performSelector:@selector(changeFrame:) withObject:params afterDelay:0.01];
}

- (void)changeFrame:(NSDictionary *)params
{
    CGRect frame = CGRectFromString(params[@"frame"]);
    BOOL animated = [params[@"animated"] boolValue];
    BOOL shouldReloadFirst = frame.size.width == 0 || frame.size.height == 0;
    [UIView animateWithDuration:animated ? 0.25 : 0 animations:^{
        self.view.frame = frame;
        if (shouldReloadFirst) {//Displays view before loading cells to allow for more responsive view
            [self.collectionView reloadData];
        }
        self.collectionView.frame = CGRectMake(kScanMenuMargin, kScanMenuMargin, frame.size.width - 2 * kScanMenuMargin, frame.size.height - 2 * kScanMenuMargin);
    } completion:^(BOOL finished) {
        if (!shouldReloadFirst) {
            [self.collectionView reloadData];
        }
        [self.activityIndicator stopAnimating];
        [self.collectionView selectItemAtIndexPath:self.selectedIndex animated:NO scrollPosition:UICollectionViewScrollPositionNone]; //Reset selected item because changing size may have changed the amount of items and therefore selection
    }];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.view.frame.size.width == 0 ? 0 : [self.scans count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CRTitledImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

	CRScan *scan = (CRScan *)self.scans[indexPath.row];
	
    cell.name.text = scan.name;
    cell.image.image = ((CRSlice *)scan.slices[0]).image;
	
    if ([self.highlights containsObject:scan.scanID]) {
        cell.layer.borderColor = [CR_COLOR_ANSWER_INDICATOR CGColor];
        cell.layer.borderWidth = 3.0;
    } else {
        cell.layer.borderWidth = 0;
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath;
    [self.activityIndicator startAnimating];
    [self performSelector:@selector(selectedScanActivityHelper:) withObject:((CRScan *)self.scans[indexPath.row]).scanID afterDelay:0.0];
}

//Helps display activity indicator after selecting scan if it needs to wait for image load
- (void)selectedScanActivityHelper:(NSString *)scanID {
    [self.delegate scansMenuViewControllerDidSelectScan:scanID];
    [self.activityIndicator stopAnimating];
}

#pragma mark – UICollectionViewDelegateFlowLayout
//Cells sized to fit 3 per row pixels
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*) collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat dim = (collectionView.frame.size.width - 40) / 4;
    return CGSizeMake(dim, dim);
}

//Cells are 20 pixels away from edge of view and 15 from each other
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 20, 20, 20);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 15;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 15;
}

@end
