//
//  CRLecturerImageViewController.m
//  CollaboRead
//
//  Created by Hannah Clark on 10/20/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRLecturerImageViewController.h"
#import "CRAPIClientService.h"
#import "CRAnswerPoint.h"
#import "CRUser.h"
#import "CRAnswerLine.h"
#import "CRScan.h"
#import "CRSlice.h"
#import "CRAnswerRefreshService.h"
#import "CRErrorAlertService.h"
#import "CRCarouselCell.h"
#import "CRColors.h"
#import "BBBadgeBarButtonItem.h"

#define kCR_SIDE_BAR_TOGGLE_SHOW @"Show Answer Table"
#define kCR_SIDE_BAR_TOGGLE_HIDE @"Hide Answer Table"

@interface CRLecturerImageViewController ()
/*!
 @brief Student answers to display as CRAnswerLines
 */
@property (nonatomic, strong) NSArray *selectedAnswers;
/*!
 @brief Colors of student answers as dictionary with keys r, g, b
 */
@property (nonatomic, strong) NSArray *selectedColors;
/*!
 @brief Button placed within toggle button to allow for a title with the badge
 */
@property (nonatomic, strong) UIButton *subToggleButton;
/*!
 @brief Button to toggle student answer table with badge indicating unviewed answers
 */
@property (nonatomic, strong) BBBadgeBarButtonItem *toggleStudentAnswerTableButton;
/*!
 @brief View controller to handle selection of student answers to display
 */
@property (nonatomic, readwrite, strong) CRStudentAnswerTableViewController *studentAnswerTableViewController;

/*!
 Handles acquistion of new answers
 */
- (void)refreshAnswers;
/*!
 Draw selected student answers on the current image
 */
-(void)drawStudentAnswers;
@end

//TODO:correspond socket to case changes
@implementation CRLecturerImageViewController

- (void)loadView {
    [super loadView];
    
    self.studentAnswerTableViewController = [[CRStudentAnswerTableViewController alloc] initWithAnswerList:self.caseChosen.answers andScanID:((CRScan*)self.caseChosen.scans[self.scanIndex]).scanID];
    
    self.studentAnswerTableViewController.delegate = self;
    self.studentAnswerTableViewController.visible = NO;
    [self addChildViewController:self.studentAnswerTableViewController];
    [super.view addSubview:self.studentAnswerTableViewController.view];
    
    self.subToggleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 175, 20)];
    [self.subToggleButton setTitle:kCR_SIDE_BAR_TOGGLE_SHOW forState:UIControlStateNormal];
    [self.subToggleButton setTitleColor:CR_COLOR_TINT forState:UIControlStateNormal];
    self.toggleStudentAnswerTableButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:self.subToggleButton];
    self.studentAnswerTableViewController.toggleButton = self.subToggleButton; //as per example, sub button actually handles clicks
    self.navigationItem.rightBarButtonItem = self.toggleStudentAnswerTableButton;
    
    self.view = super.view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.autoresizesSubviews = NO;

    NSArray *scanHighlights = [self.caseChosen answerScans];
    self.scansMenuController.highlights = scanHighlights;

    self.toggleStudentAnswerTableButton.badgeBGColor = CR_COLOR_ANSWER_INDICATOR;
    self.toggleStudentAnswerTableButton.badgeOriginX = 170;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.caseChosen answerSlicesForScan:((CRScan *)self.caseChosen.scans[self.scanIndex]).scanID].count > 0) {
        self.toggleStudentAnswerTableButton.badgeValue = @"!";
    }
    //Open for refresh
    [[CRAnswerRefreshService sharedInstance] setUpdateBlock:^{
        [self refreshAnswers];
    }];
    
    [[CRAnswerRefreshService sharedInstance] initiateConnectionWithCase:self.caseChosen];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[CRAnswerRefreshService sharedInstance] disconnect];
}

//Custom setter to handle image change
- (void)setSliceIndex:(NSUInteger)sliceIndex {
    [super setSliceIndex:sliceIndex];
    [self drawStudentAnswers];
}

//Custom setter to handle image change
- (void)setScanIndex:(NSUInteger)scanIndex {
    [super setScanIndex:scanIndex];
    self.studentAnswerTableViewController.scanId = ((CRScan*)self.caseChosen.scans[self.scanIndex]).scanID; //Notify answer table of changes
}

//Custom setter to handle image change
- (void)setCaseChosen:(CRCase *)caseChosen {
    [super setCaseChosen:caseChosen];
    self.scansMenuController.highlights = [self.caseChosen answerScans];
}

-(void)drawStudentAnswers
{
    //Find lines for current slice and scan
    //TODO: fix color correspondance
    NSString *scanID = ((CRScan *)self.caseChosen.scans[self.scanIndex]).scanID;
    NSString *sliceID = ((CRSlice *)((CRScan *)self.caseChosen.scans[self.scanIndex]).slices[self.sliceIndex]).sliceID;
    NSMutableArray *answerLines = [[NSMutableArray alloc] init];
    [self.selectedAnswers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [((CRAnswer *)obj).drawings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CRAnswerLine *line = obj;
            if ([line.scanID isEqualToString: scanID] && [line.sliceID isEqualToString:sliceID]) {
                [answerLines addObject:line];
                *stop = true;
            }
        }];
    }];
    [self.imageMarkup drawPermenantAnswers:answerLines inColors:self.selectedColors];
    
}

- (void)refreshAnswers
{
	[[CRAPIClientService sharedInstance] retrieveCaseSetsWithLecturer:self.lecturerID block:^(NSArray *array, NSError *error) {
		if (!error) {
			CRCaseSet *selectedCaseSet = array[self.indexPath.section];
			self.caseChosen.answers = ((CRCase *)[selectedCaseSet.cases.allValues sortedArrayUsingSelector:@selector(compareDates:)][self.indexPath.row]).answers;
			
			NSArray *answers = self.caseChosen.answers;
            NSArray *scanHighlights = [self.caseChosen answerScans];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.studentAnswerTableViewController.answerList = answers;
                //Highlights may need to change
                [self.scrollBar reloadData];
                self.scansMenuController.highlights = scanHighlights;
                [self drawStudentAnswers];
                if ([self.caseChosen answerSlicesForScan:((CRScan *)self.caseChosen.scans[self.scanIndex]).scanID].count > 0 && !self.studentAnswerTableViewController.visible) {
                    self.toggleStudentAnswerTableButton.badgeValue = @"!"; //New answers should trigger badge if answer table isn't currently visible
                }
                
            });
		} else {
			UIAlertController *alertController = [[CRErrorAlertService sharedInstance] networkErrorAlertForItem:@"case" completionBlock:^(UIAlertAction* action) {
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
}



#pragma mark - CRStudentAnswerTable Delegate Methods
- (void)studentAnswerTableView:(CRStudentAnswerTableViewController *)studentAnswerTable didChangeAnswerSelection:(NSArray *)answers
{
    self.selectedAnswers = answers;
	
	NSMutableArray *colors = [[NSMutableArray alloc] init];
	for (id obj in answers) {
		[colors addObject:studentColors[[self.caseChosen.answers indexOfObject:obj]]];
	}
	
    self.selectedColors = colors;
    [self drawStudentAnswers];
}

//TODO:MAY NOT BE NEEDED
-(void)studentAnswerTableView:(CRStudentAnswerTableViewController *)studentAnswerTableView didRefresh:(CRCase *)refreshedCase {
    self.caseChosen.answers = refreshedCase.answers;
    self.scansMenuController.highlights = [self.caseChosen answerScans];
    [self.scrollBar reloadData];
}

-(void) scansMenuViewControllerDidSelectScan:(NSString *)scanId
{
    [super scansMenuViewControllerDidSelectScan:scanId];
    //Make sure to adjust badge to notify of answers
    if ([self.caseChosen answerSlicesForScan:scanId].count > 0 && !self.studentAnswerTableViewController.visible) {
        self.toggleStudentAnswerTableButton.badgeValue = @"!";
    } else {
        self.toggleStudentAnswerTableButton.badgeValue = @"";
    }
}

- (void)toolPanelViewController:(CRToolPanelViewController *)toolPanelViewController didSelectTool:(NSInteger)tool
{
    [super toolPanelViewController:toolPanelViewController didSelectTool:tool];
    [self drawStudentAnswers]; //Make sure answers are drawn after action
}

-(UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view { //Highlight slices with drawings
    CRCarouselCell *cView = (CRCarouselCell *)[super carousel:carousel viewForItemAtIndex:index reusingView:view];
    if ([[self.caseChosen answerSlicesForScan:((CRScan *)self.caseChosen.scans[self.scanIndex]).scanID] containsObject:@(index)]) {
        cView.isHighlighted = YES;
    } else {
        cView.isHighlighted = NO;
    }
    return cView;
}

#pragma mark - CRSideBarViewController Delegate Methods

- (void)CRSideBarViewController:(CRSideBarViewController *)sideBarViewController didChangeVisibility:(BOOL)visible
{
    //Toggle title, no more need for alert once visible
    if (visible) {
        self.toggleStudentAnswerTableButton.badgeValue = @"";
    }
    [self.subToggleButton setTitle:visible ? kCR_SIDE_BAR_TOGGLE_HIDE : kCR_SIDE_BAR_TOGGLE_SHOW forState:UIControlStateNormal];
}

@end
