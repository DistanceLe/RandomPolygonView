//
//  RandomView.h
//  RandomPolygonView
//
//  Created by lijie on 2022/5/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RandomView : UIView


@property(nonatomic, strong)UIColor* lineColor;
@property(nonatomic, strong)UIColor* pointColor;

/**  默认 2 */
@property(assign, nonatomic)CGFloat lineWidth;
/**  默认6 */
@property(assign, nonatomic)CGFloat pointWidth;


/**  手势可以识别的 半径，默认 50 */
@property(assign, nonatomic)CGFloat gestureWidth;

/**  默认YES 自动优化， 相同斜率上面的点 不会作为锚点固定位置 */
@property(assign, nonatomic)BOOL autoOptimize;

/**  默认NO， 双击点，删除点 */
@property(assign, nonatomic)BOOL doubleClickToRemovePoint;





@property(nonatomic, strong)void(^pointSelectedHandler)(CGPoint point, NSInteger index);
@property(nonatomic, strong)void(^pointDeletedHandler)(CGPoint point, NSInteger index);
@property(nonatomic, strong)void(^pointChangeHandler)(CGPoint point, NSInteger index);

/**  需要第一次  设置完Frame初始化一次 */
-(void)initData;

-(void)deletePoint:(CGPoint)point;
-(void)deletePointWithIndex:(NSInteger)index;





@end

NS_ASSUME_NONNULL_END
