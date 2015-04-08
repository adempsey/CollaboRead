//
//  CRToolPanelViewController.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 11/5/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kToolPanelTableViewWidth 90.0
#define kToolPanelTableViewMargin (kToolPanelTableViewWidth/8)
#define kToolPanelButtonDimension 60.0

typedef NS_ENUM(NSUInteger, kPanelSections) {
	kCR_PANEL_TOOL_PEN = 0,
	kCR_PANEL_TOOL_ERASER,
	kCR_PANEL_TOOL_UNDO,
	kCR_PANEL_TOOL_CLEAR,
    kCR_PANEL_TOOL_POINTER,
    kCR_PANEL_TOOL_SCANS,
    kCR_PANEL_TOOL_PATIENT_INFO,
	kCR_PANEL_TOOL_COUNT
};

/*!
 @class CRToolPanelViewController
 
 @discussion Controller for the tool bar for analyzing case images
 */
@interface CRToolPanelViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readwrite, weak) id delegate;

@end

/*!
 @protocol CRToolPanelViewControllerDelegate
 
 @discussion Provides interface with delegate for changing tool selection
 */
@protocol CRToolPanelViewControllerDelegate <NSObject>

@required

/*!
 Called when a tool has been newly selected
 @param toolPanelViewController
 The tool panel on which the event occurred
 @param tool
 The newly selected tool
 */
- (void)toolPanelViewController:(CRToolPanelViewController*)toolPanelViewController didSelectTool:(NSInteger)tool;
/*!
 Called when tools that trigger new views to appear (scans or patient info) are swapped from
 @param toolPanelViewController
 The tool panel on which the event occurred
 @param tool
 The newly selected tool
 */
- (void)toolPanelViewController:(CRToolPanelViewController*)toolPanelViewController didDeselectTool:(NSInteger)tool;

@end

