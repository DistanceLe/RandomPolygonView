//
//  ViewController.m
//  RandomPolygonView
//
//  Created by lijie on 2022/5/17.
//

#import "ViewController.h"
#import "RandomView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    RandomView* subView = [[RandomView alloc]init];
    subView.frame = CGRectMake(100, 100, 200, 200);
    subView.backgroundColor = [[UIColor redColor]colorWithAlphaComponent:0.08];
//    subView.backgroundColor = [UIColor clearColor];
    subView.layer.masksToBounds = NO;
    subView.doubleClickToRemovePoint = YES;
    subView.gestureWidth = 50;
    [subView initData];
    [self.view addSubview:subView];
}


@end
