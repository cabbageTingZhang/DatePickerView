//
//  ViewController.m
//  LimitDataPicker
//
//  Created by mac-mini-ios on 15/12/25.
//  Copyright © 2015年 mac-mini-ios. All rights reserved.
//
#define WEAKSELF __weak __typeof(&*self)weakSelf = self;

#import "ViewController.h"
#import "DatePickerView.h"

@interface ViewController ()
{
    DatePickerView *_datePickerView;///<时间选择器
}
@property (weak, nonatomic) IBOutlet UITextField *txt_date;///<日期显示textfield
@property (weak, nonatomic) IBOutlet UIButton *btn;///<点击选择日期按钮

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.btn.layer.cornerRadius = 5.0;
    self.btn.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
//点击选择时间按钮触发事件
- (IBAction)chooseDateBtnClick:(id)sender
{
    [self.view endEditing:YES];
    _datePickerView = [[NSBundle mainBundle] loadNibNamed:@"DatePickerView" owner:nil options:nil][0];
    UITapGestureRecognizer *gestrue = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(CancelChoose)];//给view视图添加一个点击手势
    [_datePickerView addGestureRecognizer:gestrue];
    [_datePickerView.cancelBtn addTarget:self action:@selector(CancelChoose) forControlEvents:UIControlEventTouchUpInside];
    [_datePickerView.doneBtn addTarget:self action:@selector(DoneChoose) forControlEvents:UIControlEventTouchUpInside];
    _datePickerView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    //完成上移动画
    CGRect actionSheetViewRect = _datePickerView.actionSheetView.frame;
    actionSheetViewRect.origin.y = self.view.frame.size.height;
    _datePickerView.actionSheetView.frame = actionSheetViewRect;
    WEAKSELF
    [UIView animateWithDuration:0.3 animations:^{
        CGRect actionSheetViewRect = _datePickerView.actionSheetView.frame;
        actionSheetViewRect.origin.y = weakSelf.view.frame.size.height - 206;
        _datePickerView.actionSheetView.frame = actionSheetViewRect;
    }];
    [self.view addSubview:_datePickerView];
}

//点击DatePicker取消按钮触发的事件
- (void)CancelChoose
{
    [self CancelAction];
}
//点击DatePicker完成按钮触发的事件
- (void)DoneChoose
{
    self.txt_date.text = _datePickerView.datePickerText;
    NSLog(@"最终获取到的时间戳(这个时间戳和安卓的一样是13位的,具体可看datePickerView属性解释)--%f",_datePickerView.endSendNumber);
    NSLog(@"最终获取到的时间区间--%@",_datePickerView.endSendAmpm);
    [self CancelAction];
}

//取消DatePicker选择动作
- (void)CancelAction
{
    //完成下移动画
    WEAKSELF
    [UIView animateWithDuration:0.3 animations:^
     {
         CGRect actionSheetViewRect = _datePickerView.actionSheetView.frame;
         actionSheetViewRect.origin.y = weakSelf.view.frame.size.height;
         _datePickerView.actionSheetView.frame = actionSheetViewRect;
     } completion:^(BOOL finished)
     {
         [_datePickerView removeFromSuperview];
     }];
}

@end
