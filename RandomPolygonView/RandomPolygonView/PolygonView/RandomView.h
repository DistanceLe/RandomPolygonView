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





@property(nonatomic, strong)void(^valueChangeHandler)(id changeValue, id changeValue2, NSInteger index);


-(void)initData;



@end

NS_ASSUME_NONNULL_END
