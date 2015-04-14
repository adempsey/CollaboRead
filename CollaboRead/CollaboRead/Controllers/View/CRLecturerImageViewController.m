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
#import "CRNotifications.h"
#import "BBBadgeBarButtonItem.h"

#define kCR_SIDE_BAR_TOGGLE_SHOW @"Show Answer Table"
#define kCR_SIDE_BAR_TOGGLE_HIDE @"Hide Answer Table"

#define SCAN_FILTER [NSPredicate predicateWithFormat:@"SELF ==[c] %@", ((CRScan *)self.caseChosen.scans[self.scanIndex]).scanID]

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

@property (nonatomic, readwrite, strong) NSArray *studentAnswers;
@property (nonatomic, strong) NSArray *studentAnswerScans;

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

- (void)loadView
{
    [super loadView];
    
    self.studentAnswerTableViewController = [[CRStudentAnswerTableViewController alloc] initWithAnswerList:self.studentAnswers andScanID:((CRScan*)self.caseChosen.scans[self.scanIndex]).scanID];
    
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.autoresizesSubviews = NO;

    NSArray *scanHighlights = [self.caseChosen answerScans];
    self.scansMenuController.highlights = scanHighlights;

    self.toggleStudentAnswerTableButton.badgeBGColor = CR_COLOR_ANSWER_INDICATOR;
    self.toggleStudentAnswerTableButton.badgeOriginX = 170;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.caseChosen answerSlicesForScan:((CRScan *)self.caseChosen.scans[self.scanIndex]).scanID].count > 0) {
        self.toggleStudentAnswerTableButton.badgeValue = @"!";
    }
	
    [[CRAnswerRefreshService sharedInstance] initiateConnectionWithLecture:self.lectureID];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAnswers) name:CR_NOTIFICATION_REFRESH_ANSWERS object:nil];
	
	[self refreshAnswers];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[CRAnswerRefreshService sharedInstance] disconnect];
}

//Custom setter to handle image change
- (void)setSliceIndex:(NSUInteger)sliceIndex
{
    [super setSliceIndex:sliceIndex];
    [self drawStudentAnswers];
}

//Custom setter to handle image change
- (void)setScanIndex:(NSUInteger)scanIndex
{
    [super setScanIndex:scanIndex];
    // Obtain IDs of scans with answers and set highlights
    if ([self.studentAnswerScans filteredArrayUsingPredicate:SCAN_FILTER].count > 0 && !self.studentAnswerTableViewController.visible) {
        self.toggleStudentAnswerTableButton.badgeValue = @"!";
    } else {
        self.toggleStudentAnswerTableButton.badgeValue = @"";
    }
    self.studentAnswerTableViewController.scanId = ((CRScan*)self.caseChosen.scans[self.scanIndex]).scanID; //Notify answer table of changes
}

//Custom setter to handle image change
- (void)setCaseChosen:(CRCase *)caseChosen
{
    [super setCaseChosen:caseChosen];
    // Obtain IDs of scans with answers and set highlights
    NSArray *answerDrawings = [self.studentAnswers valueForKeyPath:@"drawings"];
    NSMutableArray *answerScans = [[NSMutableArray alloc] init];
    [answerDrawings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSArray class]]) {
            NSArray *answerLines = (NSArray *)obj;
            
            NSArray *answerLineScans = [answerLines valueForKeyPath:@"scanID"];
            [answerScans addObjectsFromArray:answerLineScans];
        }
    }];
    self.scansMenuController.highlights = answerScans;
}

- (void)drawStudentAnswers
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
    [self.imageMarkup drawPermanentAnswers:answerLines inColors:self.selectedColors];
    
}

- (void)refreshAnswers
{
	[[CRAPIClientService sharedInstance] retrieveAnswersForCase:self.caseChosen.caseID inLecture:self.lectureID block:^(NSArray *answers, NSError *error) {
		if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.studentAnswerTableViewController.answerList = answers;
				
				// Obtain IDs of scans with answers and set highlights
				NSArray *answerDrawings = [answers valueForKeyPath:@"drawings"];
				NSMutableArray *answerScans = [[NSMutableArray alloc] init];
				NSMutableArray *answerSlices = [[NSMutableArray alloc] init];
				[answerDrawings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
					if ([obj isKindOfClass:[NSArray class]]) {
						NSArray *answerLines = (NSArray *)obj;
						
						NSArray *answerLineScans = [answerLines valueForKeyPath:@"scanID"];
						[answerScans addObjectsFromArray:answerLineScans];
						
						NSArray *answerLineSlices = [answerLines valueForKeyPath:@"sliceID"];
						[answerSlices addObjectsFromArray:answerLineSlices];
					}
				}];
				self.scansMenuController.highlights = answerScans;
				self.sliceScroller.highlights = answerSlices;
                if ([answerScans filteredArrayUsingPredicate:SCAN_FILTER].count > [self.studentAnswerScans filteredArrayUsingPredicate:SCAN_FILTER].count) {
                    //Also check visibility here
                    if (!self.studentAnswerTableViewController.visible) {
                        self.toggleStudentAnswerTableButton.badgeValue = @"!"; //New answers should trigger badge if answer table isn't currently visible
                    }
                    
                }
                self.studentAnswers = answers;
                [self drawStudentAnswers];
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

#pragma mark - CRScanMenuViewController Delegate Methods

- (void)scansMenuViewControllerDidSelectScan:(NSString *)scanId
{
	[super scansMenuViewControllerDidSelectScan:scanId];
}

#pragma mark - CRToolPanelViewController Delegate Methods

- (void)toolPanelViewController:(CRToolPanelViewController *)toolPanelViewController didSelectTool:(NSInteger)tool
{
	[super toolPanelViewController:toolPanelViewController didSelectTool:tool];
	[self drawStudentAnswers]; //Make sure answers are drawn after action
}

#pragma mark - CRStudentAnswerTable Delegate Methods

- (void)studentAnswerTableView:(CRStudentAnswerTableViewController *)studentAnswerTable didChangeAnswerSelection:(NSArray *)answers
{
    self.selectedAnswers = answers;
	
	NSMutableArray *colors = [[NSMutableArray alloc] init];
	for (id obj in answers) {
		[colors addObject:studentColors[[self.studentAnswers indexOfObject:obj]]];
	}
	
    self.selectedColors = colors;
    [self drawStudentAnswers];
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
