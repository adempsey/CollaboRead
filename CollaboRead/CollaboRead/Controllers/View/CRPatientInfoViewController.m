//
//  CRPatientInfoViewController.m
//  CollaboRead
//
//  Created by Hamid Mansoor on 12/1/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRPatientInfoViewController.h"

#define kTEXT_VIEW_FONT_SIZE 14.0

@interface CRPatientInfoViewController ()

/*!
 @brief Text view to display patientInfo string
 */
@property (nonatomic, readwrite, strong) UITextView *patientInfoTextView;

@end

@implementation CRPatientInfoViewController

-(void)setViewFrame:(CGRect)frame {
    self.view.frame = frame;
    self.patientInfoTextView.frame = CGRectMake(0,
                                                0,
                                                self.view.frame.size.width,
                                                self.view.frame.size.height);
}

- (instancetype)initWithPatientInfo:(NSString *)patientInfo
{
	if (self = [super init]) {
		self.infoText = patientInfo;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.patientInfoTextView = [[UITextView alloc] initWithFrame:CGRectMake(0,
																			0,
																			self.view.frame.size.width,
																			self.view.frame.size.height)];
	self.patientInfoTextView.text = self.infoText;
	self.patientInfoTextView.textColor = [UIColor whiteColor];
	self.patientInfoTextView.font = [UIFont systemFontOfSize:kTEXT_VIEW_FONT_SIZE];
	self.patientInfoTextView.backgroundColor = [UIColor clearColor];
	self.patientInfoTextView.editable = NO;
	[self.view addSubview:self.patientInfoTextView];
}

//Adjusts text view text when infoText is updated
- (void)setInfoText:(NSString *)infoText
{
	_infoText = infoText;
	self.patientInfoTextView.text = infoText;
}

@end
