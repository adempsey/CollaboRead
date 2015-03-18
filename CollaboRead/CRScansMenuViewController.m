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

@interface CRScansMenuViewController ()

/*!
 @brief View to display scans
 */
@property (nonatomic, strong) UICollectionView *collectionView;
/*!
 @brief Currently selected index in collection view
 */
@property (nonatomic, strong) NSIndexPath *selectedIndex;

@end

@implementation CRScansMenuViewController

static NSString * const reuseIdentifier = @"scanCell";

-(instancetype)initWithScans:(NSArray *)scans {
    self = [super init];
    if (self) {
        self.scans = scans;
        self.selectedIndex = [NSIndexPath indexPathForItem:0 inSection:0];
    }
    return self;
}

-(void) setHighlights:(NSArray *)highlights {
    _highlights = highlights;
    [self.collectionView reloadData];
}

-(void) setViewFrame:(CGRect)frame {
    self.view.frame = frame;
    [self.collectionView reloadData];
    self.collectionView.frame = CGRectMake(kScanMenuMargin, kScanMenuMargin, frame.size.width - 2 * kScanMenuMargin, frame.size.height - 2 * kScanMenuMargin);
    [self.collectionView selectItemAtIndexPath:self.selectedIndex animated:NO scrollPosition:UICollectionViewScrollPositionNone]; //Reset selected item because changing size may have changed the amount of items and therefore selection
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = CR_COLOR_TINT;

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(kScanMenuMargin, kScanMenuMargin, self.view.frame.size.width - 2 * kScanMenuMargin, self.view.frame.size.height - 2 * kScanMenuMargin) collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = CR_COLOR_PRIMARY;
    // Register cell classes
    [self.collectionView registerClass:[CRTitledImageCollectionCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    [self.view addSubview:self.collectionView];
    if (self.scans == nil) {
        self.scans = [[NSArray alloc] init];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.view.frame.size.width == 0 ? 0 : [self.scans count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CRTitledImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    // Configure the cell
    cell.name.text = ((CRScan *)self.scans[indexPath.row]).name;
    cell.image.image = ((CRSlice *)((CRScan *)self.scans[indexPath.row]).slices[0]).image;
    if ([self.highlights containsObject:[NSNumber numberWithInteger:indexPath.row]]) {
        cell.layer.borderColor = [CR_COLOR_ANSWER_INDICATOR CGColor];
        cell.layer.borderWidth = 3.0;
    }
    else {
        cell.layer.borderWidth = 0;
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath;
    [self.delegate scansMenuViewControllerDidSelectScan:((CRScan *)self.scans[indexPath.row]).scanID];
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
