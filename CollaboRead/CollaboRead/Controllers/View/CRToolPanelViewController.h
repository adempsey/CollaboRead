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
#define kButtonDimension 60.0

typedef NS_ENUM(NSUInteger, kPanelSections) {
	kCR_PANEL_TOOL_PEN = 0,
	kCR_PANEL_TOOL_ERASER,
	kCR_PANEL_TOOL_UNDO,
	kCR_PANEL_TOOL_CLEAR,
    kCR_PANEL_TOOL_SCANS,
	kCR_PANEL_TOOL_COUNT
};

@interface CRToolPanelViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readwrite, weak) id delegate;
@property (nonatomic, readwrite, assign) BOOL toolPanelIsVisible;

- (void)toggleToolPanel;

@end

@protocol CRToolPanelViewControllerDelegate <NSObject>

@required
- (void)toolPanelViewController:(CRToolPanelViewController*)toolPanelViewController didSelectTool:(NSInteger)tool;
- (void)toolPanelViewController:(CRToolPanelViewController*)toolPanelViewController didDeselectTool:(NSInteger)tool;

@end

