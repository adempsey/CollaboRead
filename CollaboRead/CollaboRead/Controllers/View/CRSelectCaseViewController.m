//
//  CRSelectCaseViewController.m
//  CollaboRead
//
//  Created by Hannah Clark on 10/15/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRSelectCaseViewController.h"
#import "CRImageController.h"
#import "CRUserKeys.h"
#import "CRCaseSet.h"
#import "CRCase.h"
#import "CRTitledImageCollectionCell.h"
#import "CRAPIClientService.h"

@interface CRSelectCaseViewController()
{
    NSIndexPath *selectedPath; //Allows the view to pass the selected case in the segue prep function
}

@property (nonatomic, strong) NSArray *caseSets;

@end

@implementation CRSelectCaseViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = [self.lecturer objectForKey:CR_DB_USER_NAME];

    //Get lecturers cases and reload view with that information
	[[CRAPIClientService sharedInstance] retrieveCaseSetsWithLecturer:self.lecturer[CR_DB_USER_ID] block:^(NSArray *caseSets) {
		self.caseSets = caseSets;
        [self.collectionView reloadData];//Maybe put back on main thread?
	}];
}

#pragma mark - UICollectionViewDataSource
//Set the number of cases per section to be the number of cases in the group it was formed from
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.caseSets ? ((CRCaseSet*) self.caseSets[section]).cases.count : 0;
}

//Set the number of sections to be the number of groupings
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.caseSets.count;
}

//Set the cell to have the image and name of the case it corresponds to
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CRTitledImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CaseCell" forIndexPath:indexPath];

	CRCaseSet *caseSet = self.caseSets[indexPath.section];
	NSString *caseKey = caseSet.cases.allKeys[indexPath.row];
	CRCase *crCase = caseSet.cases[caseKey];

	cell.name.text = crCase.name;
	cell.image.image = crCase.images[0];

    return cell;
}

#pragma mark - UICollectionViewDelegate
//When a cell is selected, remember its path to set the case for the next view
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    selectedPath = indexPath;
}

#pragma mark – UICollectionViewDelegateFlowLayout
//Cells are all 200 x 200 pixels
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*) collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(200, 200);
}

//Cells are 50 pixels away from edge of view and 30 from each other?
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(50, 50, 30, 30);
}

#pragma mark - Navigation

//Give the case analysis view the appropriate case
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	CRImageController *nextController = segue.destinationViewController;
	nextController.user = self.user;

	CRCaseSet *selectedCaseSet = self.caseSets[selectedPath.section];
	NSString *selectedCaseKey = selectedCaseSet.cases.allKeys[selectedPath.row];
	CRCase *selectedCase = selectedCaseSet.cases[selectedCaseKey];

	nextController.caseChosen = selectedCase;
	nextController.caseId = [selectedCaseKey integerValue];
	nextController.caseGroup = [selectedCaseSet.setID integerValue];
}


@end
