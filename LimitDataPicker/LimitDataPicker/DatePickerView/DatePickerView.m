//
//  DatePickerView.m
//  Friday
//
//  Created by mac-mini-ios on 15/7/23.
//  Copyright (c) 2015年 xtuone. All rights reserved.
//
#define LimitDay 59

#import "DatePickerView.h"
#import "UIColor+K1Util.h"
@interface DatePickerView ()
#pragma mark - IBActions
@property (weak, nonatomic) IBOutlet UIPickerView *customPicker;/**< 时间picker*/

@end

@implementation DatePickerView
{
    NSMutableArray *_yearArray;/**< 年选择数组*/
    NSArray *_monthArray;/**< 月选择数组*/
    NSMutableArray *_DaysArray;/**< 日选择数组*/
    NSArray *_amPmArray;/**< 上下午选择数组*/
    NSMutableArray *_monthAndDayArray;/**< 月份日期数组*/
    NSMutableArray *_yearAndMonthAndDayArr;/**< 年月日数组*/
    NSMutableArray *_smallYMDArr;/**< 需要的小的年月日数组*/
    
    NSString *_currentMonthString;/**< 当前的月份*/
    NSString *_currentMonthAndDayString;/**< 当前的月份和天数*/
    NSString *_endChoiceMonthAndDay;/**< 最终选择的月日字符串*/
    NSString *_endChoiceYearMD;/**< 最终选择的年月日字符串*/
    
    int _currentYearsNum;/**< 当前时间的年份(int)*/
}

#pragma mark - my methed
//DatePicker的存储路径
- (NSString *)createPath
{
    //    获得documents的目录
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    //   拼接一个新的路径
    NSString *newPath = [documentsPath stringByAppendingPathComponent:@"DatePicker"];
    return newPath;
}

//将传过来的时间字符串传化为NSNumber类型
- (double)sendTimeWithString:(NSString *)timeStr
{
    //获取当前点击按钮时的小时分钟秒数
    NSDate *date = [NSDate date];
    NSDateFormatter *currentFormatter = [[NSDateFormatter alloc] init];
    [currentFormatter setDateFormat:@"HH时mm分ss秒"];
    NSString *currentDateString = [NSString stringWithFormat:@"%@",[currentFormatter stringFromDate:date]];
    //将最终选择的年月日和当前获取到的小时分钟拼接 并最终生成所需的时间戳
    NSString *newTimeStr = [NSString stringWithFormat:@"%@ %@",timeStr,currentDateString];
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [inputFormatter setDateFormat:@"yyyy年MM月d日 HH时mm分ss秒"];
    NSDate *inputDate = [inputFormatter dateFromString:newTimeStr];
    NSString *timeString = [NSString stringWithFormat:@"%ld", (long)[inputDate timeIntervalSince1970]];
    
    return ([timeString doubleValue] * 1000);
}

#pragma mark - view cycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    NSDate *date = [NSDate date];
    
    // Get Current Year(获取当前的年份)
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy"];
    NSString *currentyearString = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
    _currentYearsNum = [currentyearString intValue];
    
    // Get Current  Month(获取当前的月份)
    [formatter setDateFormat:@"MM"];
    _currentMonthString = [NSString stringWithFormat:@"%ld",(long)[[formatter stringFromDate:date]integerValue]];
    
    // Get Current  Date(获取当前的天数)
    [formatter setDateFormat:@"d"];
    NSString *currentDateString = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
    
    //PickerView - Years data
    _yearArray = [[NSMutableArray alloc] init];
    for (int i = 1970; i <= 2050 ; i++)
    {
        [_yearArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    //PickerView - Months data
    _monthArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12"];
    
    // PickerView -  days data
    _DaysArray = [[NSMutableArray alloc]init];
    for (int i = 1; i <= 31; i++)
    {
        [_DaysArray addObject:[NSString stringWithFormat:@"%d",i]];
        
    }
    
    //PickerView - Months And days data
    _monthAndDayArray = [NSMutableArray array];
    _yearAndMonthAndDayArr = [NSMutableArray array];
    
    //判断是不是第一次(通过判断DatePicker.plist文件是否存在),如果是第一次创建文件,并将_monthAndDayArray数组存入plist文件中,如果不是第一次直接从文件中读取数据不用再次创建
    NSFileManager *fileManage = [NSFileManager defaultManager];
    [fileManage createDirectoryAtPath:[self createPath] withIntermediateDirectories:YES attributes:nil error:nil];
    if (![fileManage fileExistsAtPath:[[self createPath] stringByAppendingPathComponent:@"Year.plist"]])
    {
        [fileManage createFileAtPath:[[self createPath] stringByAppendingPathComponent:@"Year.plist"] contents:nil attributes:nil];
        NSString *yearFilePath = [NSString stringWithFormat:@"%@/Year.plist",[self createPath]];
        NSArray *yearArr = @[currentyearString];
        [yearArr writeToFile:yearFilePath atomically:YES];
    }
    NSString *oldYear = [[NSArray alloc] initWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/DatePicker/Year.plist"]][0];
    //通过判断文件夹下是否有DatePicker.plist文件 以及 当前年份过存储的oldYear的值去确定是否需要重写年月日数组
    if (![fileManage fileExistsAtPath:[[self createPath] stringByAppendingPathComponent:@"DatePicker.plist"]] || ![currentyearString isEqualToString:oldYear])
    {
        if ([fileManage fileExistsAtPath:[[self createPath] stringByAppendingPathComponent:@"DatePicker.plist"]])
        {
            [fileManage removeItemAtPath:[[self createPath] stringByAppendingPathComponent:@"DatePicker.plist"] error:nil];
            [fileManage removeItemAtPath:[[self createPath] stringByAppendingPathComponent:@"Year.plist"] error:nil];
            //在清除老的数组之后应该立即创建新的否则会出现老的年份读取错误的情况
            [fileManage createFileAtPath:[[self createPath] stringByAppendingPathComponent:@"Year.plist"] contents:nil attributes:nil];
            NSString *yearFilePath = [NSString stringWithFormat:@"%@/Year.plist",[self createPath]];
            NSArray *yearArr = @[currentyearString];
            [yearArr writeToFile:yearFilePath atomically:YES];
        }
        [fileManage createFileAtPath:[[self createPath] stringByAppendingPathComponent:@"DatePicker.plist"] contents:nil attributes:nil];
        NSString *filePath = [NSString stringWithFormat:@"%@/DatePicker.plist",[self createPath]];
        int currentMonthDay = 30;
        for (int i = _currentYearsNum - 1; i <= _currentYearsNum; i++)
        {
            for (int j = 1; j <= _monthArray.count; j ++)
            {
                if (j == 1 || j == 3 || j == 5 || j == 7 || j == 8 || j == 10 || j == 12)
                {
                    currentMonthDay = 31;
                }
                else if (j == 2)
                {
                    int yearint = _currentYearsNum;
                    
                    if(((yearint %4==0)&&(yearint %100!=0))||(yearint %400==0)){
                        
                        currentMonthDay = 29;
                    }
                    else
                    {
                        currentMonthDay = 28; // or return 29
                    }
                }
                else
                {
                    currentMonthDay = 30;
                }
                for (int k = 1; k <= currentMonthDay ; k ++)
                {
                    NSString *monthAndDayString = [NSString stringWithFormat:@"%d年%d月%d日",i,j,k];
                    [_yearAndMonthAndDayArr addObject:monthAndDayString];
                }
            }
        }
        
        [_yearAndMonthAndDayArr writeToFile:filePath atomically:YES];
    }
    
    _yearAndMonthAndDayArr = [[NSMutableArray alloc] initWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/DatePicker/DatePicker.plist"]];
    NSString *currentYMD = [NSString stringWithFormat:@"%@年%@月%@日",currentyearString,_currentMonthString,currentDateString];
    
    //找出当前年月日在数字中的位置
    int x = 0;
    for (x = (int)_yearAndMonthAndDayArr.count - 1; x >= 0 ; x -- )
    {
        NSString *ymdStr = _yearAndMonthAndDayArr[x];
        if ([currentYMD isEqualToString:ymdStr])
        {
            break;
        }
    }
    //获取需要的小的年月日数组
    _smallYMDArr = [NSMutableArray array];
    for (int i = x - LimitDay; i <= x; i ++)
    {
        NSString *ymdStr = _yearAndMonthAndDayArr[i];
        NSArray *array = [ymdStr componentsSeparatedByString:@"年"];
        
        [_smallYMDArr addObject:_yearAndMonthAndDayArr[i]];
        [_monthAndDayArray addObject:array[1]];
    }
    //PickerView - AM PM data
    _amPmArray = @[@"不确定",@"上午",@"中午",@"下午",@"晚上"];
    
    // PickerView - Default Selection as per current Date(默认选择的选项)
    _currentMonthAndDayString = [NSString stringWithFormat:@"%@月%@日",_currentMonthString,currentDateString];
    [self.customPicker selectRow:[_monthAndDayArray indexOfObject:_currentMonthAndDayString] inComponent:0 animated:YES];
    [self.customPicker selectRow:[_amPmArray indexOfObject:@"不确定"] inComponent:1 animated:YES];
    [self endChoiceReturenText];
}

//最终所有返回的信息都在此方法里
- (void)endChoiceReturenText
{
    if ([[_amPmArray objectAtIndex:[self.customPicker selectedRowInComponent:2]] isEqualToString:@"不确定"])
    {
        self.datePickerText = [NSString stringWithFormat:@"%@",[_monthAndDayArray objectAtIndex:[self.customPicker selectedRowInComponent:0]]];
        _endChoiceMonthAndDay =[NSString stringWithFormat:@"%@",[_monthAndDayArray objectAtIndex:[self.customPicker selectedRowInComponent:0]]];
        _endSendAmpm = @0;
        
        //根据最终选择的年月从数组中遍历找出所在数组中的位置
        int y  = 0;
        for (y = (int)_monthAndDayArray.count - 1; y >= 0; y --)
        {
            NSString *str = _monthAndDayArray[y];
            if ([_endChoiceMonthAndDay isEqualToString:str])
            {
                break;
            }
        }
        _endChoiceYearMD = _smallYMDArr[y];
        _endSendNumber = [self sendTimeWithString:_endChoiceYearMD];
        return;
    }
    else
    {
        self.datePickerText = [NSString stringWithFormat:@"%@%@",[_monthAndDayArray objectAtIndex:[self.customPicker selectedRowInComponent:0]],[_amPmArray objectAtIndex:[self.customPicker selectedRowInComponent:2]]];
        _endChoiceMonthAndDay =[NSString stringWithFormat:@"%@",[_monthAndDayArray objectAtIndex:[self.customPicker selectedRowInComponent:0]]];
        NSString *ampmStr = [_amPmArray objectAtIndex:[self.customPicker selectedRowInComponent:2]];
        int i = 0;
        for (i = 0; i <= 4; i ++)
        {
            if ([ampmStr isEqualToString:_amPmArray[i]])
            {
                _endSendAmpm = [NSNumber numberWithInt:i];
                break;
            }
        }
        
        //根据最终选择的年月从数组中遍历找出所在数组中的位置
        int y  = 0;
        for (y = (int)_monthAndDayArray.count - 1; y >= 0; y --)
        {
            NSString *str = _monthAndDayArray[y];
            if ([_endChoiceMonthAndDay isEqualToString:str])
            {
                break;
            }
        }
        _endChoiceYearMD = _smallYMDArr[y];
        _endSendNumber = [self sendTimeWithString:_endChoiceYearMD];
    }
}

#pragma mark - UIPickerViewDelegate
//已经选择了某个区地某一行(通常用来刷新界面时调用此方法)
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self endChoiceReturenText];
}

#pragma mark - UIPickerViewDatasource
//返回picker每个区每一行的内容
- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view
{
    // Custom View created for each component
    UILabel *pickerLabel = (UILabel *)view;
    
    if (pickerLabel == nil)
    {
        CGRect frame = CGRectMake(0.0, 0.0, 110.0, 44.0);
        pickerLabel = [[UILabel alloc] initWithFrame:frame];
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor colorWithHexString:@"#666666"]];
        [pickerLabel setFont:[UIFont systemFontOfSize:18.0f]];
        [pickerLabel setBackgroundColor:[UIColor colorWithHexString:@"#00000000"]];
    }
    if (component == 0)//第一行
    {
        pickerLabel.text = [_monthAndDayArray objectAtIndex:row];
    }
    else if (component == 2)//第三行
    {
        pickerLabel.text = [_amPmArray objectAtIndex:row];
    }
    else//第二行
    {
        pickerLabel.text = @"";
        pickerLabel.frame = CGRectMake(0.0, 0.0, 5.0, 44.0);
    }
    return pickerLabel;
}

//返回行高
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 44;
}

//返回多少列
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;//此处写三行,才能让picker上下滑动的字没有那么参差
}

// returns the # of rows in each component..
//每列有多少行
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0)//第一行
    {
        return LimitDay + 1;//为实现循环而设定,可以调的更大
    }
    else if(component == 1)//第二行,特殊处理
    {
        return 0;
    }
    else//第三行
    {
        return 5;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (component == 1 )
    {
        return 0;//第二行的存在意义完全是为了调节另两行显示
    }
    else
    {
        return 110;
    }
}
@end
