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
	
	CGFloat viewOriginY = CR_STATUS_BAR_HEIGHT;
    CGFloat topBar = CR_TOP_BAR_HEIGHT;
    CGRect screenFrame = CR_LANDSCAPE_FRAME;
    
	CGRect viewFrame = CGRectMake(0,
								  viewOriginY,
								  kToolPanelTableViewWidth,
								  screenFrame.size.height - viewOriginY);
	self.view.frame = viewFrame;
	self.view.backgroundColor = [UIColor clearColor];
	
    self.tableView.frame = CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height);
	self.tableView.separatorColor = [UIColor clearColor];

	[self.tableView selectRowAtIndexPath:self.selectedTool animated:NO scrollPosition:UITableViewScrollPositionNone];
	self.tableView.scrollEnabled = NO;
	self.tableView.contentInset = UIEdgeInsetsMake((self.view.frame.size.height - topBar - kCR_PANEL_TOOL_COUNT * kToolPanelTableViewWidth) / 2.0, 0, 0, 0);

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
    else if (self.selectedTool.row == kCR_PANEL_TOOL_SCANS) {
        [self tableView:self.tableView didSelectRowAtIndexPath:self.selectedTool];
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
    if(self.selectedTool.row ==kCR_PANEL_TOOL_SCANS) {
        switch (indexPath.row) {
            case kCR_PANEL_TOOL_UNDO:
            case kCR_PANEL_TOOL_CLEAR:
                [self.delegate toolPanelViewController:self didDeselectTool:self.selectedTool.row];
            case kCR_PANEL_TOOL_SCANS:
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
                self.selectedTool = [NSIndexPath indexPathForRow:kCR_PANEL_TOOL_PEN inSection:0];
                [self.tableView selectRowAtIndexPath:self.selectedTool animated:NO scrollPosition:UITableViewScrollPositionNone];
                [self.delegate toolPanelViewController:self didSelectTool:self.selectedTool.row];
                break;
            case kCR_PANEL_TOOL_PEN:
            case kCR_PANEL_TOOL_ERASER:
            case kCR_PANEL_TOOL_ZOOM:
                [self.delegate toolPanelViewController:self didDeselectTool:self.selectedTool.row];
                //unzoom if another button is pressed
                self.selectedTool = indexPath;
            default:
                break;
        }
    } else if (self.selectedTool.row == kCR_PANEL_TOOL_ZOOM) {
        switch (indexPath.row) {
            case kCR_PANEL_TOOL_UNDO:
            case kCR_PANEL_TOOL_CLEAR:
                [self.delegate toolPanelViewController:self didDeselectTool:self.selectedTool.row];
            case kCR_PANEL_TOOL_ZOOM:
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
                self.selectedTool = [NSIndexPath indexPathForRow:kCR_PANEL_TOOL_PEN inSection:0];
                [self.tableView selectRowAtIndexPath:self.selectedTool animated:NO scrollPosition:UITableViewScrollPositionNone];
                [self.delegate toolPanelViewController:self didSelectTool:self.selectedTool.row];
                break;
            case kCR_PANEL_TOOL_PEN:
            case kCR_PANEL_TOOL_ERASER:
            case kCR_PANEL_TOOL_SCANS:
                [self.delegate toolPanelViewController:self didDeselectTool:self.selectedTool.row];
                //unzoom if another button is pressed
                self.selectedTool = indexPath;
            default:
                break;
        }
    } else if (indexPath.row == kCR_PANEL_TOOL_UNDO || indexPath.row == kCR_PANEL_TOOL_CLEAR) {
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
        case kCR_PANEL_TOOL_ZOOM:
            title = @"CRToolPanelZoom.png";
            break;
        case kCR_PANEL_TOOL_SCANS:
            title = @"CRToolPanelScan.png";
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
