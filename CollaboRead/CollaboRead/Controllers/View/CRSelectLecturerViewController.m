//
//  CRSelectLecturerViewController.m
//  CollaboRead
//
//  Created by Hannah Clark on 10/18/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRSelectLecturerViewController.h"
#import "CRSelectCaseViewController.h"
#import "CRTitledImageCollectionCell.h"
#import "CRAPIClientService.h"
#import "CRCaseSet.h"
#import "CRCase.h"

@interface CRSelectLecturerViewController ()
{
    NSIndexPath *selectedPath;
}

@property (nonatomic, strong) NSArray *lecturers;

@end

@implementation CRSelectLecturerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Select Lecturer";
    
    //Get Lecturers to display
    [[CRAPIClientService sharedInstance]retrieveLecturersWithBlock:^(NSArray* lecturers)
    {
        self.lecturers = lecturers;
        [self.collectionView reloadData];
    }];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    CRSelectCaseViewController *nextController = [segue destinationViewController];
    nextController.user = self.user;
    nextController.lecturer = self.lecturers[selectedPath.row];
}


#pragma mark <UICollectionViewDataSource>

//No groupings so single section
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//When lecturers is available, number of items should be number of lecturers
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return (self.lecturers && [self.lecturers isKindOfClass:[NSArray class]]) ?
            [self.lecturers count]: 0;
}

//Set cell to appropriate lecturer
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CRTitledImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LecturerCell" forIndexPath:indexPath];
	CRUser *lecturer = self.lecturers[indexPath.row];
	cell.image.image = lecturer.image;
	cell.name.text = [NSString stringWithFormat:@"%@ %@", lecturer.title, lecturer.name];

    return cell;
}
#pragma mark – UICollectionViewDelegateFlowLayout
//Cells are all 200 x 200 pixels
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*) collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(200, 200);
}

//Cells are 50 pixels away from edge of view and 30 from each other?
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(50, 50, 30, 30);
}
#pragma mark <UICollectionViewDelegate>

//When a cell is selected, remember its path to set the case for the next view
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    selectedPath = indexPath;
}

@end
