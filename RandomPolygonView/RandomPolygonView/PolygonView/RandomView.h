//
//  RandomView.h
//  RandomPolygonView
//
//  Created by lijie on 2022/5/16.
//

#import <UIKit/UIKit.h>
#import "LJGestureView.h"

NS_ASSUME_NONNULL_BEGIN

@interface RandomView : UIView

/**  各个点 在父视图上面的位置  CGPoint */
@property(nonatomic, strong)NSMutableArray* pointsArray;

@property(nonatomic, strong)UIColor* lineColor;
@property(nonatomic, strong)UIColor* pointColor;
@property(nonatomic, strong)UIColor* fillColor;

/**  默认 2 */
@property(assign, nonatomic)CGFloat lineWidth;
/**  默认6 */
@property(assign, nonatomic)CGFloat pointWidth;
/**  默认12 */
@property(assign, nonatomic)CGFloat selectPointWidth;


/**  手势可以识别的 半径，默认 50 */
@property(assign, nonatomic)CGFloat gestureWidth;

/**  默认YES 自动优化， 相同斜率上面的点 不会作为锚点固定位置 */
@property(assign, nonatomic)BOOL autoOptimize;

/**  默认NO， 双击点，删除点 */
@property(assign, nonatomic)BOOL doubleClickToRemovePoint;

/**  默认YES 根据手势范围，增加一个边缘。  gestureWidth的一半*/
@property(assign, nonatomic)BOOL addGestureEdge;


@property(nonatomic, strong)void(^pointSelectedHandler)(CGPoint point, NSInteger index);
@property(nonatomic, strong)void(^pointDeletedHandler)(CGPoint point, NSInteger index);
@property(nonatomic, strong)void(^pointChangeHandler)(CGPoint point, NSInteger index);




#pragma mark - ================ 区域用到 ==================
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
/**  个数 */
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property(nonatomic, assign)LJGestureType gestureType;

/**  是否可以编辑  默认可以YES*/
@property(nonatomic, assign)BOOL intoEdit;



#pragma mark - ================ 区域专用  控制刷新 位置大小 ==================
@property(nonatomic, strong)id frameRoom;
/**  缩放比例  左上角位置 和 宽高 */
@property(nonatomic, assign)CGFloat scaleSize;

/**  高亮显示 已经选中的区域， 只在右边区域详情展开时候有效 */
-(void)showSelectImage:(BOOL)show;




#pragma mark - ================ 初始化 ==================
/**  需要第一次  设置完Frame初始化一次，同时会给 pointsArray 初始化赋值*/
-(void)initData;

-(void)deletePoint:(CGPoint)point;
-(void)deletePointWithIndex:(NSInteger)index;





@end

NS_ASSUME_NONNULL_END
