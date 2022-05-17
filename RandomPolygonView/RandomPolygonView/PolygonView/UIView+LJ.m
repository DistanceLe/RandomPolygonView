//
//  UIView+LJ.m
//  LJTrack
//
//  Created by LiJie on 16/6/17.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import "UIView+LJ.h"
#import <objc/runtime.h>

@interface UIView ()

@property(nonatomic, strong)NSMutableDictionary* handlerDictionary;

@end

@implementation UIView (LJ)

- (CGFloat)lj_height{
    return self.frame.size.height;
}

- (void)setLj_height:(CGFloat)lj_height{
    CGRect temp = self.frame;
    temp.size.height = lj_height;
    self.frame = temp;
}

- (CGFloat)lj_width{
    return self.frame.size.width;
}

- (void)setLj_width:(CGFloat)lj_width{
    CGRect temp = self.frame;
    temp.size.width = lj_width;
    self.frame = temp;
}


- (CGFloat)lj_y{
    return self.frame.origin.y;
}

- (void)setLj_y:(CGFloat)lj_y{
    CGRect temp = self.frame;
    temp.origin.y = lj_y;
    self.frame = temp;
}

- (CGFloat)lj_x{
    return self.frame.origin.x;
}

- (void)setLj_x:(CGFloat)lj_x{
    CGRect temp = self.frame;
    temp.origin.x = lj_x;
    self.frame = temp;
}

//=====================================
-(void)setLj_origin:(CGPoint)lj_origin{
    CGRect frame=self.frame;
    frame.origin=lj_origin;
    self.frame=frame;
}
-(CGPoint)lj_origin{
    return self.frame.origin;
}

-(void)setLj_size:(CGSize)lj_size{
    CGRect frame=self.frame;
    frame.size=lj_size;
    self.frame=frame;
}

-(CGSize)lj_size{
    return self.frame.size;
}

-(CGFloat)lj_maxX{
    return self.lj_x+self.lj_width;
}

-(CGFloat)lj_maxY{
    return self.lj_y+self.lj_height;
}

-(CGFloat)lj_centerX{
    return self.lj_x+self.lj_width/2.0f;
}

-(CGFloat)lj_centerY{
    return self.lj_y+self.lj_height/2.0f;
}

-(void)setLj_maxX:(CGFloat)lj_maxX{
    CGRect frame=self.frame;
    frame.origin.x = lj_maxX-frame.size.width;
    self.frame=frame;
}

-(void)setLj_maxY:(CGFloat)lj_maxY{
    CGRect frame=self.frame;
    frame.origin.y = lj_maxY-frame.size.height;
    self.frame=frame;
}

-(void)setLj_centerX:(CGFloat)lj_centerX{
    CGPoint center=self.center;
    center.x=lj_centerX;
    self.center=center;
}

-(void)setLj_centerY:(CGFloat)lj_centerY{
    CGPoint center=self.center;
    center.y=lj_centerY;
    self.center=center;
}

static char temDicKey;
-(void)setHandlerDictionary:(NSMutableDictionary *)handlerDictionary
{
    objc_setAssociatedObject(self, &temDicKey, handlerDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMutableDictionary*)handlerDictionary
{
    return  objc_getAssociatedObject(self, &temDicKey);
}




-(void)addCustomGesture:(UIGestureRecognizer*)gesture{
    if (self.gestureRecognizers) {
        NSMutableArray* tempGestureArray = [NSMutableArray arrayWithArray:self.gestureRecognizers];
        for (UIGestureRecognizer* subGesture in tempGestureArray) {
            if ([subGesture isMemberOfClass:[gesture class]]) {
                //单双 击。。。
                if ([subGesture isMemberOfClass:[UITapGestureRecognizer class]]) {
                    if ([subGesture valueForKey:@"numberOfTapsRequired"] == [gesture valueForKey:@"numberOfTapsRequired"]) {
                        [self removeGestureRecognizer:subGesture];
                    }
                }else{
                    [self removeGestureRecognizer:subGesture];
                }
            }
        }
    }
    [self addGestureRecognizer:gesture];
}






-(void)addTapGestureHandler:(LJTapBlock)handler
{
    self.userInteractionEnabled=YES;
    if (!self.handlerDictionary) {
        self.handlerDictionary=[NSMutableDictionary dictionary];
    }
    [self.handlerDictionary setObject:handler forKey:@"tap"];
    UITapGestureRecognizer* tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handlerTapAction:)];
    
    [self addCustomGesture:tap];
    for (UITapGestureRecognizer* gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
            if (gesture.numberOfTapsRequired >= 2) {
                [tap requireGestureRecognizerToFail:gesture];
                break;
            }
        }
    }
}

-(void)addMultipleTap:(NSInteger)numTap gestureHandler:(LJTapBlock)handler{
    self.userInteractionEnabled=YES;
    if (!self.handlerDictionary) {
        self.handlerDictionary=[NSMutableDictionary dictionary];
    }
    [self.handlerDictionary setObject:handler forKey:@"doubleTap"];
    UITapGestureRecognizer* tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handlerDoubleTapAction:)];
    tap.numberOfTapsRequired=numTap;
    [self addCustomGesture:tap];
    
    for (UITapGestureRecognizer* gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
            if (gesture.numberOfTapsRequired==1) {
                [gesture requireGestureRecognizerToFail:tap];
                break;
            }
        }
    }
}
/**  添加一个滑动,拖拽，事件 */
-(void)addPanGestureHandler:(LJPanBlock)handler{
    self.userInteractionEnabled=YES;
    if (!self.handlerDictionary) {
        self.handlerDictionary=[NSMutableDictionary dictionary];
    }
    [self.handlerDictionary setObject:handler forKey:@"pan"];
    UIPanGestureRecognizer* pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlerPanAction:)];
    [pan setMinimumNumberOfTouches:1];
    [pan setMaximumNumberOfTouches:1];
    
    [self addCustomGesture:pan];
}

-(void)addLongGestureTime:(CGFloat)time Handler:(LJLongBlock)handler{
    self.userInteractionEnabled=YES;
    if (!self.handlerDictionary) {
        self.handlerDictionary=[NSMutableDictionary dictionary];
    }
    [self.handlerDictionary setObject:handler forKey:@"long"];
    UILongPressGestureRecognizer* longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handlerLongAction:)];
    longGesture.minimumPressDuration = time;
    [self addCustomGesture:longGesture];
}

/**  添加一个 双指放大缩小 手势 */
-(void)addPinchGestureHandler:(LJPinchBlock)handler{
    self.userInteractionEnabled=YES;
    if (!self.handlerDictionary) {
        self.handlerDictionary=[NSMutableDictionary dictionary];
    }
    [self.handlerDictionary setObject:handler forKey:@"pinch"];
    UIPinchGestureRecognizer* pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlerPinchAction:)];
    [self addCustomGesture:pinchGesture];
}
-(void)handlerPinchAction:(UIPinchGestureRecognizer*)pinchGesture{
    LJPinchBlock tempBlock = [self.handlerDictionary objectForKey:@"pinch"];
    if (tempBlock) {
        tempBlock(pinchGesture, self);
    }
}

-(void)handlerLongAction:(UILongPressGestureRecognizer*)longGesture{
    LJLongBlock tempBlock = [self.handlerDictionary objectForKey:@"long"];
    if (tempBlock) {
        tempBlock(longGesture, self);
    }
}

-(void)handlerPanAction:(UIPanGestureRecognizer*)pan{
    LJPanBlock tempBlock=[self.handlerDictionary objectForKey:@"pan"];
    if (tempBlock) {
        tempBlock(pan, self);
    }
}

-(void)handlerTapAction:(UITapGestureRecognizer*)tap{
    LJTapBlock tempBlock=[self.handlerDictionary objectForKey:@"tap"];
    if (tempBlock) {
        tempBlock(tap, self);
    }
}
-(void)handlerDoubleTapAction:(UITapGestureRecognizer*)tap{
    LJTapBlock tempBlock=[self.handlerDictionary objectForKey:@"doubleTap"];
    if (tempBlock) {
        tempBlock(tap, self);
    }
}

-(void)setSystemStyle{
    self.layer.cornerRadius = self.lj_height/2.0;
    self.layer.shadowOffset = CGSizeMake(-1, 3);
    self.layer.shadowColor = [UIColor greenColor].CGColor;
    self.layer.shadowRadius = 2;
    self.layer.shadowOpacity = 0.2;
    self.backgroundColor = [UIColor redColor];
}
-(void)setborderLineStyle{
    self.layer.cornerRadius = self.lj_height/2.0;
    self.layer.borderWidth=0.5;
    self.layer.borderColor=[[UIColor grayColor] colorWithAlphaComponent:0.5].CGColor;
    self.layer.masksToBounds=YES;
}

-(void)addShadowColor:(UIColor *)color{
    self.layer.shadowOffset = CGSizeMake(-1, 3);
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowRadius = 2;
    self.layer.shadowOpacity = 0.7;
}
-(void)setLayerCornerRadius:(CGFloat )Radius{
    self.layer.cornerRadius = Radius;
    self.layer.masksToBounds=YES;
}
@end
