//
//  UIView+LJ.h
//  LJTrack
//
//  Created by LiJie on 16/6/17.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LJTapBlock)(UITapGestureRecognizer* tapGesture, UIView* itself);
typedef void(^LJPanBlock)(UIPanGestureRecognizer* panGesture, UIView* itself);
typedef void(^LJLongBlock)(UILongPressGestureRecognizer* longGesture, UIView* itself);
typedef void(^LJPinchBlock)(UIPinchGestureRecognizer* pinchGesture, UIView* itself);



#define kRGBColor(r, g, b, a)   [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define DLog( s, ... ) NSLog( @"<%@: (%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#define kTextColor              kRGBColor(15, 15, 15, 1.0)//淡黑色



/**  Weakify  Strongify */
#ifndef weakify
#if DEBUG       //===========
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else           //===========
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif          //===========
#endif


#ifndef strongify
#if DEBUG       //+++++++++++
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else           //+++++++++++
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif          //+++++++++++
#endif





@interface UIView (LJ)


@property (nonatomic, assign)CGFloat lj_height;
@property (nonatomic, assign)CGFloat lj_width;
@property (nonatomic, assign)CGFloat lj_y;
@property (nonatomic, assign)CGFloat lj_x;

@property(nonatomic, assign) CGPoint lj_origin;
@property(nonatomic, assign) CGSize  lj_size;

@property(nonatomic, assign)CGFloat  lj_maxX;
@property(nonatomic, assign)CGFloat  lj_maxY;

@property(nonatomic, assign)CGFloat  lj_centerX;
@property(nonatomic, assign)CGFloat  lj_centerY;



/**  添加一个点击事件 */
-(void)addTapGestureHandler:(LJTapBlock)handler;

/**  添加一个双击事件 */
-(void)addMultipleTap:(NSInteger)numTap gestureHandler:(LJTapBlock)handler;

/**  添加一个滑动,拖拽，事件 */
-(void)addPanGestureHandler:(LJPanBlock)handler;

/**  添加一个长按事件 */
-(void)addLongGestureTime:(CGFloat)time Handler:(LJLongBlock)handler;


/**  添加一个 双指放大缩小 手势 */
-(void)addPinchGestureHandler:(LJPinchBlock)handler;


/**  设置成系统的 圆角 阴影 绿色背景的样式 */
-(void)setSystemStyle;

/**  设置成系统的 圆角 灰色边线 */
-(void)setborderLineStyle;
/**  设置阴影 */
-(void)addShadowColor:(UIColor*)color;
/**  设置圆角 */
-(void)setLayerCornerRadius:(CGFloat )Radius;
@end
