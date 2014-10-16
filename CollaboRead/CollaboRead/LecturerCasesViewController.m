//
//  LecturerCasesViewController.m
//  CollaboRead
//
//  Created by Hannah Clark on 10/15/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "LecturerCasesViewController.h"
#import "ImageController.h"
#import "UserKeys.h"
#import "CaseKeys.h"
#import "CaseCell.h"
#import "CRAPIClientService.h"

@interface LecturerCasesViewController()
{
    NSIndexPath *selectedPath; //Allows the view to pass the selected case in the segue prep function
}

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;

@end

@implementation LecturerCasesViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = [self.lecturer objectForKey:U_NAME];

    //Get lecturers cases and reload view with that information
	[[CRAPIClientService sharedInstance] retrieveCaseSetsWithLecturer:self.lecturer[ID_NUM] block:^(NSArray *caseSets) {
		self.caseSets = caseSets;
		[self.collectionView reloadData];
	}];
}

#pragma mark - UICollectionViewDataSource
//Set the number of cases per section to be the number of cases in the group it was formed from
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return (self.caseSets && [self.caseSets isKindOfClass:[NSArray class]]) ? ((NSArray*) self.caseSets[section][CASES]).count : 0;
}

//Set the number of sections to be the number of groupings
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.caseSets count];
}

//Set the cell to have the image and name of the case it corresponds to
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CaseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CaseCell" forIndexPath:indexPath];
    cell.name.text = [[[[self.caseSets objectAtIndex:indexPath.section] objectForKey:CASES] objectAtIndex:indexPath.row] objectForKey:C_NAME];
    cell.image.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[[[[self.caseSets objectAtIndex:indexPath.section] objectForKey:CASES] objectAtIndex:indexPath.row] objectForKey:IMAGE] objectAtIndex:0]]]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
//When a cell is selected, remember its path to set the case for the next view
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    selectedPath = indexPath;
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {

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

 #pragma mark - Navigation
 
 //Give the case analysis view the appropriate case
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     NSLog(@"before");
     ImageController *nextController = segue.destinationViewController;
     nextController.caseChosen = [[[self.caseSets objectAtIndex:selectedPath.section] objectForKey:CASES] objectAtIndex:selectedPath.row];
     NSLog(@"segue");
     
 }


@end
