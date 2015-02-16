//
//  CRStudentAnswerTableViewController.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 11/3/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRStudentAnswerTableViewController.h"
#import "CRUser.h"

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
@property (nonatomic, readwrite, strong) NSIndexPath *tempIndexPath;
@property (nonatomic, strong) NSArray *caseSets;
@property (nonatomic, strong) NSString *userID;

@end

@implementation CRStudentAnswerTableViewController

- (instancetype)initWithStudents:(NSArray*)students
{
	if (self = [super init]) {
        self.shouldShowStudentNames = NO;
		self.selectedStudents = [[NSMutableArray alloc] init];
        _students = [[NSArray alloc] initWithArray:students];
		self.side = CR_SIDE_BAR_SIDE_RIGHT;
		self.width = kTableViewWidth;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	CGRect tableViewFrame = CGRectMake(0, 0, kTableViewWidth, super.view.frame.size.height);
	self.tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStyleGrouped];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:self.tableView];
}

-(void)setStudents:(NSArray *)students
{
    _students = students;
    [self.tableView reloadData];
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
		id selectedStudent = self.students[indexPath.row];
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
		id owners = self.students[indexPath.row];

		if ([owners isKindOfClass:[CRUser class]]) {
			owners = [NSArray arrayWithObject:owners];
		}

		NSArray *ownersList = (NSArray*)owners;

        if(self.shouldShowStudentNames){//TODO: FIND A BETTER WAY TO HAVE STUDENT IDS AND SHOW NAMES!!!!!!
            NSMutableArray *ownerNames = [[NSMutableArray alloc] init];
            [ownersList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

				if ([obj isKindOfClass:[NSString class]]) {
                    NSString *userID = obj;
					[self.allUsers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
						NSString *temp = ((CRUser*) obj).userID;
						if ([userID isEqualToString:temp]){
							[ownerNames addObject:((CRUser*) obj).name];
							*stop = true;
						}
					}];
				}
            }];
            NSMutableString *title = [NSMutableString stringWithString:ownerNames[0]];
            for (int i = 1; i < [ownerNames count]; i ++) {
                [title appendFormat:@", %@", ownerNames[i]];
            }
            return title;
        }
        else {
            return [NSString stringWithFormat:@"Student %ld", (long) indexPath.row + 1];
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
