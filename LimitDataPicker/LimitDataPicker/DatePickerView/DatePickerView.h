//
//  DatePickerView.h
//  Friday
//
//  Created by mac-mini-ios on 15/7/23.
//  Copyright (c) 2015年 xtuone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DatePickerView : UIView

@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;/**< 取消按钮*/
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;/**< 完成按钮*/
@property (weak, nonatomic) IBOutlet UIView *actionSheetView;/**< 需要完成动画的图层*/

@property (copy, nonatomic) NSString *datePickerText;/**< 最终选择的日期时间,(这个值,外界可以直接获取到)*/
@property (assign, nonatomic) double endSendNumber;/**< 最终发送的日期时间戳,(这个值,外界可以直接获取到)*/
@property (strong, nonatomic) NSNumber *endSendAmpm;/**< 最终发送的拾取时间区间,0表示不确定,1表示上午,剩下的以此类推,(这个值,外界可以直接获取)*/

@end
