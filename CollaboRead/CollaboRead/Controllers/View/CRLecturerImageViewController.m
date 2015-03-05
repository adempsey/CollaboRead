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

#define studentColors @[@{@"red":@0, @"green": @255, @"blue" : @0}, \
                        @{@"red":@0, @"green": @0, @"blue" : @255}, \
                        @{@"red":@255, @"green": @255, @"blue" : @0}, \
                        @{@"red":@255, @"green": @0, @"blue" : @255}, \
                        @{@"red":@0, @"green": @255, @"blue" : @255}, \
                        @{@"red":@255, @"green": @150, @"blue" : @100}, \
                        @{@"red":@175, @"green": @255, @"blue" : @50}, \
                        @{@"red":@175, @"green": @255, @"blue" : @255}, \
                        @{@"red":@175, @"green": @100, @"blue" : @255}, \
                        @{@"red":@175, @"green": @255, @"blue" : @200}, \
                        @{@"red":@255, @"green": @50, @"blue" : @100}, \
                        @{@"red":@150, @"green": @150, @"blue" : @255}, \
                        @{@"red":@255, @"green": @200, @"blue" : @255}, \
                        @{@"red":@0, @"green": @150, @"blue" : @150}, \
                        @{@"red":@150, @"green": @100, @"blue" : @100}]

#define kCR_SIDE_BAR_TOGGLE_SHOW @"Show Answer Table"
#define kCR_SIDE_BAR_TOGGLE_HIDE @"Hide Answer Table"

@interface CRLecturerImageViewController ()

@property (nonatomic, strong) UIButton *showButton;
@property (nonatomic, strong) UIButton *hideButton;
@property (nonatomic, strong) NSArray *allStudents;
@property (nonatomic, strong) NSArray *selectedAnswers;
@property (nonatomic, strong) NSArray *selectedColors;
@property (nonatomic, strong) UIBarButtonItem *toggleStudentAnswerTableButton;
@property (nonatomic, strong) UIImageView *studentAnswerView;

@property (nonatomic, readwrite, strong) CRStudentAnswerTableViewController *studentAnswerTableViewController;

@end

@implementation CRLecturerImageViewController

-(void)drawStudentAnswers
{
    NSString *scanID = ((CRScan *)self.caseChosen.scans[self.scanIndex]).scanID;
    NSString *sliceID = ((CRSlice *)((CRScan *)self.caseChosen.scans[self.scanIndex]).slices[self.sliceIndex]).sliceID;
    UIGraphicsBeginImageContext(self.imgFrame.size);//Draw only in image
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
    [self.selectedAnswers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary* color = self.selectedColors[idx];
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), [color[@"red"] floatValue], [color[@"green"] floatValue], [color[@"blue"] floatValue], 1.0);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
        [((CRAnswer *)obj).drawings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CRAnswerLine *line = obj;
            if ([line.scanID isEqualToString: scanID] && [line.sliceID isEqualToString:sliceID]) {
                for (int i = 1; i < [line.data count]; i++) {
                    CRAnswerPoint *beg = [line.data objectAtIndex:i - 1];
                    if (!beg.isEndPoint) {
                        CRAnswerPoint *fin = [line.data objectAtIndex:i];
                        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), beg.coordinate.x * self.currZoom, beg.coordinate.y * self.currZoom);
                        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), fin.coordinate.x * self.currZoom, fin.coordinate.y * self.currZoom);
                    }
                }
                CGContextStrokePath(UIGraphicsGetCurrentContext());
                *stop = true;
            }
        }];

        
    }];
    
    self.studentAnswerView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.studentAnswerView setAlpha:1.0];
    UIGraphicsEndImageContext();
}

-(void)loadAndScaleImage:(UIImage *)img {
    [super loadAndScaleImage:img];
    if (self.studentAnswerView == nil) {
        self.studentAnswerView = [[UIImageView alloc] init];
    }
    self.studentAnswerView.frame = self.imgFrame;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.studentAnswerView = [[UIImageView alloc] init];
    self.studentAnswerView.frame = self.imgFrame;
    [self.limView addSubview:self.studentAnswerView];
	self.view.autoresizesSubviews = NO;

	// Should pass array of CRUsers that have submitted answers
	// This workflow will need to be adjusted in the future, since this list will change as students submit answers
    [self loadStudents];
	self.studentAnswerTableViewController.delegate = self;
	[self.view addSubview:self.studentAnswerTableViewController.view];

    NSArray *scanHighlights = [self.caseChosen answerScans];
    self.scansMenuController.highlights = scanHighlights;

	self.toggleStudentAnswerTableButton = [[UIBarButtonItem alloc] initWithTitle:kCR_SIDE_BAR_TOGGLE_HIDE style:UIBarButtonItemStylePlain target:nil action:nil];
	self.toggleStudentAnswerTableButton.possibleTitles = [NSSet setWithArray:@[kCR_SIDE_BAR_TOGGLE_HIDE, kCR_SIDE_BAR_TOGGLE_SHOW]];
	self.studentAnswerTableViewController.toggleButton = self.toggleStudentAnswerTableButton;
	self.navigationItem.rightBarButtonItem = self.toggleStudentAnswerTableButton;

	[[CRAnswerRefreshService sharedInstance] setUpdateBlock:^{
		[self refreshAnswers];
	}];
	
	[[CRAnswerRefreshService sharedInstance] initiateConnectionWithCase:self.caseChosen];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[CRAnswerRefreshService sharedInstance] disconnect];
}

- (void)refreshAnswers
{
	[[CRAPIClientService sharedInstance] retrieveCaseSetsWithLecturer:self.lecturerID block:^(NSArray *array, NSError *error) {
		if (!error) {
			CRCaseSet *selectedCaseSet = array[self.indexPath.section];
			self.caseChosen = [selectedCaseSet.cases.allValues sortedArrayUsingSelector:@selector(compareDates:)][self.indexPath.row];
			
			NSMutableArray *students = [[NSMutableArray alloc] init];
			NSArray *answers = self.caseChosen.answers;
            NSArray *scanHighlights = [self.caseChosen answerScans];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.studentAnswerTableViewController.answerList = answers;
                [self.scrollBar reloadData];
                self.scansMenuController.highlights = scanHighlights;
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

- (void)loadStudents
{
    NSMutableArray *allStudents = [[NSMutableArray alloc] init];;
    NSArray *answers = self.caseChosen.answers;
    
    [answers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [allStudents addObject:((CRAnswer *)obj).owners];
    }];
    self.allStudents = allStudents;
    self.studentAnswerTableViewController = [[CRStudentAnswerTableViewController alloc] initWithAnswerList:answers];

}

-(void)zoomOut {
    [super zoomOut];
    self.studentAnswerView.frame = self.imgFrame;
}

-(void)panZoom:(CGPoint)translation {
    [super panZoom:translation];
    self.studentAnswerView.frame = self.imgFrame;
}

-(void)zoomImageToScale:(CGFloat)scale {
    [super zoomImageToScale:scale];
    self.studentAnswerView.frame = self.imgFrame;
}

#pragma mark - CRStudentAnswerTable Delegate Methods
- (void)studentAnswerTableView:(CRStudentAnswerTableViewController *)studentAnswerTable didChangeAnswerSelection:(NSArray *)answers
{
    self.selectedAnswers = answers;
	
	NSMutableArray *colors = [[NSMutableArray alloc] init];
#warning colors are inconsistent
	for (id obj in answers) {
		[colors addObject:studentColors[0]];
	}
	
    self.selectedColors = colors;
    [self drawStudentAnswers];
}

-(void)studentAnswerTableView:(CRStudentAnswerTableViewController *)studentAnswerTableView didRefresh:(CRCase *)refreshedCase{
    self.caseChosen.answers = refreshedCase.answers;
    [self.scrollBar reloadData];
}

-(void) scansMenuViewControllerDidSelectScan:(NSString *)scanId
{
    [super scansMenuViewControllerDidSelectScan:scanId];
    self.studentAnswerView.frame = self.imgFrame;
    [self.scrollBar reloadData];
    [self drawStudentAnswers];
}

- (void)toolPanelViewController:(CRToolPanelViewController *)toolPanelViewController didSelectTool:(NSInteger)tool
{
    [super toolPanelViewController:toolPanelViewController didSelectTool:tool];
    [self drawStudentAnswers];
}

-(UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    CRCarouselCell *cView = (CRCarouselCell *)[super carousel:carousel viewForItemAtIndex:index reusingView:view];
    if ([[self.caseChosen answerSlicesForScan:((CRScan *)self.caseChosen.scans[self.scanIndex]).scanID] containsObject:@(index)]) {
        cView.isHighlighted = YES;
    } else {
        cView.isHighlighted = NO;
    }
    return cView;
}

#pragma mark - iCarousel Delegate Methods

-(void) carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    [super carouselCurrentItemIndexDidChange:carousel];
    [self drawStudentAnswers];
}

#pragma mark - CRSideBarViewController Delegate Methods

- (void)CRSideBarViewController:(CRSideBarViewController *)sideBarViewController didChangeVisibility:(BOOL)visible
{
	self.toggleStudentAnswerTableButton.title = visible ? kCR_SIDE_BAR_TOGGLE_HIDE : kCR_SIDE_BAR_TOGGLE_SHOW;
}

@end
