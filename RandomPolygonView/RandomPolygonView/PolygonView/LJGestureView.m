//
//  LJGestureView.m
//  RandomPolygonView
//
//  Created by lijie on 2021/8/3.
//

#import "LJGestureView.h"
#import "UIView+LJ.h"

typedef NS_ENUM(uint8_t, LJGestureDirection) {
    LJGestureDirection_None = 0,
    LJGestureDirection_Top = 1,
    LJGestureDirection_Left,
    LJGestureDirection_Bottom,
    LJGestureDirection_Right,
    
    LJGestureDirection_LeftAndTop,
    LJGestureDirection_LeftAndBottom,
    LJGestureDirection_RightAndTop,
    LJGestureDirection_RightAndBottom,
};


@interface LJGestureView ()


@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *rightView;


@property (weak, nonatomic) IBOutlet UIImageView *leftTopImageView;
@property (weak, nonatomic) IBOutlet UIImageView *leftBottomImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightBottomImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightTopImageView;
@property (weak, nonatomic) IBOutlet UIImageView *moveImageView;

/**  默认12 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftTopWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftBottomWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightTopWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightBottomWidth;

/**  默认4 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightWidth;

@property (weak, nonatomic) IBOutlet UIView *selectZoneBackView;
@property (weak, nonatomic) IBOutlet UIImageView *selectZoneImageView;
@property (weak, nonatomic) IBOutlet UIImageView *selectZoneRightImageview;


@property(nonatomic, assign)CGFloat originWidth;
@property(nonatomic, assign)CGFloat originHeight;

@property(nonatomic, assign)CGFloat originX;
@property(nonatomic, assign)CGFloat originY;

@property(nonatomic, assign)CGPoint originCenter;
@property(nonatomic, assign)CGPoint originTouchPoint;


@property(nonatomic, assign)LJGestureType currentGesture;
@property(nonatomic, assign)LJGestureDirection currentDirection;


/**  手势刚开始 就在父视图里面 */
@property(nonatomic, assign)BOOL inGestureOK;
@property(nonatomic, assign)BOOL customStartGesture;

@end


@implementation LJGestureView

@synthesize gestureDragEdge =_gestureDragEdge;

static CGFloat const kInvalidNum = -10000;

/**  当前视图 最小的长宽 */
static CGFloat const kMinGestureWidth = 21;

/**  拖拽放大缩小， 的默认手势边缘宽度
     当视图的大小 过小时，移动的边缘对应发生改变*/
static CGFloat const kDefaultDragEdge = 30;

-(void)awakeFromNib{
    [super awakeFromNib];
    
    //Xib 会自动调整视图的大小。。。  需要关闭
    self.autoresizingMask = UIViewAutoresizingNone;
    
    self.countLabel.backgroundColor = kRGBColor(220, 220, 220, 1);
    self.countLabel.layer.cornerRadius = 9;
    self.countLabel.layer.masksToBounds = YES;
    self.countLabel.textColor = kTextColor;
    
    [self initData];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self initData];
    }
    return self;
}

- (void)dealloc {
    DLog(@"✅%@ dealloc", NSStringFromClass([self class]));
}

-(void)initData{
    self.gestureDragEdge = kDefaultDragEdge;
    self.showGestureImage = YES;
    self.intoEdit = YES;
    
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor clearColor].CGColor;
    
    
}
-(void)setShowGestureImage:(BOOL)showGestureImage{
    _showGestureImage = showGestureImage;
    [self refreshEditUI];
}
-(void)setIntoEdit:(BOOL)intoEdit{
    _intoEdit = intoEdit;
    [self refreshEditUI];
}

-(void)setGestureType:(LJGestureType)gestureType{
    _gestureType = gestureType;
    [self initGesture];
    [self refreshEditUI];
}

-(void)setGestureDragEdge:(CGFloat)gestureDragEdge{
    if (gestureDragEdge <= 0) {
        _gestureDragEdge = kDefaultDragEdge;
    }else{
        _gestureDragEdge = gestureDragEdge;
    }
}

/**  当视图的大小 过小时，移动的边缘对应发生改变 */
-(CGFloat)gestureDragEdge{
    CGFloat minValue = self.lj_width < self.lj_height?self.lj_width:self.lj_height;
    if (minValue < 30) {
        return minValue/3.0;
    }
    if (minValue < _gestureDragEdge*4) {

        if (minValue/6.0 < 10) {
            return 10;
        }
        return minValue/6.0;
    }
    
    return _gestureDragEdge;
}

-(void)refreshEditUI{
    if (self.showGestureImage && self.intoEdit) {
        self.leftTopImageView.hidden = NO;
        self.leftBottomImageView.hidden = NO;
        self.rightTopImageView.hidden = NO;
        self.rightBottomImageView.hidden = NO;
        
        self.topView.hidden = NO;
        self.leftView.hidden = NO;
        self.bottomView.hidden = NO;
        self.rightView.hidden = NO;
        
        self.moveImageView.hidden = NO;
        
        self.layer.borderColor = [UIColor whiteColor].CGColor;
    }else{
        self.leftTopImageView.hidden = YES;
        self.leftBottomImageView.hidden = YES;
        self.rightTopImageView.hidden = YES;
        self.rightBottomImageView.hidden = YES;
        
        self.topView.hidden = YES;
        self.leftView.hidden = YES;
        self.bottomView.hidden = YES;
        self.rightView.hidden = YES;
        
        self.moveImageView.hidden = YES;
        
        self.layer.borderColor = [UIColor clearColor].CGColor;
    }
    
    self.userInteractionEnabled = self.intoEdit;
}

#pragma mark - ================ Touch 哦 ==================
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!self.intoEdit || touches.count == 0) {
        return;
    }
    //过滤出 有效的Touch
    NSInteger validCount = 0;
    UITouch* tempTouch = nil;
    for (UITouch* obj in event.allTouches.allObjects) {
        if (obj.view == self) {
            if (!tempTouch) {
                tempTouch = obj;
            }
            validCount ++;
        }else if (!obj.view){
            //这个 View 如果是先后Touch了，第一个Touch的view 就是nil
            CGPoint begingPoint = [obj locationInView:self];
            if (CGRectContainsPoint(self.bounds, begingPoint)) {
                validCount ++;
            }
        }
    }
    if (validCount == 0 || validCount > 2) {
        return;
    }
    
    DLog(@"开始Touch🌶");
    if ((self.gestureType & LJGestureType_TwoFingleScale) > 0 && validCount == 2){
        //双指缩放
        self.currentGesture = LJGestureType_TwoFingleScale;
        [self beginGesture];
        return;
    }
    
    if (((self.gestureType & LJGestureType_OneFingleDragScale) > 0 || (self.gestureType & LJGestureType_OneFingleDragMove) > 0)){
        //单指拖拽缩放，或者单指移动
        {
            self.originWidth = self.lj_width;
            self.originHeight = self.lj_height;
            self.originX = self.lj_x;
            self.originY = self.lj_y;
            self.originCenter = self.center;
            
            
            CGPoint begingPoint = [tempTouch locationInView:self];
            self.originTouchPoint = [tempTouch locationInView:self.superview];
            DLog(@"自身开始点%.1f, %.1f", begingPoint.x, begingPoint.y);
            DLog(@"父视图开始点%.1f, %.1f", self.originTouchPoint.x, self.originTouchPoint.y);
            
            if ((self.gestureType & LJGestureType_OneFingleDragScale) > 0) {
                if (begingPoint.y < self.gestureDragEdge && (begingPoint.y < self.lj_height/2.0)) {
                    //上
                    self.currentGesture = LJGestureType_OneFingleDragScale;
                    if (begingPoint.x < self.gestureDragEdge && (begingPoint.x < self.lj_width/2.0)) {
                        //左上角
                        self.currentDirection = LJGestureDirection_LeftAndTop;
                    }else if (begingPoint.x > self.lj_width-self.gestureDragEdge){
                        //右上角
                        self.currentDirection = LJGestureDirection_RightAndTop;
                    }else{
                        //上
                        self.currentDirection = LJGestureDirection_Top;
                    }
                }else if (begingPoint.x < self.gestureDragEdge && (begingPoint.x < self.lj_width/2.0)){
                    //左
                    self.currentGesture = LJGestureType_OneFingleDragScale;
                    if (begingPoint.y < self.gestureDragEdge && (begingPoint.y < self.lj_height/2.0)) {
                        //左上角
                        self.currentDirection = LJGestureDirection_LeftAndTop;
                    }else if (begingPoint.y > self.lj_height-self.gestureDragEdge){
                        //左下角
                        self.currentDirection = LJGestureDirection_LeftAndBottom;
                    }else{
                        //左
                        self.currentDirection = LJGestureDirection_Left;
                    }
                }else if (begingPoint.y > self.lj_height-self.gestureDragEdge){
                    //下
                    self.currentGesture = LJGestureType_OneFingleDragScale;
                    if (begingPoint.x < self.gestureDragEdge && (begingPoint.x < self.lj_width/2.0)) {
                        //左下角
                        self.currentDirection = LJGestureDirection_LeftAndBottom;
                    }else if (begingPoint.x > self.lj_width-self.gestureDragEdge){
                        //右下角
                        self.currentDirection = LJGestureDirection_RightAndBottom;
                    }else{
                        //下
                        self.currentDirection = LJGestureDirection_Bottom;
                    }
                }else if (begingPoint.x > self.lj_width-self.gestureDragEdge){
                    //右
                    self.currentGesture = LJGestureType_OneFingleDragScale;
                    if (begingPoint.y < self.gestureDragEdge && (begingPoint.y < self.lj_height/2.0)) {
                        //右上角
                        self.currentDirection = LJGestureDirection_RightAndTop;
                    }else if (begingPoint.y > self.lj_height-self.gestureDragEdge){
                        //右下角
                        self.currentDirection = LJGestureDirection_RightAndBottom;
                    }else{
                        //右
                        self.currentDirection = LJGestureDirection_Right;
                    }
                }else{
                    //不在拖拽放大的区域中
                    self.currentGesture = LJGestureType_None;
                }
            }
                
            if((self.gestureType & LJGestureType_OneFingleDragMove) > 0 &&
               self.currentGesture == LJGestureType_None){
                //移动
                self.currentGesture = LJGestureType_OneFingleDragMove;
            }
            [self beginGesture];
            
        }
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!self.intoEdit) {
        return;
    }
    DLog(@"结束Touch👌");
    //表示手势 没有被用到，需要手动结束手势
    if ((self.gestureType & LJGestureType_TwoFingleScale) > 0 ||
        ((self.gestureType & LJGestureType_OneFingleDragScale) > 0 || (self.gestureType & LJGestureType_OneFingleDragMove) > 0)){
        [self endGesture];
    }
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //取消 表示手势被使用了，可以不用管了
    DLog(@"取消Touch👌");
    if (self.intoEdit &&
        !self.customStartGesture &&
        ((self.gestureType & LJGestureType_TwoFingleScale) > 0 ||
         ((self.gestureType & LJGestureType_OneFingleDragScale) > 0 || (self.gestureType & LJGestureType_OneFingleDragMove) > 0))
        ){
        
        [self endGesture];
    }
}


#pragma mark - ================ 手势哦 ==================
-(void)initGesture{
    
    for (UIGestureRecognizer* gesture in self.gestureRecognizers) {
        if ((self.gestureType & LJGestureType_TwoFingleScale) > 0 &&
            [gesture isKindOfClass:[UIPinchGestureRecognizer class]]) {
            [self removeGestureRecognizer:gesture];
        }
        if (((self.gestureType & LJGestureType_OneFingleDragScale) > 0 || (self.gestureType & LJGestureType_OneFingleDragMove) > 0) &&
            [gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
            [self removeGestureRecognizer:gesture];
        }
    }
    
    @weakify(self);
    if ((self.gestureType & LJGestureType_TwoFingleScale) > 0){
        //双指缩放
        [self addPinchGestureHandler:^(UIPinchGestureRecognizer *pinchGesture, UIView *itself) {
            @strongify(self);
            if (!self.intoEdit) {
                return;
            }
            
            if([pinchGesture state] == UIGestureRecognizerStateBegan) {
                self.currentGesture = LJGestureType_TwoFingleScale;
                self.customStartGesture = YES;
                [self beginGesture];
                
                self.originWidth = self.lj_width;
                self.originHeight = self.lj_height;
                self.originCenter = self.center;
                return;
            }else if (pinchGesture.state == UIGestureRecognizerStateEnded ||
                      pinchGesture.state == UIGestureRecognizerStateCancelled ||
                      pinchGesture.state == UIGestureRecognizerStateFailed){
                self.customStartGesture = NO;
                [self endGesture];
            }
            
            [self scaleView:pinchGesture.scale];
        }];
    }
    if (((self.gestureType & LJGestureType_OneFingleDragScale) > 0 || (self.gestureType & LJGestureType_OneFingleDragMove) > 0)){
        //单指拖拽缩放，或者单指移动
        [self addPanGestureHandler:^(UIPanGestureRecognizer *panGesture, UIView *itself) {
            @strongify(self);
            if (!self.intoEdit) {
                return;
            }
            
            if (panGesture.state == UIGestureRecognizerStateBegan) {
                self.originWidth = self.lj_width;
                self.originHeight = self.lj_height;
                self.originX = self.lj_x;
                self.originY = self.lj_y;
                self.originCenter = self.center;
                
                
                CGPoint begingPoint = [panGesture locationInView:self];
                self.originTouchPoint = [panGesture locationInView:self.superview];
                DLog(@"自身开始点%.1f, %.1f", begingPoint.x, begingPoint.y);
                DLog(@"父视图开始点%.1f, %.1f", self.originTouchPoint.x, self.originTouchPoint.y);
                
                if (self.currentGesture > LJGestureType_TwoFingleScale) {
                    //已经确定了 方向，或者移动了
                    self.customStartGesture = YES;
                    [self beginGesture];
                    return;
                }
                
                
                if ((self.gestureType & LJGestureType_OneFingleDragScale) > 0) {
                    if (begingPoint.y < self.gestureDragEdge && (begingPoint.y < self.lj_height/2.0)) {
                        //上
                        self.currentGesture = LJGestureType_OneFingleDragScale;
                        if (begingPoint.x < self.gestureDragEdge && (begingPoint.x < self.lj_width/2.0)) {
                            //左上角
                            self.currentDirection = LJGestureDirection_LeftAndTop;
                        }else if (begingPoint.x > self.lj_width-self.gestureDragEdge){
                            //右上角
                            self.currentDirection = LJGestureDirection_RightAndTop;
                        }else{
                            //上
                            self.currentDirection = LJGestureDirection_Top;
                        }
                    }else if (begingPoint.x < self.gestureDragEdge && (begingPoint.x < self.lj_width/2.0)){
                        //左
                        self.currentGesture = LJGestureType_OneFingleDragScale;
                        if (begingPoint.y < self.gestureDragEdge && (begingPoint.y < self.lj_height/2.0)) {
                            //左上角
                            self.currentDirection = LJGestureDirection_LeftAndTop;
                        }else if (begingPoint.y > self.lj_height-self.gestureDragEdge){
                            //左下角
                            self.currentDirection = LJGestureDirection_LeftAndBottom;
                        }else{
                            //左
                            self.currentDirection = LJGestureDirection_Left;
                        }
                    }else if (begingPoint.y > self.lj_height-self.gestureDragEdge){
                        //下
                        self.currentGesture = LJGestureType_OneFingleDragScale;
                        if (begingPoint.x < self.gestureDragEdge && (begingPoint.x < self.lj_width/2.0)) {
                            //左下角
                            self.currentDirection = LJGestureDirection_LeftAndBottom;
                        }else if (begingPoint.x > self.lj_width-self.gestureDragEdge){
                            //右下角
                            self.currentDirection = LJGestureDirection_RightAndBottom;
                        }else{
                            //下
                            self.currentDirection = LJGestureDirection_Bottom;
                        }
                    }else if (begingPoint.x > self.lj_width-self.gestureDragEdge){
                        //右
                        self.currentGesture = LJGestureType_OneFingleDragScale;
                        if (begingPoint.y < self.gestureDragEdge && (begingPoint.y < self.lj_height/2.0)) {
                            //右上角
                            self.currentDirection = LJGestureDirection_RightAndTop;
                        }else if (begingPoint.y > self.lj_height-self.gestureDragEdge){
                            //右下角
                            self.currentDirection = LJGestureDirection_RightAndBottom;
                        }else{
                            //右
                            self.currentDirection = LJGestureDirection_Right;
                        }
                    }else{
                        //不在拖拽放大的区域中
                        self.currentGesture = LJGestureType_None;
                    }
                }
                    
                if((self.gestureType & LJGestureType_OneFingleDragMove) > 0 &&
                   self.currentGesture == LJGestureType_None){
                    //移动
                    self.currentGesture = LJGestureType_OneFingleDragMove;
                    
                    CGPoint translation = [panGesture translationInView:self.superview];
                    [self setCenter:(CGPoint){self.center.x + translation.x, self.center.y + translation.y}];
                    [panGesture setTranslation:CGPointZero inView:self.superview];
                }
                self.customStartGesture = YES;
                [self beginGesture];
                
            }else if (panGesture.state == UIGestureRecognizerStateChanged) {
                if (self.currentGesture == LJGestureType_OneFingleDragScale) {
//                    DLog(@"改变大小===父视图移动点%.1f, %.1f", [panGesture locationInView:self.superview].x, [panGesture locationInView:self.superview].y);
                    //拖拽放大 到移动的点
                    [self changeScaleToPoint:[panGesture locationInView:self.superview]];
                }else if (self.currentGesture == LJGestureType_OneFingleDragMove){
                    //移动
                    CGPoint translation = [panGesture translationInView:self.superview];
//                    DLog(@"移动中......%.1f, %.1f", translation.x, translation.y);
                    
//                    [self setCenter:(CGPoint){self.center.x + translation.x, self.center.y + translation.y}];
                    [self changeWidth:kInvalidNum height:kInvalidNum x:self.lj_x+translation.x y:self.lj_y+translation.y needIntersection:NO];
                    
                    [panGesture setTranslation:CGPointZero inView:self.superview];
                }
            }else if (panGesture.state == UIGestureRecognizerStateEnded ||
                      panGesture.state == UIGestureRecognizerStateCancelled ||
                      panGesture.state == UIGestureRecognizerStateFailed){
                self.customStartGesture = NO;
                [self endGesture];
            }
        }];
    }
}

-(void)beginGesture{
    DLog(@"开始 手势🤚");
    [self.superview bringSubviewToFront:self];
    
    CGAffineTransform newTransformBorder = CGAffineTransformScale(CGAffineTransformIdentity, 2, 2);
    CGFloat bigWidth = 20;
    CGFloat bigBorderWidth = 8;
    
    if (self.currentGesture == LJGestureType_TwoFingleScale) {
        self.leftTopWidth.constant = bigWidth;
        self.leftBottomWidth.constant = bigWidth;
        self.rightTopWidth.constant = bigWidth;
        self.rightBottomWidth.constant = bigWidth;
        
        
        //其余的恢复原样
        self.moveImageView.transform = CGAffineTransformIdentity;
        CGFloat bigBorderWidth = 4;
        self.topWidth.constant = bigBorderWidth;
        self.leftWidth.constant = bigBorderWidth;
        self.bottomWidth.constant = bigBorderWidth;
        self.rightWidth.constant = bigBorderWidth;
        
    }else if (self.currentGesture == LJGestureType_OneFingleDragMove){
        self.moveImageView.transform = newTransformBorder;
    }else if (self.currentGesture == LJGestureType_OneFingleDragScale){
        switch (self.currentDirection) {
            case LJGestureDirection_None: {
                break;
            }
            case LJGestureDirection_Top:{
                self.topWidth.constant = bigBorderWidth;
                break;
            }
            case LJGestureDirection_Left: {
                self.leftWidth.constant = bigBorderWidth;
                break;
            }
            case LJGestureDirection_Bottom: {
                self.bottomWidth.constant = bigBorderWidth;
                break;
            }
            case LJGestureDirection_Right: {
                self.rightWidth.constant = bigBorderWidth;
                break;
            }
                
            case LJGestureDirection_LeftAndTop: {
                self.leftTopWidth.constant = bigWidth;
                break;
            }
            case LJGestureDirection_LeftAndBottom: {
                self.leftBottomWidth.constant = bigWidth;
                break;
            }
            case LJGestureDirection_RightAndTop: {
                self.rightTopWidth.constant = bigWidth;
                break;
            }
            case LJGestureDirection_RightAndBottom: {
                self.rightBottomWidth.constant = bigWidth;
                break;
            }
        }
    }
}

-(void)endGesture{
    DLog(@"结束 手势🤚");
    self.currentGesture = 0;
    self.inGestureOK = NO;
//    self.topView.transform = CGAffineTransformIdentity;
//    self.leftView.transform = CGAffineTransformIdentity;
//    self.bottomView.transform = CGAffineTransformIdentity;
//    self.rightView.transform = CGAffineTransformIdentity;
    
    self.moveImageView.transform = CGAffineTransformIdentity;
    
    CGFloat bigWidth = 12;
    self.leftTopWidth.constant = bigWidth;
    self.leftBottomWidth.constant = bigWidth;
    self.rightTopWidth.constant = bigWidth;
    self.rightBottomWidth.constant = bigWidth;
    
    CGFloat bigBorderWidth = 4;
    self.topWidth.constant = bigBorderWidth;
    self.leftWidth.constant = bigBorderWidth;
    self.bottomWidth.constant = bigBorderWidth;
    self.rightWidth.constant = bigBorderWidth;
    
    
    if (self.frameRoom) {
        [self saveRoomSize];
    }
}

-(void)scaleView:(CGFloat)scale{
//    DLog(@"缩放大小:%.2f", scale);
    if (scale > 1) {
        scale = log10(scale) + 1;
    }
    
    if (scale < 1) {
        scale = 1- log10(2-scale);
    }
    
    CGFloat tempWidth = kInvalidNum;
    CGFloat tempHeigth = kInvalidNum;
    
//    DLog(@"实际缩放大小:%.4f", scale);
    tempWidth = self.originWidth*scale;
    tempHeigth = self.originHeight*scale;
    [self changeWidth:tempWidth height:tempHeigth x:kInvalidNum y:kInvalidNum needIntersection:NO];
    
    CGRect tempFrame = self.frame;
    self.center = self.originCenter;
    BOOL isContains = CGRectContainsRect(self.superview.bounds, self.frame);
    if (!isContains) {
        self.frame = tempFrame;
    }
}

/**  拖拽放大 到移动的点 */
-(void)changeScaleToPoint:(CGPoint)point{
    CGFloat tempWidth = kInvalidNum;
    CGFloat tempHeigth = kInvalidNum;
    CGFloat tempX = kInvalidNum;
    CGFloat tempY = kInvalidNum;
    
    switch (self.currentDirection) {
        case LJGestureDirection_None: {
            break;
        }
        case LJGestureDirection_Top:{
//            DLog(@"放大：%.2f", (point.y - self.originTouchPoint.y));
            tempY = self.originY+(point.y - self.originTouchPoint.y);
            tempHeigth = self.originHeight - (point.y - self.originTouchPoint.y);
            break;
        }
        case LJGestureDirection_Left: {
            tempX = self.originX+(point.x - self.originTouchPoint.x);
            tempWidth = self.originWidth - (point.x - self.originTouchPoint.x);
            break;
        }
        case LJGestureDirection_Bottom: {
            tempHeigth = self.originHeight + (point.y - self.originTouchPoint.y);
            break;
        }
        case LJGestureDirection_Right: {
            tempWidth = self.originWidth + (point.x - self.originTouchPoint.x);
            break;
        }
            
            
        case LJGestureDirection_LeftAndTop: {
            
            tempX = self.originX+(point.x - self.originTouchPoint.x);
            tempWidth = self.originWidth - (point.x - self.originTouchPoint.x);
            
            tempY = self.originY+(point.y - self.originTouchPoint.y);
            tempHeigth = self.originHeight - (point.y - self.originTouchPoint.y);
            break;
        }
        case LJGestureDirection_LeftAndBottom: {
            
            tempX = self.originX+(point.x - self.originTouchPoint.x);
            tempWidth = self.originWidth - (point.x - self.originTouchPoint.x);
            
            tempHeigth = self.originHeight + (point.y - self.originTouchPoint.y);
            break;
        }
        case LJGestureDirection_RightAndTop: {
            
            tempWidth = self.originWidth + (point.x - self.originTouchPoint.x);
            
            tempY = self.originY+(point.y - self.originTouchPoint.y);
            tempHeigth = self.originHeight - (point.y - self.originTouchPoint.y);
            break;
        }
        case LJGestureDirection_RightAndBottom: {
            
            tempWidth = self.originWidth + (point.x - self.originTouchPoint.x);
            
            tempHeigth = self.originHeight + (point.y - self.originTouchPoint.y);
            break;
        }
    }
    [self changeWidth:tempWidth height:tempHeigth x:tempX y:tempY needIntersection:YES];
}

-(void)changeWidth:(CGFloat)width height:(CGFloat)height x:(CGFloat)x y:(CGFloat)y needIntersection:(BOOL)needIntersection{
    CGRect bigFrame = self.superview.bounds;
    CGRect tempFrame = self.frame;
    
    if (width != kInvalidNum) {
        tempFrame.size.width = width;
    }
    if (height != kInvalidNum) {
        tempFrame.size.height = height;
    }
    if (x != kInvalidNum) {
        tempFrame.origin.x = x;
    }
    if (y != kInvalidNum) {
        tempFrame.origin.y = y;
    }
    
    if (tempFrame.size.width < kMinGestureWidth) {
        tempFrame.size.width = self.lj_width;
        tempFrame.origin.x = self.lj_x;
    }
    if (tempFrame.size.height < kMinGestureWidth) {
        tempFrame.size.height = self.lj_height;
        tempFrame.origin.y = self.lj_y;
    }
    
    
    BOOL isContains = CGRectContainsRect(bigFrame, tempFrame);
    if (isContains) {
        self.inGestureOK = YES;
        self.frame = tempFrame;
    }else if (needIntersection){
        self.inGestureOK = YES;
        CGRect intersectionFrame = CGRectIntersection(bigFrame, tempFrame);
        self.frame = intersectionFrame;
    }else{
        
        //如果 不在父视图内部
        if (!self.inGestureOK) {
            //手势刚开始的是 就在父视图外面
            CGRect unionFrame = CGRectUnion(bigFrame, self.frame);
            if (!CGRectEqualToRect(unionFrame, bigFrame)) {
                
                if (self.lj_x < 0) {
                    self.lj_x = 0;
                }
                if (self.lj_y < 0) {
                    self.lj_y = 0;
                }
                if (self.lj_maxX > self.superview.lj_width) {
                    self.lj_maxX = self.superview.lj_width;
                }
                if (self.lj_maxY > self.superview.lj_height) {
                    self.lj_maxY = self.superview.lj_height;
                }
            }
        }else{
            if (self.currentGesture == LJGestureType_OneFingleDragMove) {
                //在移动到边缘的时候 可以只移动一个方向   这样移动更顺滑
                CGRect tempFrameX = CGRectMake(tempFrame.origin.x, tempFrame.origin.y, tempFrame.size.width, tempFrame.size.height);
                
                tempFrameX.origin.x = self.lj_x;
                isContains = CGRectContainsRect(bigFrame, tempFrameX);
                if (isContains) {
                    self.inGestureOK = YES;
                    self.frame = tempFrameX;
                }else{
                    tempFrame.origin.y = self.lj_y;
                    isContains = CGRectContainsRect(bigFrame, tempFrame);
                    if (isContains) {
                        self.inGestureOK = YES;
                        self.frame = tempFrame;
                    }
                }
            }
        }
    }
    
    if (self.countLabel) {
        self.countLabel.layer.cornerRadius = self.countLabel.lj_width/2.0;
    }
}



#pragma mark - ================ 设置房间专用==================
-(void)setScaleSize:(CGFloat)scaleSize{
//    _scaleSize = scaleSize;
//
//    if (self.frameRoom) {
//        CGRect tempframe = CGRectMake(self.frameRoom.positionX*scaleSize,
//                                      self.frameRoom.positionY*scaleSize,
//                                      self.frameRoom.pdWidth*scaleSize,
//                                      self.frameRoom.pdHeight*scaleSize);
//
//        BOOL hasChange = NO;
//        if (tempframe.size.width > self.superview.lj_width || tempframe.size.height > self.superview.lj_height) {
//            hasChange = YES;
//            CGFloat tempScale = tempframe.size.width/self.superview.lj_width;
//            CGFloat tempScale2 = tempframe.size.height/self.superview.lj_height;
//
//            tempScale = (tempScale>tempScale2?tempScale:tempScale2) * 3.0;
//
//            tempframe = CGRectMake(tempframe.origin.x/tempScale,
//                                   tempframe.origin.y/tempScale,
//                                   tempframe.size.width/tempScale,
//                                   tempframe.size.height/tempScale
//                                   );
//        }
//
//        self.frame = tempframe;
//
//        if (self.lj_x < 0) {
//            self.lj_x = 0;
//            hasChange = YES;
//        }
//        if (self.lj_y < 0) {
//            self.lj_y = 0;
//            hasChange = YES;
//        }
//        if (self.lj_maxX > self.superview.lj_width) {
//            self.lj_maxX = self.superview.lj_width;
//            hasChange = YES;
//        }
//        if (self.lj_maxY > self.superview.lj_height) {
//            self.lj_maxY = self.superview.lj_height;
//            hasChange = YES;
//        }
//        if (self.countLabel) {
//            self.countLabel.layer.cornerRadius = self.countLabel.lj_width/2.0;
//        }
//    }
}

-(void)saveRoomSize{
//    if (self.countLabel) {
//        self.countLabel.layer.cornerRadius = self.countLabel.lj_width/2.0;
//    }
//    self.frameRoom.positionX = self.lj_x/self.scaleSize;
//    self.frameRoom.positionY = self.lj_y/self.scaleSize;
//    self.frameRoom.pdWidth = self.lj_width/self.scaleSize;
//    self.frameRoom.pdHeight = self.lj_height/self.scaleSize;
//    [kDataManager savePublishToHistoryOperation:self.frameRoom];
}


-(void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:backgroundColor];
    
    if (self.selectZoneBackView && !self.selectZoneBackView.hidden) {
        [self refreshSelectColor];
    }
}

/**  高亮显示 已经选中的区域， 只在右边区域详情展开时候有效 */
-(void)showSelectImage:(BOOL)show{
    if (show && self.frameRoom) {
        self.selectZoneBackView.hidden = NO;
        [self refreshSelectColor];
    }else{
        self.selectZoneBackView.hidden = YES;
    }
}

-(void)refreshSelectColor{
//    self.selectZoneImageView.tintColor = [kDataManager getReverseColorWithColorStr:self.frameRoom.bgColor];
    self.selectZoneRightImageview.tintColor = [self.backgroundColor colorWithAlphaComponent:1];
}

@end
