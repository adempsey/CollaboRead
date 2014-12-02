//
//  CRPatientInfoViewController.m
//  CollaboRead
//
//  Created by Hamid Mansoor on 12/1/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRPatientInfoViewController.h"
#import "CRViewSizeMacros.h"
#import "CRColors.h"

@interface CRPatientInfoViewController ()
@property (nonatomic, readwrite, assign) BOOL tableIsVisible;

@end

#define kTableViewWidth 230.0
#define kTableViewMargin (kTableViewWidth/8)


@implementation CRPatientInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect screenBounds = LANDSCAPE_FRAME;
    CGFloat viewOriginY = TOP_BAR_HEIGHT;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGRect viewFrame = CGRectMake(screenBounds.size.width - kTableViewMargin,
                                  viewOriginY,
                                  kTableViewMargin,
                                  screenHeight - viewOriginY);
    self.view.backgroundColor = CR_COLOR_PRIMARY;
    [self.view setFrame:viewFrame];
    self.tableIsVisible = NO;
}

- (instancetype)initWithPatientInfo: (NSString *) patientInfo {
    UITextView *myTextView = [[UITextView alloc]initWithFrame:
                              CGRectMake(10, 50, 200, 350)];
    [myTextView setText:patientInfo];
    myTextView.textColor = [UIColor cyanColor];
    myTextView.backgroundColor = [UIColor clearColor];
    myTextView.editable = NO;
    myTextView.delegate = self;
    [self.view addSubview:myTextView];
    return self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)toggleTable
{
    self.tableIsVisible ? [self hideTable] : [self showTable];
}

- (void)setFullView:(BOOL)shouldBeFull
{
    CGRect viewFrame = self.view.frame;
    CGRect screenFrame = LANDSCAPE_FRAME;
    viewFrame.origin.x = screenFrame.size.width - (shouldBeFull ? kTableViewWidth : (kTableViewMargin));
    viewFrame.size.width = shouldBeFull ? kTableViewWidth : kTableViewMargin;
    self.view.frame = viewFrame;
}

- (void)showTable
{
//    currentTableFrame.origin.x = 0;
    
    [self setFullView:YES];
    
    [UIView animateWithDuration:0.25 animations:^{
//        self.view.frame = currentTableFrame;
    } completion:^(BOOL finished) {
        if (finished) {
            self.tableIsVisible = YES;
        }
    }];
}

- (void)hideTable
{
//    currentTableFrame.origin.x = kTableViewWidth;
    
    [UIView animateWithDuration:0.25 animations:^{
//        self.view.frame = currentTableFrame;
    } completion:^(BOOL finished) {
        if (finished) {
            self.tableIsVisible = NO;
            [self setFullView:NO];
        }
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
