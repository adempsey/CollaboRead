//
//  CRToolPanelViewController.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 11/5/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRToolPanelViewController.h"
#import "CRToolPanelCell.h"
#import "CRColors.h"
#import "CRViewSizeMacros.h"

#define kButtonDimension 60.0

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

		self.toolPanelIsVisible = YES;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	CGFloat viewOriginY = TOP_BAR_HEIGHT;
    
    CGRect screenFrame = LANDSCAPE_FRAME;
    
	CGRect viewFrame = CGRectMake(0,
								  viewOriginY,
								  kToolPanelTableViewWidth,
								  screenFrame.size.height - viewOriginY);
	self.view.frame = viewFrame;
	self.view.backgroundColor = [UIColor clearColor];
	
	self.tableView.frame = self.view.frame;
	self.tableView.separatorColor = [UIColor clearColor];

	[self.tableView selectRowAtIndexPath:self.selectedTool animated:NO scrollPosition:UITableViewScrollPositionNone];
	self.tableView.scrollEnabled = NO;
	self.tableView.contentInset = UIEdgeInsetsMake(80, 0, 0, 0);

	UIView *tableViewBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	tableViewBackgroundView.backgroundColor = CR_COLOR_PRIMARY;
	tableViewBackgroundView.alpha = 0.8;
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.backgroundView = tableViewBackgroundView;

	[self.view addSubview:self.tableView];
}

// Reduces area of view when not visible
// This allows the user to touch parts of the view below the panel when it's not shown
- (void)setFullView:(BOOL)shouldBeFull
{
	CGRect viewFrame = self.view.frame;
	viewFrame.size.width = shouldBeFull ? kToolPanelTableViewWidth : kToolPanelTableViewMargin;
	self.view.frame = viewFrame;
}

- (void)toggleToolPanel
{
	CGRect currentTableFrame = self.tableView.frame;
	currentTableFrame.origin.x = self.toolPanelIsVisible ? -kToolPanelTableViewWidth : 0;

	if (!self.toolPanelIsVisible) {
		[self setFullView:YES];
		self.tableView.alpha = 1.0;
	}

	[UIView animateWithDuration:0.25 animations:^{
		self.tableView.frame = currentTableFrame;
	} completion:^(BOOL finished) {
		if (finished) {
			self.toolPanelIsVisible = !self.toolPanelIsVisible;
			if (!self.toolPanelIsVisible) {
				[self setFullView:NO];
				self.tableView.alpha = 0.0;
			}
		}
	}];
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
	return kToolPanelTableViewWidth;
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
