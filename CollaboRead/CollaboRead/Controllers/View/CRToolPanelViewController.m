//
//  CRToolPanelViewController.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 11/5/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRToolPanelViewController.h"
#import "CRToolPanelCell.h"

#define kNavigationBarHeight 44.0 // bad but w/e
#define kTableViewWidth 90.0

@interface CRToolPanelViewController ()

@property (nonatomic, readwrite, strong) UITableView *tableView;
@property (nonatomic, readwrite, strong) NSIndexPath *selectedTool;

@end

@implementation CRToolPanelViewController

- (instancetype)init
{
	if (self = [super init]) {
		self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStyleGrouped];
		self.tableView.dataSource = self;
		self.tableView.delegate = self;
		
		self.selectedTool = [NSIndexPath indexPathForRow:kCR_PANEL_TOOL_PEN inSection:0];
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	CGRect screenBounds = [UIScreen mainScreen].bounds;
	CGFloat viewOriginY = kNavigationBarHeight + [UIApplication sharedApplication].statusBarFrame.size.height;
	CGRect viewFrame = CGRectMake(0,
								  viewOriginY,
								  kTableViewWidth,
								  screenBounds.size.height - viewOriginY);
	self.view.frame = viewFrame;
	self.view.backgroundColor = [UIColor clearColor];
	
	self.tableView.frame = CGRectMake(0, 80, self.view.frame.size.width, self.view.frame.size.height);
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.separatorColor = [UIColor clearColor];
	
	[self.tableView selectRowAtIndexPath:self.selectedTool animated:NO scrollPosition:UITableViewScrollPositionNone];
	
	[self.view addSubview:self.tableView];
}

#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return kCR_PANEL_TOOL_COUNT;
}

- (CRToolPanelCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CRToolPanelCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PanelCell"];
	
	if (!cell) {
		cell = [[CRToolPanelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PanelCell"];
	}
	
	cell.imageView.image = [self imageForCellAtIndexPath:indexPath];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kTableViewWidth;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.delegate toolPanelViewController:self didSelectTool:indexPath.row];
	
	if (indexPath.row == kCR_PANEL_TOOL_UNDO || indexPath.row == kCR_PANEL_TOOL_CLEAR) {
		[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
		[self.tableView selectRowAtIndexPath:self.selectedTool animated:NO scrollPosition:UITableViewScrollPositionNone];
		
	} else {
		self.selectedTool = indexPath;
	}
}

#pragma mark - Extra TableView Methods

- (UIImage*)imageForCellAtIndexPath:(NSIndexPath*)indexPath
{
	NSString *title;
	switch (indexPath.row) {
		case kCR_PANEL_TOOL_PEN:
			title = @"CRToolPanelPen.png";
			break;
		case kCR_PANEL_TOOL_ERASER:
			title = @"CRToolPanelEraser.png";
			break;
		case kCR_PANEL_TOOL_UNDO:
			title = @"CRToolPanelUndo.png";
			break;
		case kCR_PANEL_TOOL_CLEAR:
			title = @"CRToolPanelClear.png";
			break;
	}
	
	if (title) {
		UIImage *image = [UIImage imageNamed:title];
		image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		return image;
	}
	
	return nil;
}

@end
