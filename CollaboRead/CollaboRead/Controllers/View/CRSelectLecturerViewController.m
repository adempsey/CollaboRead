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
#import "CRViewSizeMacros.h"
#import "CRErrorAlertService.h"

@interface CRSelectLecturerViewController ()
{
    NSIndexPath *selectedPath;
}

@property (nonatomic, strong) NSArray *lecturers; //Lecturers in database
@property (nonatomic, readwrite, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation CRSelectLecturerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    //Set up display with placeholder, iOS version appropriately
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.title = @"Select Lecturer";
    
    [self.collectionView registerClass:[CRTitledImageCollectionCell class] forCellWithReuseIdentifier:@"LecturerCell"];
    
    //Get Lecturers to display and display when possible
    [[CRAPIClientService sharedInstance]retrieveLecturersWithBlock:^(NSArray* lecturers, NSError *error) {
		if (!error) {
			self.lecturers = lecturers;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });

		} else {
			UIAlertController *alertController = [[CRErrorAlertService sharedInstance] networkErrorAlertForItem:@"cases" completionBlock:^(UIAlertAction *action) {
				if (self != self.navigationController.viewControllers[0]) {
					[self.navigationController popViewControllerAnimated:YES];
				} else if (self.presentingViewController) {
					[self dismissViewControllerAnimated:YES completion:nil];
				}
			}];
			[self presentViewController:alertController animated:YES completion:nil];
		}
    }];
}

#pragma mark - Navigation

//Pass along user and lecturer
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    CRSelectCaseViewController *nextController = [segue destinationViewController];
    nextController.lecturer = self.lecturers[selectedPath.row];
}


#pragma mark <UICollectionViewDataSource>

//No groupings so view only has single section
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
    cell.contentView.frame = cell.bounds;
    cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	CRUser *lecturer = self.lecturers[indexPath.row];
	cell.image.image = lecturer.image;
	cell.name.text = lecturer.name;

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

//When a cell is selected, remember its path to set the case for the next view, trigger segue
//Segue is triggered here rather than automatically because of difficulties between custom collectionviewcells in iOS 7 vs 8
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    selectedPath = indexPath;
    [self performSegueWithIdentifier:@"LecturerSelected" sender:self];
}

@end
