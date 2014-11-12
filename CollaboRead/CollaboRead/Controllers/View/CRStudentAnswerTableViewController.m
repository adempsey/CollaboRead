//
//  CRStudentAnswerTableViewController.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 11/3/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRStudentAnswerTableViewController.h"
#import "CRUser.h"
#import "CRColors.h"
#import "CRViewSizeMacros.h"

typedef NS_ENUM(NSUInteger, kStudentAnswerTableViewSections) {
	kSECTION_OPTIONS = 0,
	kSECTION_STUDENTS,
	kSECTION_COUNT
};

typedef NS_ENUM(NSUInteger, kStudentAnswerTableViewOptions) {
	kOPTION_SHOW_ALL = 0,
	kOPTION_HIDE_ALL,
	kOPTION_SHOW_NAMES,
	kOPTION_COUNT
};

#define kTableViewWidth 230.0
#define kTableViewMargin (kTableViewWidth/8)

@interface CRStudentAnswerTableViewController ()

@property (nonatomic, readwrite, strong) UITableView *tableView;
@property (nonatomic, readwrite, strong) NSMutableArray *selectedStudents;
@property (nonatomic, readwrite, assign) BOOL shouldShowStudentNames;
@property (nonatomic, readwrite, assign) BOOL tableIsVisible;
@property (nonatomic, readwrite, assign) BOOL didBeginMovingTable;

@end

@implementation CRStudentAnswerTableViewController

- (instancetype)initWithStudents:(NSArray*)students
{
	if (self = [super init]) {
		self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStyleGrouped];
		self.tableView.delegate = self;
		self.tableView.dataSource = self;
		
		self.students = [[NSArray alloc] initWithArray:students];
		self.selectedStudents = [[NSMutableArray alloc] init];
		
		self.shouldShowStudentNames = NO;
		self.tableIsVisible = NO;
		self.didBeginMovingTable = NO;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	CGRect screenBounds = LANDSCAPE_FRAME;
	CGFloat viewOriginY = TOP_BAR_HEIGHT;
	CGRect viewFrame = CGRectMake(screenBounds.size.width - kTableViewMargin,
								  viewOriginY,
								  kTableViewMargin,
								  screenBounds.size.height - viewOriginY);
	[self.view setFrame:viewFrame];
	
	CGRect tableViewFrame = CGRectMake(viewFrame.size.width, 0, kTableViewWidth, viewFrame.size.height);
	self.tableView.frame = tableViewFrame;

	UIView *tableViewBackgroundView = [[UIView alloc] initWithFrame:tableViewFrame];
	tableViewBackgroundView.backgroundColor = CR_COLOR_PRIMARY;
	tableViewBackgroundView.alpha = 0.9;
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.backgroundView = tableViewBackgroundView;

	[self.view addSubview:self.tableView];

	UIPanGestureRecognizer *tableSlideGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveTable:)];
	tableSlideGestureRecognizer.delegate = self;
	[self.view addGestureRecognizer:tableSlideGestureRecognizer];
}

- (void)moveTable:(UIPanGestureRecognizer*)gesture
{
	if (gesture.state == UIGestureRecognizerStateBegan) {
		self.didBeginMovingTable = YES;

		[self setFullView:YES];
	}

	if (gesture.state == UIGestureRecognizerStateChanged && self.didBeginMovingTable) {
		CGPoint translation = [gesture translationInView:self.view];
		CGPoint center = self.tableView.center;

		[self.tableView setCenter:CGPointMake(MAX(center.x + translation.x, kTableViewWidth/2), center.y)];
		[gesture setTranslation:CGPointZero inView:self.view];

	} else if (gesture.state == UIGestureRecognizerStateEnded) {
		if (self.tableView.center.x < 7*kTableViewWidth/8) {
			[self showTable];
		} else {
			[self hideTable];
		}

		self.didBeginMovingTable = NO;
	}
}

// Reduces area of view when not visible
// This allows the user to touch parts of the view below the panel when it's not shown
- (void)setFullView:(BOOL)shouldBeFull
{
	CGRect viewFrame = self.view.frame;
    CGRect screenFrame = LANDSCAPE_FRAME;
	viewFrame.origin.x = screenFrame.size.width - (shouldBeFull ? kTableViewWidth : (kTableViewMargin));
	viewFrame.size.width = shouldBeFull ? kTableViewWidth : kTableViewMargin;
	self.view.frame = viewFrame;
}

- (void)toggleTable
{
	self.tableIsVisible ? [self hideTable] : [self showTable];
}

- (void)showTable
{
	CGRect currentTableFrame = self.tableView.frame;
	currentTableFrame.origin.x = 0;

	[self setFullView:YES];

	[UIView animateWithDuration:0.25 animations:^{
		self.tableView.frame = currentTableFrame;
	} completion:^(BOOL finished) {
		if (finished) {
			self.tableIsVisible = YES;
		}
	}];
}

- (void)hideTable
{
	CGRect currentTableFrame = self.tableView.frame;
	currentTableFrame.origin.x = kTableViewWidth;

	[UIView animateWithDuration:0.25 animations:^{
		self.tableView.frame = currentTableFrame;
	} completion:^(BOOL finished) {
		if (finished) {
			self.tableIsVisible = NO;
			[self setFullView:NO];
		}
	}];
}

#pragma mark - UITableView Datasource Methods

// Right now, there are just two sections - options, and students
// For UI, maybe it would be best to have separate table view groups
// for each answer group? Would possibly be cleaner to include group names
// in section headers? We should talk about that

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return kSECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case kSECTION_OPTIONS:
			return kOPTION_COUNT;
			break;
		case kSECTION_STUDENTS:
			return self.students.count;
			break;
		default:
			return 0;
			break;
	}
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"StudentAnswerCell"];
	
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"StudentAnswerCell"];
	}
	
	cell.textLabel.text = [self titleForCellAtIndexPath:indexPath];
	cell.textLabel.textColor = [UIColor whiteColor];
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
	
	cell.accessoryType = [self accessoryTypeForCellAtIndexPath:indexPath];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

#pragma mark - UITableView Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == kSECTION_OPTIONS) {
		
		if (indexPath.row == kOPTION_SHOW_ALL) {
			self.selectedStudents = [self.students mutableCopy];
			[self.delegate studentAnswerTableView:self didChangeStudentSelection:[self.selectedStudents copy]];
			
		} else if (indexPath.row == kOPTION_HIDE_ALL) {
			[self.selectedStudents removeAllObjects];
			[self.delegate studentAnswerTableView:self didChangeStudentSelection:[self.selectedStudents copy]];
			
		} else if (indexPath.row == kOPTION_SHOW_NAMES) {
			self.shouldShowStudentNames = !self.shouldShowStudentNames;
	
		}
		
	} else if (indexPath.section == kSECTION_STUDENTS) {
		
		CRUser *selectedStudent = self.students[indexPath.row];
		
		if ([self.selectedStudents containsObject:selectedStudent]) {
			[self.selectedStudents removeObject:selectedStudent];
			
		} else {
			[self.selectedStudents addObject:selectedStudent];
			
		}
		
		[self.delegate studentAnswerTableView:self didChangeStudentSelection:[self.selectedStudents copy]];
	}
	
	[self.tableView reloadData];
	[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Extra TableView Methods

- (NSString*)titleForCellAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == kSECTION_OPTIONS) {
		switch (indexPath.row) {
			case kOPTION_SHOW_ALL:
				return @"Show All Answers";
				break;
			case kOPTION_HIDE_ALL:
				return @"Hide All Answers";
				break;
			case kOPTION_SHOW_NAMES:
				return @"Show Student Names";
				break;
			default:
				return @"";
		}
		
	} else if (indexPath.section == kSECTION_STUDENTS) {
		id student = self.students[indexPath.row];
		
		if ([student isKindOfClass:[CRUser class]]) {
			return self.shouldShowStudentNames ? ((CRUser*)student).name : [NSString stringWithFormat:@"Student %ld", (long) indexPath.row + 1];
		}
	}
	
	return @"";
}

- (NSInteger)accessoryTypeForCellAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == kSECTION_OPTIONS) {
		
		if (indexPath.row == kOPTION_SHOW_NAMES) {
			return self.shouldShowStudentNames ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
		}
		
	} else if (indexPath.section == kSECTION_STUDENTS) {
		
		BOOL isSelected = [self.selectedStudents containsObject:self.students[indexPath.row]];
		return isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
		
	}
	
	return UITableViewCellAccessoryNone;
}

@end
