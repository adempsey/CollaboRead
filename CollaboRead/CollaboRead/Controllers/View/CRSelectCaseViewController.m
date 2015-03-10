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
#import "CRScan.h"
#import "CRSlice.h"
#import "CRTitledImageCollectionCell.h"
#import "CRAPIClientService.h"
#import "CRViewSizeMacros.h"
#import "CRErrorAlertService.h"
#import "CRAccountService.h"

@interface CRSelectCaseViewController()
{
    NSIndexPath *selectedPath; //Allows the view to pass the selected case in the segue prep function
}

@property (nonatomic, strong) NSArray *caseSets;
@property (nonatomic, readwrite, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation CRSelectCaseViewController

-(void)viewDidAppear:(BOOL)animated {
    self.collectionView.userInteractionEnabled = YES;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	
	self.navigationItem.title = self.lecturer.name;

    //Get lecturers cases and reload view with that information
	[[CRAPIClientService sharedInstance] retrieveCaseSetsWithLecturer:self.lecturer.userID block:^(NSArray *caseSets, NSError *error) {
		if (!error) {
			self.caseSets = caseSets;
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
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alertController animated:YES completion:nil];
            });


		}
	}];
    [self.collectionView registerClass:[CRTitledImageCollectionCell class] forCellWithReuseIdentifier:@"CaseCell"];
    
}

- (IBAction)dismiss:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
	[[CRAccountService sharedInstance] logout];
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
    cell.contentView.frame = cell.bounds;
    cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	CRCaseSet *caseSet = self.caseSets[indexPath.section];
	NSArray *caseArray = [caseSet.cases.allValues sortedArrayUsingSelector:@selector(compareDates:)];
	CRCase *crCase = caseArray[indexPath.row];
    
	cell.name.text = crCase.name;
	CRScan *scan = crCase.scans[0];
	CRSlice *slice = scan.slices[0];
	cell.image.image = slice.image;
    return cell;
}

#pragma mark - UICollectionViewDelegate
//When a cell is selected, remember its path to set the case for the next view
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *segID = [[CRAccountService sharedInstance].user.type isEqualToString:@"lecturer"] ? @"LecturerSelectedCase" : @"StudentSelectedCase";
    selectedPath = indexPath;
    [self.view addSubview:self.activityIndicator];
    self.collectionView.userInteractionEnabled = NO;
    [self performSegueWithIdentifier:segID sender:self];
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

	CRCaseSet *selectedCaseSet = self.caseSets[selectedPath.section];
    NSArray *caseArray = [selectedCaseSet.cases.allValues sortedArrayUsingSelector:@selector(compareDates:)];
	CRCase *selectedCase = caseArray[selectedPath.row];
    //NSString *selectedCaseKey = [selectedCaseSet.cases allKeysForObject:selectedCase][0];//[selectedCaseSet.cases keysSortedByValueUsingSelector:@selector(compareDates:)][selectedPath.row];
    //selectedCaseSet.cases.allKeys[selectedPath.row];
	nextController.caseChosen = selectedCase;
	nextController.caseGroup = selectedCaseSet.setID;

    nextController.lecturerID = self.lecturer.userID;
    nextController.indexPath = selectedPath;
}


@end
