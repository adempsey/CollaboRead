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
    self.view.backgroundColor = [UIColor redColor];
    self.view.frame = CGRectMake(0, 0, 500, 20);
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)setWidth:(CGFloat)width {
    CGRect old = self.view.frame;
    old = CGRectMake(old.origin.x, old.origin.y, width, old.size.height);
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
    CGPoint loc = [[touches anyObject] locationInView:self.view];
    self.view.scrollOffset = loc.x;
    [self.view setNeedsDisplay];
    
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    CGFloat loc = [[touches anyObject] locationInView:self.view].x;
    NSUInteger position = loc / (self.view.frame.size.width / self.partitions);
    loc = position * (self.view.frame.size.width/self.partitions);
    self.view.scrollOffset = loc;
    [UIView animateWithDuration:0.2 animations:^{
        [self.view setNeedsDisplay];
    }];
    self.isMoving = NO;
    
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
