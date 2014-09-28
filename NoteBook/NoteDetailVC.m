//
//  NoteDetailVC.m
//  NoteBook
//
//  Created by  on 14-9-26.
//  Copyright (c) 2014年 __MyCompanyName__. All rights reserved.
//

#import "NoteDetailVC.h"

@implementation NoteDetailVC

#pragma mark - ViewLifeCycle视图生命周期
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 刚进入页面，没有处于编辑状态
    isTetxing = NO;
    
    // 设置导航栏
    self.navigationItem.hidesBackButton = YES;   // 隐藏返回按钮
    
//    UIButton *btnBack = [UIButton buttonWithType: UIButtonTypeCustom];
//    btnBack.frame = CGRectMake(0, 0, 60, 44);
//    //[btnBack setImage: [UIImage imageNamed: @"back_button.9.png"] forState: UIControlStateNormal];
//    [btnBack addTarget: self action: @selector(btnBackClick) forControlEvents: UIControlEventTouchUpInside];
//    
//    UIImageView *img = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"back_button.9.png"]];
//    img.frame = CGRectMake(0, 0, btnBack.frame.size.width, btnBack.frame.size.height);
//    [btnBack addSubview: img];
//    
//    UILabel *backLabel = [[UILabel alloc] initWithFrame: CGRectMake(28, 2, 60-5, 45-5)];
//    backLabel.text = @"列表";
//    backLabel.textColor = [UIColor whiteColor];
//    backLabel.font = [UIFont systemFontOfSize: 11.f];
//    backLabel.backgroundColor = [UIColor clearColor];
//    [btnBack addSubview: backLabel];
//    
//    [self.navigationController.navigationBar addSubview: btnBack];
    
    [self navShow];
    
    // 设置背景
    UIView *bgView = [[UIView alloc] initWithFrame: CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 20, self.view.frame.size.width, self.view.frame.size.height)];
    UIImageView *bgImg = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"note_paper_background_full.png"]];
    bgImg.frame = bgView.frame;
    [bgView addSubview: bgImg];
    
    [self.view addSubview: bgView];
    
    // 第三方类库
    notepad = [[KGNotePad alloc] initWithFrame: CGRectMake(self.view.frame.origin.x + 10, self.view.frame.origin.y - 20, self.view.frame.size.width, self.view.frame.size.height)];
    notepad.textView.font=[UIFont systemFontOfSize:18.f];
    // 设置线条颜色
    [notepad setVerticalLineColor: [UIColor colorWithRed: 228/255.f green: 224/255.f blue: 215/255.f alpha: 1]];
    [notepad setPaperBackgroundColor: [UIColor colorWithRed: 248/255.f green: 243/255.f blue: 235/255.f alpha: 1]];
    [self.view addSubview: notepad];
    
    // 输入框的相关设置
    notepad.textView.returnKeyType = UIReturnKeyDefault;   // 返回键类型
    
    //notepad.textView.keyboardType = UIKeyboardTypeDefault;  // 键盘类型
    
    notepad.textView.textColor = [UIColor colorWithRed: 110/255.f green: 67/255.f blue: 47/255.f alpha: 1];
    
    notepad.textView.scrollEnabled = YES;    // 是否可以拖动
    
    notepad.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;   // 自适应高度
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 注册键盘出现通知
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(keyboardDidShow:) name: UIKeyboardDidShowNotification object: nil];
    
    // 注册键盘隐藏通知
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(keyboardDidHide:) name: UIKeyboardDidHideNotification object: nil];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 移除导航栏视图
    [navView removeFromSuperview];
    
    // 解除键盘出现通知
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIKeyboardDidShowNotification object: nil];
    
    // 解除键盘隐藏通知
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIKeyboardDidHideNotification object: nil];
    
}

#pragma mark - NoteAdd,Del,Change数据增删改查
// 进入详情页面，显示记事详细
- (void)showDetail:(int)line
{
    noteDao = [[NoteDAO alloc] init];
    
    noteList = [noteDao queryFromDB];
    
    note = [noteList objectAtIndex: line];
    
    notepad.textView.text = note.content;
    
    numOfNote = line;
    
}

// 点击记事本，进入编辑状态，点击保存，更新数据
- (void)reSaveNote
{
    noteList = [noteDao queryFromDB];
    
    note = [noteList objectAtIndex: numOfNote];
    
    NSString *reString = notepad.textView.text;
    [noteDao updateNote: note andContent: reString andDate: [NSDate date]];
}

// 删除记事
- (void)deleteNote
{
    noteList = [noteDao queryFromDB];
    
    note = [noteList objectAtIndex: numOfNote];
    
    [noteDao deleteNote: note];
}


#pragma mark - 键盘出现通知
// 键盘出现时，导航栏相应变化
- (void)keyboardDidShow:(NSNotification *)notif
{
    isTetxing = YES;
    [self navShow];
    
    // 获得键盘尺寸
    NSDictionary *info = [notif userInfo];
    NSValue *aValue = [info objectForKey: UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    
    // 重新定义输入框的尺寸
    CGRect viewFrame = notepad.frame;
    viewFrame.size.height -= (keyboardSize.height + 50);
    //notepad.frame = viewFrame;

    notepad.textView.textInputView.frame = viewFrame;
    
}

- (void)keyboardDidHide:(NSNotification *)notif
{
    isTetxing = NO;
    [self navShow];
    
    NSDictionary *info = [notif userInfo];
    NSValue *aValue = [info objectForKey: UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    
    // 键盘消失时，恢复原有高度
    CGRect viewFrame = notepad.frame;
    viewFrame.size.height += (keyboardSize.height + 50);
    notepad.frame = viewFrame;
    
}


#pragma mark - 导航栏表现
// 导航栏表现
- (void)navShow
{
    // 先将已经存在的navView移除
    [navView removeFromSuperview];
    
    navView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    
    UIButton *btnBack = [UIButton buttonWithType: UIButtonTypeCustom];
    btnBack.frame = CGRectMake(0, 0, 60, 44);
    //[btnBack setImage: [UIImage imageNamed: @"back_button.9.png"] forState: UIControlStateNormal];
    [btnBack addTarget: self action: @selector(btnBackClick) forControlEvents: UIControlEventTouchUpInside];
    
    UIImageView *img = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"back_button.9.png"]];
    img.frame = CGRectMake(0, 0, btnBack.frame.size.width, btnBack.frame.size.height);
    [btnBack addSubview: img];
    
    UILabel *backLabel = [[UILabel alloc] initWithFrame: CGRectMake(28, 2, 60-5, 45-5)];
    backLabel.text = @"列表";
    backLabel.textColor = [UIColor whiteColor];
    backLabel.font = [UIFont systemFontOfSize: 11.f];
    backLabel.backgroundColor = [UIColor clearColor];
    [btnBack addSubview: backLabel];
    
    [navView addSubview: btnBack];
    
    if(isTetxing) {   // 正处于编辑状态（则右边的按钮应该为保存按钮）
        UIButton *btnSave = [UIButton buttonWithType: UIButtonTypeCustom];
        btnSave.frame = CGRectMake(self.navigationController.navigationBar.frame.size.width - 70, 0, 60, 44);
        [btnSave addTarget: self action: @selector(btnSaveClick) forControlEvents: UIControlEventTouchUpInside];
        
        UIImageView *imgSave = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"button.png"]];
        imgSave.frame = CGRectMake(0, 0, btnSave.frame.size.width, btnSave.frame.size.height);
        [btnSave addSubview: imgSave];
        
        UILabel *saveLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 60 - 20, 44)];
        saveLabel.text = @"完成";
        saveLabel.textColor = [UIColor whiteColor];
        saveLabel.font = [UIFont systemFontOfSize: 11.f];
        saveLabel.backgroundColor = [UIColor clearColor];
        [btnSave addSubview: saveLabel];
        
        [navView addSubview: btnSave];
        
    } else {
        
        UIButton *btnDel = [UIButton buttonWithType: UIButtonTypeCustom];
        btnDel.frame = CGRectMake(self.navigationController.navigationBar.frame.size.width - 70, 2, 60, 40);
        [btnDel addTarget: self action: @selector(btnDelClick) forControlEvents: UIControlEventTouchUpInside];
        
        UIImageView *imgSave = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"delete_button_normal.9.png"]];
        imgSave.frame = CGRectMake(0, 0, btnDel.frame.size.width, btnDel.frame.size.height);
        [btnDel addSubview: imgSave];
        
        [navView addSubview: btnDel];
        
    }
    
    [self.navigationController.navigationBar addSubview: navView];
    
}



#pragma mark - ButtonAction按钮点击事件
- (void)btnBackClick
{
    [self.navigationController popViewControllerAnimated: YES];
}

// 编辑完成后，重新保存记事
- (void)btnSaveClick
{
    NSLog(@"完成按钮被点击");
    [self reSaveNote];
    [notepad.textView resignFirstResponder];
}

// 进入页面，点击删除，删除记事
- (void)btnDelClick
{
    [self deleteNote];
    NSLog(@"删除按钮被点击");
    [self.navigationController popViewControllerAnimated: YES];
}


@end
