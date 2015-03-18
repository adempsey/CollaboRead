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

/*!
 @brief Table view to display tool buttons
 */
@property (nonatomic, readwrite, strong) UITableView *tableView;
/*!
 @brief Tool currently selected in table
 */
@property (nonatomic, readwrite, strong) NSIndexPath *selectedTool;

@end

@implementation CRToolPanelViewController

- (instancetype)init
{
	if (self = [super init]) {
		_selectedTool = [NSIndexPath indexPathForRow:kCR_PANEL_TOOL_PEN inSection:0];
	}
	return self;
}

-(void)loadView {
    CGFloat viewOriginY = CR_TOP_BAR_HEIGHT;
    CGRect screenFrame = CR_LANDSCAPE_FRAME;
    CGRect viewFrame = CGRectMake(0,
                                  viewOriginY,
                                  kToolPanelTableViewWidth,
                                  screenFrame.size.height - viewOriginY);
    UIView *view = [[UIView alloc] initWithFrame:viewFrame];
    
    view.backgroundColor = [UIColor clearColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorColor = [UIColor clearColor];
    
    [self.tableView selectRowAtIndexPath:self.selectedTool animated:NO scrollPosition:UITableViewScrollPositionNone];
    self.tableView.scrollEnabled = NO;
    self.tableView.contentInset = UIEdgeInsetsMake((kToolPanelTableViewWidth - kToolPanelButtonDimension)/ 2.0, 0, 0, 0);
    
    [view addSubview:self.tableView];
    self.view = view;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //This might not be done in a nib, so it's in viewDidLoad
    UIView *tableViewBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    tableViewBackgroundView.backgroundColor = CR_COLOR_PRIMARY;
    tableViewBackgroundView.alpha = 0.8;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = tableViewBackgroundView;
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
    return tableView.frame.size.height / (kCR_PANEL_TOOL_COUNT + 1);
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.delegate toolPanelViewController:self didSelectTool:indexPath.row];
    if(self.selectedTool.row == kCR_PANEL_TOOL_SCANS) { //May need to force deselect scans or transition to pen
        switch (indexPath.row) {
            case kCR_PANEL_TOOL_UNDO:
            case kCR_PANEL_TOOL_CLEAR:
                //Deselect scans to toggle, also switch to pen by cascading
                [self.delegate toolPanelViewController:self didDeselectTool:self.selectedTool.row];
            case kCR_PANEL_TOOL_SCANS:
                //Delegate already knows it was selected again, so just deselect from table and move to pen
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
                self.selectedTool = [NSIndexPath indexPathForRow:kCR_PANEL_TOOL_PEN inSection:0];
                [self.tableView selectRowAtIndexPath:self.selectedTool animated:NO scrollPosition:UITableViewScrollPositionNone];
                [self.delegate toolPanelViewController:self didSelectTool:self.selectedTool.row];
                break;
            case kCR_PANEL_TOOL_PATIENT_INFO:
            case kCR_PANEL_TOOL_PEN:
            case kCR_PANEL_TOOL_ERASER:
            case kCR_PANEL_TOOL_POINTER:
                //Deselect to toggle, no need to specify other tool
                [self.delegate toolPanelViewController:self didDeselectTool:self.selectedTool.row];
                self.selectedTool = indexPath;
            default:
                break;
        }
    } else if(self.selectedTool.row == kCR_PANEL_TOOL_PATIENT_INFO) {//May need to force deselect patient info or transition to pen
        switch (indexPath.row) {
            case kCR_PANEL_TOOL_UNDO:
            case kCR_PANEL_TOOL_CLEAR:
                //Deselect patient info to toggle, also switch to pen by cascading
                [self.delegate toolPanelViewController:self didDeselectTool:self.selectedTool.row];
            case kCR_PANEL_TOOL_PATIENT_INFO:
                //Delegate already knows it was selected again, so just deselect from table and move to pen
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
                self.selectedTool = [NSIndexPath indexPathForRow:kCR_PANEL_TOOL_PEN inSection:0];
                [self.tableView selectRowAtIndexPath:self.selectedTool animated:NO scrollPosition:UITableViewScrollPositionNone];
                [self.delegate toolPanelViewController:self didSelectTool:self.selectedTool.row];
                break;
            case kCR_PANEL_TOOL_SCANS:
            case kCR_PANEL_TOOL_PEN:
            case kCR_PANEL_TOOL_ERASER:
            case kCR_PANEL_TOOL_POINTER:
                //Deselect to toggle, no need to specify other tool
                [self.delegate toolPanelViewController:self didDeselectTool:self.selectedTool.row];
                self.selectedTool = indexPath;
            default:
                break;
        }
    } else if (indexPath.row == kCR_PANEL_TOOL_UNDO || indexPath.row == kCR_PANEL_TOOL_CLEAR) { //These tools do not remain selected and should return to previously selected tool, if not the patient info or scans
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
        case kCR_PANEL_TOOL_POINTER:
            title = @"CRToolPanelPointer.png";
            break;
        case kCR_PANEL_TOOL_SCANS:
            title = @"CRToolPanelScan.png";
            break;
        case kCR_PANEL_TOOL_PATIENT_INFO:
            title = @"CRToolPanelPatientInfo.png";
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
