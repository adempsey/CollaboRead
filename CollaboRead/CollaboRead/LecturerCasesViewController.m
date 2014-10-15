//
//  LecturerCasesViewController.m
//  CollaboRead
//
//  Created by Hannah Clark on 10/15/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "LecturerCasesViewController.h"
#import "ImageController.h"
#import "UserKeys.h"
#import "CaseKeys.h"
#import "CaseCell.h"

@interface LecturerCasesViewController()
{
    NSURLConnection *currentConnection;
    BOOL connectionFin;
    NSIndexPath *selectedPath;
}

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;

@end

@implementation LecturerCasesViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = [self.lecturer objectForKey:U_NAME];
    self.caseSets =[self.lecturer objectForKey:CASE_GROUPS];
    NSString *urlString = [NSString stringWithFormat: @"http://collaboread.herokuapp.com/lecturercases?lecturerID=%@", [self.lecturer objectForKey:ID_NUM]];
    NSURL *reqUrl = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:reqUrl];
    if (currentConnection) {
        [currentConnection cancel];
        currentConnection = nil;
    }
    connectionFin = NO;
    currentConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (connectionFin) {
        return [[[self.caseSets objectAtIndex:section] objectForKey: CASES] count];
    }
    else {
        return 0;
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.caseSets count];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CaseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CaseCell" forIndexPath:indexPath];
    cell.name.text = [[[[self.caseSets objectAtIndex:indexPath.section] objectForKey:CASES] objectAtIndex:indexPath.row] objectForKey:C_NAME];
    cell.image.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[[[[self.caseSets objectAtIndex:indexPath.section] objectForKey:CASES] objectAtIndex:indexPath.row] objectForKey:IMAGE] objectAtIndex:0]]]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    selectedPath = indexPath;
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark – UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*) collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(200, 200);
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(50, 50, 30, 30);
}

#pragma mark - NSURLConnectionDelegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection Error: %@", error);
    connection = nil;
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSError *error;
    NSArray *caseSets =[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    self.caseSets = caseSets;
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    connectionFin = YES;
    currentConnection = nil;
    [self.collectionView reloadData];
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     NSLog(@"before");
     ImageController *nextController = segue.destinationViewController;
     nextController.caseChosen = [[[self.caseSets objectAtIndex:selectedPath.section] objectForKey:CASES] objectAtIndex:selectedPath.row];
     NSLog(@"segue");
     
 }


@end
