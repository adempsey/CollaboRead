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
#import "CRAnswerSubmissionService.h"

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

@interface CRLecturerImageViewController ()

@property (nonatomic, strong) UIButton *showButton;
@property (nonatomic, strong) UIButton *hideButton;
@property (nonatomic, strong) NSArray *allStudents;
@property (nonatomic, strong) NSArray *selectedAnswers;
@property (nonatomic, strong) NSArray *selectedColors;
@property (nonatomic, strong) UIBarButtonItem *toggleStudentAnswerTableButton;
@property (nonatomic, strong) UIBarButtonItem *toggleStudentRefreshAnswerTableButton;
@property (nonatomic, strong) UIImageView *studentAnswerView;

@property (nonatomic, readwrite, strong) CRStudentAnswerTableViewController *studentAnswerViewController;

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
                        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), beg.coordinate.x, beg.coordinate.y);
                        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), fin.coordinate.x, fin.coordinate.y);
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
    [self.view addSubview:self.studentAnswerView];
    //CGFloat topBarHeight = self.navigationController.navigationBar.frame.size.height +
    //[UIApplication sharedApplication].statusBarFrame.size.height;
	self.view.autoresizesSubviews = NO;

	// Should pass array of CRUsers that have submitted answers
	// This workflow will need to be adjusted in the future, since this list will change as students submit answers
    [self loadStudents];
	self.studentAnswerViewController.delegate = self;
	[self.view addSubview:self.studentAnswerViewController.view];
    self.studentAnswerViewController.allUsers = self.allUsers;

	self.toggleStudentAnswerTableButton = [[UIBarButtonItem alloc] initWithTitle:@"Answers"
																					   style:UIBarButtonItemStylePlain
																					  target:self.studentAnswerViewController
																					  action:@selector(toggleTable)];
	self.navigationItem.rightBarButtonItem = self.toggleStudentAnswerTableButton;
    [self.view setNeedsDisplay];
	[[CRAnswerSubmissionService sharedInstance] setDidReceiveAnswerBlock:^(NSString* answer) {
		[self didReceiveAnswer:answer];
	}];
}

- (void)didReceiveAnswer:(NSString*)answerData
{
	[[CRAPIClientService sharedInstance] retrieveCaseSetsWithLecturer:self.lecturerID block:^(NSArray *array) {
        CRCaseSet *selectedCaseSet = array[self.indexPath.section];
        self.caseChosen = [selectedCaseSet.cases.allValues sortedArrayUsingSelector:@selector(compareDates:)][self.indexPath.row];
        
        NSMutableArray *students = [[NSMutableArray alloc] init];
        NSArray *answers = self.caseChosen.answers;
        [answers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [students addObject:((CRAnswer *)obj).owners];
        }];
        self.studentAnswerViewController.students = students;
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
    self.studentAnswerViewController = [[CRStudentAnswerTableViewController alloc] initWithStudents:self.allStudents];

}

#pragma mark - CRStudentAnswerTable Delegate Methods
- (void)studentAnswerTableView:(CRStudentAnswerTableViewController *)studentAnswerTable didChangeStudentSelection:(NSArray *)students
{
    NSMutableArray *selectedAnswers = [[NSMutableArray alloc] init];;
	NSMutableArray *colors = [[NSMutableArray alloc] init];
    [self.caseChosen.answers enumerateObjectsUsingBlock:^(id obj, NSUInteger ansIdx, BOOL *stop) {
        CRAnswer *currAnswer = obj;
        [students enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSArray *currOwners = obj;
            if ([currAnswer.owners isEqualToArray:currOwners]){
                [selectedAnswers addObject:currAnswer];
                [colors addObject:studentColors[ansIdx % 15]];
                *stop = true;
            }
        }];
    }];
    self.selectedAnswers = selectedAnswers;
    self.selectedColors = colors;
    [self drawStudentAnswers];
}

-(void)studentAnswerTableView:(CRStudentAnswerTableViewController *)studentAnswerTableView didRefresh:(CRCase *)refreshedCase{
    self.caseChosen.answers = refreshedCase.answers;
}

-(void) scansMenuViewControllerDidSelectScan:(NSString *)scanId
{
    [super scansMenuViewControllerDidSelectScan:scanId];
    self.studentAnswerView.frame = self.imgFrame;
    [self drawStudentAnswers];
}

- (void)toolPanelViewController:(CRToolPanelViewController *)toolPanelViewController didSelectTool:(NSInteger)tool
{
    [super toolPanelViewController:toolPanelViewController didSelectTool:tool];
    [self drawStudentAnswers];
}

@end
