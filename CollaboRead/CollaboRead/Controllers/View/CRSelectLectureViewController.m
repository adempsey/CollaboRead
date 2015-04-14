//
//  CRSelectLectureViewController.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 4/9/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "CRSelectLectureViewController.h"
#import "CRTitledImageCollectionCell.h"
#import "CRAPIClientService.h"
#import "CRSelectCaseViewController.h"
#import "CRAccountService.h"
#import "CRCase.h"
#import "CRScan.h"
#import "CRSlice.h"
#import "CRUserKeys.h"

@interface CRSelectLectureViewController ()
{
	NSIndexPath *selectedPath;
}

@property (nonatomic, readwrite, strong) NSArray *lectures;
@property (nonatomic, readwrite, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation CRSelectLectureViewController

static NSString * const reuseIdentifier = @"LectureCell";

- (void)viewDidLoad {
	[super viewDidLoad];
	
	if ([[[CRAccountService sharedInstance] user].type isEqualToString:CR_USER_TYPE_LECTURER]) {
		self.lecturer = [[CRAccountService sharedInstance] user];
	}
	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	self.navigationItem.title = [self.lecturer.name stringByAppendingString:@"'s Lectures"];
	[self.activityIndicator startAnimating];
	
	[[CRAPIClientService sharedInstance] retrieveLecturesWithLecturer:self.lecturer.userID block:^(NSArray *lectures, NSError *error) {
		[self.activityIndicator stopAnimating];
		self.activityIndicator.hidden = YES;
		
		if (!error) {
			self.lectures = lectures;
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.collectionView reloadData];
			});
		} else {
			NSLog(@"%@", error);
		}
	}];
	
    [self.collectionView registerClass:[CRTitledImageCollectionCell class] forCellWithReuseIdentifier:reuseIdentifier];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.collectionView.userInteractionEnabled = YES;
}

/*!
 Dismiss view controller
 @param sender
 UIElement that triggered method, unused
 */
- (IBAction)dismiss:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
	[[CRAccountService sharedInstance] logout];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return self.lectures.count;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return self.lectures ? ((CRLecture*) self.lectures[section]).cases.count : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	CRTitledImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

	cell.contentView.frame = cell.bounds;
	cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	CRLecture *lecture = self.lectures[indexPath.section];
	NSArray *caseArray = [lecture.cases.allValues sortedArrayUsingSelector:@selector(compareDates:)];

	cell.name.text = lecture.name;
	
	CRCase *firstCase = caseArray[0];
	CRScan *firstScan = firstCase.scans[0];
	CRSlice *firstSlice = firstScan.slices[0];
	cell.image.image = firstSlice.image;
	
    return cell;
}

- (void)prepSegue
{
//	[self.activityIndicator stopAnimating]; //The view won't make this change until it also performs the segue, so it is ok to stop before the view loading occurs
	NSString *segID = [[CRAccountService sharedInstance].user.type isEqualToString:@"lecturer"] ? @"LecturerSelectedLecture" : @"StudentSelectedLecture";
	[self performSegueWithIdentifier:segID sender:self];
}

#pragma mark - UICollectionViewDelegate
//When a cell is selected, remember its path to set the case for the next view
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	selectedPath = indexPath;
	self.collectionView.userInteractionEnabled = NO;
	[self performSelector:@selector(prepSegue) withObject:nil afterDelay:0];//"Delay" is needed so that the view will render activity indicator before stopping it
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
	CRSelectCaseViewController *nextController = segue.destinationViewController;
	CRLecture *selectedLecture = self.lectures[selectedPath.section];
	nextController.cases = selectedLecture.cases;
	nextController.lectureID = selectedLecture.lectureID;
    nextController.navigationItem.title = selectedLecture.name;
	nextController.lecturer = self.lecturer;
}

@end
