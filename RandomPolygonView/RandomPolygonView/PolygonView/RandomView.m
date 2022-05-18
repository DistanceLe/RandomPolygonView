//
//  RandomView.m
//  RandomPolygonView
//
//  Created by lijie on 2022/5/16.
//

#import "RandomView.h"
#import "UIView+LJ.h"


//@interface LJLinePoint : NSObject
//
//@property (assign, nonatomic) CGFloat x;
//@property (assign, nonatomic) CGFloat y;
//
//@end
//@implementation LJLinePoint
//@end


@interface RandomView ()


@property(nonatomic, strong)NSMutableArray* pointsArray;

@property(assign, nonatomic)NSInteger selectedIndex;
@property(assign, nonatomic)NSInteger touchIndex;
@property(nonatomic, assign)CGPoint originCenter;
@property(nonatomic, assign)CGPoint superBeginTouchPoint;

@property(assign, nonatomic)BOOL hasEqualBefore;
@property(assign, nonatomic)BOOL hasEqualAfter;

@property (nonatomic, strong) NSMutableArray* layerArray;

@end

@implementation RandomView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.lineColor = [UIColor greenColor];
        self.pointColor = [UIColor redColor];
        
        self.lineWidth = 2;
        self.pointWidth = 6;
        self.gestureWidth = 50;
        
        self.autoOptimize = YES;
        
        self.hasEqualAfter = NO;
        self.hasEqualBefore = NO;
        
        self.doubleClickToRemovePoint = NO;
        
    }
    return self;
}


-(void)initData{
    self.touchIndex = -1;
    self.selectedIndex = -1;
    self.pointsArray = [NSMutableArray array];
    self.layerArray = [NSMutableArray array];
    
    float x = self.lj_x;
    float y = self.lj_y;
    float width = self.lj_width;
    float height = self.lj_height;
    
    //各个点 在父视图上面的位置
    //点的个数一定是偶数，从第一个点开始是实点，第二个是虚点。这样排序下来
    [self.pointsArray addObjectsFromArray:@[@(CGPointMake(x+0, y+0)),
                                            @(CGPointMake(x+0.5*width, y+0)),
                                            
                                            @(CGPointMake(x+1*width, y+0)),
                                            @(CGPointMake(x+1*width, y+0.5*height)),
                                            
                                            @(CGPointMake(x+1*width, y+1*height)),
                                            @(CGPointMake(x+0.5*width, y+1*height)),
                                            
                                            @(CGPointMake(x+0, y+1*height)),
                                            @(CGPointMake(x+0, y+0.5*height))]];
    
    [self setNeedsDisplay];
    
    @weakify(self);
    [self addPanGestureHandler:^(UIPanGestureRecognizer *panGesture, UIView *itself) {
        @strongify(self);
        
        if (panGesture.state == UIGestureRecognizerStateBegan) {
            self.originCenter = self.center;
            
//            CGPoint begingPoint = [panGesture locationInView:self];
            self.superBeginTouchPoint = [panGesture locationInView:self.superview];
//            DLog(@"自身开始点%.1f, %.1f", begingPoint.x, begingPoint.y);
            DLog(@"父视图开始点%.1f, %.1f", self.superBeginTouchPoint.x, self.superBeginTouchPoint.y);
            
            //计算出需要移动的点
            NSInteger tempIndex = -1;
            CGFloat minLength = 1000;
            for (NSInteger i = 0; i<self.pointsArray.count; i++) {
                CGPoint subPoint = [self.pointsArray[i] CGPointValue];
                
                CGFloat tempLength = [self getLengthFromPoint:subPoint toPoint:self.superBeginTouchPoint];
                if (tempLength < self.gestureWidth && minLength > tempLength) {
                    tempIndex = i;
                    minLength = tempLength;
                }
            }
            
            self.touchIndex = tempIndex;
            if (tempIndex == -1) {
                DLog(@"没有点❌");
                return;
            }
            DLog(@"✅开始点：%ld  %.1f, %.1f", self.touchIndex, self.superBeginTouchPoint.x, self.superBeginTouchPoint.y);
            [self beginGesture];
            
        }else if (panGesture.state == UIGestureRecognizerStateChanged) {
            
            if (self.touchIndex == -1){
                //移动

            }else if(self.touchIndex >= 0){
                //拖拽点
                CGPoint translation = [panGesture translationInView:self.superview];
                
                [self movePointOffset:translation];
                
                [panGesture setTranslation:CGPointZero inView:self.superview];
            }
        }else if (panGesture.state == UIGestureRecognizerStateEnded ||
                  panGesture.state == UIGestureRecognizerStateCancelled ||
                  panGesture.state == UIGestureRecognizerStateFailed){
            
            
            [self endGesture];
        }
    }];
    
    [self addMultipleTap:2 gestureHandler:^(UITapGestureRecognizer *tapGesture, UIView *itself) {
        @strongify(self);
        if (self.doubleClickToRemovePoint) {
            NSInteger tempIndex = -1;
            CGFloat minLength = 1000;
            CGPoint superTouchPoint = [tapGesture locationInView:self.superview];
            
            for (NSInteger i = 0; i<self.pointsArray.count; i++) {
                CGPoint subPoint = [self.pointsArray[i] CGPointValue];
                
                CGFloat tempLength = [self getLengthFromPoint:subPoint toPoint:superTouchPoint];
                if (tempLength < self.gestureWidth && minLength > tempLength) {
                    tempIndex = i;
                    minLength = tempLength;
                }
            }
            if (tempIndex != -1) {
                [self deletePointWithIndex:tempIndex];
            }
        }
    }];
    [self addTapGestureHandler:^(UITapGestureRecognizer *tapGesture, UIView *itself) {
        @strongify(self);
        
        NSInteger tempIndex = -1;
        CGFloat minLength = NSIntegerMax;
        CGPoint superTouchPoint = [tapGesture locationInView:self.superview];
        
        for (NSInteger i = 0; i<self.pointsArray.count; i++) {
            CGPoint subPoint = [self.pointsArray[i] CGPointValue];
            
            CGFloat tempLength = [self getLengthFromPoint:subPoint toPoint:superTouchPoint];
            if (tempLength < self.gestureWidth && minLength > tempLength) {
                tempIndex = i;
                minLength = tempLength;
            }
        }
        
        if (self.selectedIndex == tempIndex) {
            [self selectedIndexCallBack:-1];
        }else{
            [self selectedIndexCallBack:tempIndex];
        }
        [self setNeedsDisplay];
    }];
}

-(void)selectedIndexCallBack:(NSInteger)index{
    self.selectedIndex = index;
    if (index == -1) {
        if (self.pointSelectedHandler) {
            self.pointSelectedHandler(CGPointZero, -1);
        }
    }else{
        if (self.pointSelectedHandler) {
            self.pointSelectedHandler([self.pointsArray[self.selectedIndex] CGPointValue], self.selectedIndex);
        }
    }
}

-(void)beginGesture{
    DLog(@"开始 手势🤚");
    [self.superview bringSubviewToFront:self];
    self.hasEqualAfter = NO;
    self.hasEqualBefore = NO;
    
    [self selectedIndexCallBack:self.touchIndex];
}

-(void)endGesture{
    DLog(@"结束 手势🤚");

    if(self.touchIndex >= 0){
        //拖拽点结束了， 拖拽的点变成实点，同时左右再各生成一个虚点，其他点保持不变
        CGPoint currentPoint = [self.pointsArray[self.touchIndex] CGPointValue];
        NSInteger hasInsertPoint = 0;
        
        if (!(self.autoOptimize && self.hasEqualBefore)) {
            //计算出 新生成的点
            CGPoint beforePoint = [self.pointsArray[(self.touchIndex==0?self.pointsArray.count-1:self.touchIndex-1)] CGPointValue];
            CGPoint newPoint1 = CGPointMake(fabs(currentPoint.x+beforePoint.x)/2.0, fabs(currentPoint.y+beforePoint.y)/2.0);
            
            //插入新的点
            [self.pointsArray insertObject:@(newPoint1) atIndex:(self.touchIndex)];
            
            if (self.selectedIndex == self.touchIndex) {
                [self selectedIndexCallBack:self.touchIndex+1];
            }
            hasInsertPoint = 1;
            DLog(@"新加点＋:%.1f,%.1f", newPoint1.x,newPoint1.y);
        }
        
        if (!(self.autoOptimize && self.hasEqualAfter)) {
            self.touchIndex += hasInsertPoint;
            CGPoint afterPoint = [self.pointsArray[self.touchIndex==(self.pointsArray.count-1)?0:self.touchIndex+1] CGPointValue];
            CGPoint newPoint2 = CGPointMake(fabs(currentPoint.x+afterPoint.x)/2.0, fabs(currentPoint.y+afterPoint.y)/2.0);
            
            //插入新的点
            [self.pointsArray insertObject:@(newPoint2) atIndex:(self.touchIndex+1)];
            DLog(@"新加点＋:%.1f,%.1f", newPoint2.x, newPoint2.y);
        }
        
        
        [self setNeedsDisplay];
    }
    
    
    self.hasEqualAfter = NO;
    self.hasEqualBefore = NO;
    self.touchIndex = -2;
}

/**  移动一个点的时候， 就需要更新一次当前视图的Frame */
-(void)movePointOffset:(CGPoint)offset{
    
    CGPoint subPoint = [self.pointsArray[self.touchIndex] CGPointValue];
    
    CGPoint newPoint = CGPointMake((subPoint.x + offset.x), (subPoint.y + offset.y));
    
    //相同斜率上面的点 不会作为锚点固定位置
    if (self.autoOptimize && self.pointsArray.count >= 4) {
        
        NSInteger beforeIndex = (self.touchIndex==0?self.pointsArray.count-1:self.touchIndex-1);
        NSInteger afterIndex = (self.touchIndex==(self.pointsArray.count-1)?0:self.touchIndex+1);
        
        CGPoint beforePoint = [self.pointsArray[beforeIndex] CGPointValue];
        CGPoint afterPoint = [self.pointsArray[afterIndex] CGPointValue];
        
        NSInteger beforeIndex2 = (beforeIndex==0?self.pointsArray.count-1:beforeIndex-1);
        NSInteger afterIndex2 = (afterIndex==(self.pointsArray.count-1)?0:afterIndex+1);
        
        CGPoint beforePoint2 = [self.pointsArray[beforeIndex2] CGPointValue];
        CGPoint afterPoint2 = [self.pointsArray[afterIndex2] CGPointValue];
        
        
        if ((subPoint.x - beforePoint2.x)/(subPoint.y - beforePoint2.y) ==
            (beforePoint.x - beforePoint2.x)/(beforePoint.y - beforePoint2.y)) {
            //斜率一样时
            CGPoint newBeforPoint = CGPointMake((newPoint.x+beforePoint2.x)/2.0, (newPoint.y+beforePoint2.y)/2.0);
            self.pointsArray[beforeIndex] = @(newBeforPoint);
            
            self.hasEqualBefore = YES;
        }
        if ((subPoint.x - afterPoint2.x)/(subPoint.y - afterPoint2.y) ==
            (afterPoint.x - afterPoint2.x)/(afterPoint.y - afterPoint2.y)) {
            //斜率一样时
            CGPoint newAfterPoint = CGPointMake((newPoint.x+afterPoint2.x)/2.0, (newPoint.y+afterPoint2.y)/2.0);
            self.pointsArray[afterIndex] = @(newAfterPoint);
            
            self.hasEqualAfter = YES;
        }
    }
    
    //移动到 新的位置：
    self.pointsArray[self.touchIndex] = @(newPoint);
    DLog(@"移动中......%.1f, %.1f  新点:(%.1f,%.1f)", offset.x, offset.y, newPoint.x,newPoint.y);
    
    [self refreshFrame];
}
-(void)refreshFrame{
    //计算新的Frame
    CGFloat minX = 0;
    CGFloat minY = 0;
    CGFloat maxX = 0;
    CGFloat maxY = 0;
    
    for (NSInteger i = 0; i<self.pointsArray.count; i++) {
        CGPoint subPoint = [self.pointsArray[i] CGPointValue];
        
        if (i==0) {
            minX = subPoint.x;
            minY = subPoint.y;
            maxX = subPoint.x;
            maxY = subPoint.y;
        }else{
            if (minX > subPoint.x) {
                minX = subPoint.x;
            }
            if (minY > subPoint.y) {
                minY = subPoint.y;
            }
            if (maxX < subPoint.x) {
                maxX = subPoint.x;
            }
            if (maxY < subPoint.y) {
                maxY = subPoint.y;
            }
        }
    }
    self.frame = CGRectMake(minX, minY, maxX-minX, maxY-minY);
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (CALayer* layer in self.layerArray) {
        if (layer) {
            layer.hidden = YES;
            [layer removeFromSuperlayer];
        }
    }
    [self.layerArray removeAllObjects];
    
    //画折线 了。。。
    if (self.pointsArray.count > 0) {
        
        NSMutableArray* pointArray = [NSMutableArray array];
        CGFloat minX = self.lj_x;
        CGFloat minY = self.lj_y;
        
        for (NSInteger i = 0; i < self.pointsArray.count; i++) {
            
            CGPoint subPoint = [self.pointsArray[i] CGPointValue];
            //需要吧父视图的坐标点，转化为当前视图左上角为坐标系原点的坐标
            subPoint = CGPointMake(subPoint.x - minX, subPoint.y - minY);
            
            [pointArray addObject:[NSValue valueWithCGPoint:subPoint]];
        }
        [self drawPathWithDataArr:pointArray lineColor:self.lineColor lineWidth:self.lineWidth isDash:NO];
        
        
        
        //画交界点
        [self addPointPathWithArray:pointArray];
        
        //下面的方法，画出来的圆点，会在视图的最底层，而且超出的部分不会显示出来。
//        for (NSInteger i = 0; i < pointArray.count; i++) {
//
//            CGPoint subPoint = [pointArray[i] CGPointValue];
//            CGFloat pointWidth = self.pointWidth;
//            if (i == self.selectedIndex) {
//                pointWidth *= 1.5;
//            }
//            //画交界点
//            {
//                CGRect myOval = {subPoint.x-pointWidth/2.0, subPoint.y-pointWidth/2.0, pointWidth, pointWidth};
//                CGContextSetFillColorWithColor(context, self.pointColor.CGColor);
//                CGContextAddEllipseInRect(context, myOval);
//                CGContextFillPath(context);
//            }
//        }
    }
}

- (void)drawPathWithDataArr:(NSArray *)dataArr lineColor:(UIColor *)lineColor lineWidth:(CGFloat)width isDash:(BOOL)isDash{
    
    UIBezierPath *firstPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 0, 0)];
    
    for (NSInteger i = 0; i<dataArr.count; i++) {
        NSValue *value = dataArr[i];
        CGPoint p = value.CGPointValue;
        if (i==0) {
            [firstPath moveToPoint:p];
        }else{
            [firstPath addLineToPoint:p];
        }
    }
    if (dataArr.count > 0) {
        //首尾相连起来
        [firstPath addLineToPoint:[dataArr[0] CGPointValue]];
    }
    
    if (dataArr.count == 1) {
        NSValue *value = dataArr[0];
        CGPoint p = value.CGPointValue;
        
        [firstPath addLineToPoint:CGPointMake(p.x+1, p.y+1)];
        firstPath.lineCapStyle = kCGLineCapRound;
    }
    
    //第二、UIBezierPath和CAShapeLayer关联
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.bounds;
    shapeLayer.path = firstPath.CGPath;
    if (isDash) {
        shapeLayer.lineDashPattern = @[@(10), @(6)];
    }
    
    shapeLayer.strokeColor = lineColor.CGColor;
    shapeLayer.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.2].CGColor;
    shapeLayer.lineWidth = width;
    
    [self.layer addSublayer:shapeLayer];
    [self.layerArray addObject:shapeLayer];
}

/**  画小圆点 */
-(void)addPointPathWithArray:(NSArray*)pointArray{
    
    CAShapeLayer* roundLayer = [CAShapeLayer layer];
    roundLayer.frame = self.bounds;
    
    CGMutablePathRef mutablePath = CGPathCreateMutable();
    for (NSInteger i = 0; i < pointArray.count; i++) {
        CGFloat pointWidth = self.pointWidth;
        if (i == self.selectedIndex) {
            pointWidth *= 1.5;
        }
        CGPoint subPoint = [pointArray[i] CGPointValue];
        CGRect roundRect = {subPoint.x-pointWidth/2.0, subPoint.y-pointWidth/2.0, pointWidth, pointWidth};
        CGPathAddRoundedRect(mutablePath, nil, roundRect, pointWidth/2.0, pointWidth/2.0);
    }
    
    roundLayer.path = mutablePath;
    roundLayer.fillColor = self.pointColor.CGColor;
    [self.layer addSublayer:roundLayer];
    [self.layerArray addObject:roundLayer];
}

-(CGFloat)getLengthFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint{
    CGFloat length = sqrtf(powf((fromPoint.x-toPoint.x), 2)+powf((fromPoint.y-toPoint.y), 2));
    return length;
}



- (void)deletePoint:(CGPoint)point{
    
    for (NSValue* subValue in self.pointsArray) {
        if (CGPointEqualToPoint(point, [subValue CGPointValue])) {
            
            if (self.selectedIndex == [self.pointsArray indexOfObject:subValue]) {
                
                [self selectedIndexCallBack:-1];
            }
            
            if (self.pointDeletedHandler) {
                self.pointDeletedHandler(point, [self.pointsArray indexOfObject:subValue]);
            }
            
            [self.pointsArray removeObject:subValue];
            [self refreshFrame];
            return;
        }
    }
}


- (void)deletePointWithIndex:(NSInteger)index{
    
    if (self.selectedIndex == index) {
        [self selectedIndexCallBack:-1];
    }
    
    if (self.pointsArray.count > index) {
        
        if (self.pointDeletedHandler) {
            self.pointDeletedHandler([self.pointsArray[index] CGPointValue], index);
        }
        [self.pointsArray removeObjectAtIndex:index];
        [self refreshFrame];
    }
}







@end



