
/*
    微信样式的 ActionSheet
 */

#import <UIKit/UIKit.h>

@class VHLActionSheet;

@protocol VHLActionSheetDelegate <NSObject>

@optional

typedef void(^SelectedButtonIndexBlock)(NSInteger index);

/**
 *  点击按钮
 */
- (void)actionSheet:(VHLActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface VHLActionSheet : UIView

/**
 *  代理
 */
@property (nonatomic, weak) id <VHLActionSheetDelegate> delegate;
/**
 *  实例化一个ActionSheet
 *
 *  @param title            标题
 *  @param delegate         委托
 *  @param cancelTitle      取消按钮
 *  @param destructiveTitle 高亮按钮
 *  @param otherTitles      其他按钮,s
 */
- (instancetype)initWithTitle:(NSString *)title
                     delegate:(id<VHLActionSheetDelegate>)delegate
                  cancelTitle:(NSString *)cancelTitle
       destructiveButtonTitle:(NSString *)destructiveTitle
                  otherTitles:(NSString *)otherTitles,... NS_REQUIRES_NIL_TERMINATION;
/**
 *  显示
 */
- (void)show;
/**
 *  按钮回调
 */
- (void)buttonIndex:(SelectedButtonIndexBlock)sBlock;

@end
