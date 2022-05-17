//
//  LJGestureView.h
//  RandomPolygonView
//
//  Created by lijie on 2021/8/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(uint8_t, LJGestureType) {
    LJGestureType_None = 0,
    /**  双指缩放 */
    LJGestureType_TwoFingleScale = 1,
    /**  单指拖拽缩放 */
    LJGestureType_OneFingleDragScale = 1<<1,
    /**  单指移动 */
    LJGestureType_OneFingleDragMove = 1<<2,
};


/**  手势视图， 可放大，拖拽 */
@interface LJGestureView : UIView

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
/**  个数 */
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property(nonatomic, assign)LJGestureType gestureType;

/**  单指拖拽缩放 的时候的有效边缘  默认35*/
@property(nonatomic, assign)CGFloat gestureDragEdge;

/**  是否显示 四个角 四个边 和中间移动  的图标   默认显示*/
@property(nonatomic, assign)BOOL showGestureImage;

/**  是否可以编辑  默认可以YES*/
@property(nonatomic, assign)BOOL intoEdit;





#pragma mark - ================ 区域专用  控制刷新 位置大小 ==================
@property(nonatomic, strong)id frameRoom;
/**  缩放比例  左上角位置 和 宽高 */
@property(nonatomic, assign)CGFloat scaleSize;

/**  高亮显示 已经选中的区域， 只在右边区域详情展开时候有效 */
-(void)showSelectImage:(BOOL)show;


@end

NS_ASSUME_NONNULL_END
