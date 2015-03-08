//
//  CRImageScrollerController.m
//  CollaboRead
//
//  Created by Hannah Clark on 2/9/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "CRImageScrollBarController.h"

@interface CRImageScrollBarController ()
@property (nonatomic, assign) NSUInteger partitions;
@property (nonatomic, strong) NSArray *highlights;
@property (nonatomic, assign) BOOL isMoving;

@end

@implementation CRImageScrollBarController

-(instancetype)init {
    self = [super init];
    if (self) {
        self.view = [[CRImageScrollBar alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)setPartitions:(NSUInteger)partitions andHighlights:(NSArray *)highlights {
    self.view.scrollOffset = 0;
    self.partitions = partitions;
    self.highlights = highlights;
    self.view.partitions = partitions;
    self.view.highlights = highlights;
    [self.view setNeedsDisplay];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint loc = [[touches anyObject] locationInView:self.view];
    if (CGRectContainsPoint(self.view.bounds, loc)) {
        self.isMoving = YES;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGFloat loc = [[touches anyObject] locationInView:self.view].x;
    CGFloat halfSlider = self.view.frame.size.width/self.partitions/2;
    if (self.partitions < 2) {
        loc = halfSlider;
    } else if (loc < halfSlider) {
        loc = halfSlider;
    } else if (loc > self.view.frame.size.width - halfSlider) {
        loc = self.view.frame.size.width - halfSlider;
    }
    self.view.scrollOffset = loc - halfSlider;
    NSUInteger partition = loc / (self.view.frame.size.width/self.partitions);
    [self.delegate imageScroller:self didChangePosition:partition];
    
    
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    CGFloat loc = [[touches anyObject] locationInView:self.view].x;
    CGFloat halfSlider = self.view.frame.size.width/self.partitions/2;
    NSUInteger position = loc / (self.view.frame.size.width / self.partitions);
    loc = position * (self.view.frame.size.width/self.partitions) + halfSlider;
    if (self.partitions < 2) {
        loc = halfSlider;
    } else if (loc < halfSlider) {
        loc = halfSlider;
    } else if (loc > self.view.frame.size.width - halfSlider) {
        loc = self.view.frame.size.width - halfSlider;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.view.scrollOffset = loc - halfSlider;
    }];
    NSUInteger partition = loc / (self.view.frame.size.width/self.partitions);
    self.isMoving = NO;
    [self.delegate imageScroller:self didStopAtPosition:partition];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
