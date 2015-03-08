//
//  CRPatientInfoViewController.m
//  CollaboRead
//
//  Created by Hamid Mansoor on 12/1/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRPatientInfoViewController.h"

#define kVIEW_WIDTH 230.0
#define kTEXT_VIEW_FONT_SIZE 14.0

@interface CRPatientInfoViewController ()

@property (nonatomic, readwrite, strong) UITextView *patientInfoTextView;

@end

@implementation CRPatientInfoViewController

- (instancetype)initWithPatientInfo:(NSString *)patientInfo
{
	if (self = [super init]) {
		self.infoText = patientInfo;

		self.side = CR_SIDE_BAR_SIDE_RIGHT;
		self.width = kVIEW_WIDTH;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.patientInfoTextView = [[UITextView alloc] initWithFrame:CGRectMake(0,
																			0,
																			kVIEW_WIDTH,
																			super.view.frame.size.height)];
	self.patientInfoTextView.text = self.infoText;
	self.patientInfoTextView.textColor = [UIColor whiteColor];
	self.patientInfoTextView.font = [UIFont systemFontOfSize:kTEXT_VIEW_FONT_SIZE];
	self.patientInfoTextView.backgroundColor = [UIColor clearColor];
	self.patientInfoTextView.editable = NO;
	[self.view addSubview:self.patientInfoTextView];
}

- (void)setInfoText:(NSString *)infoText
{
	_infoText = infoText;
	self.patientInfoTextView.text = infoText;
}

@end
