//
//  InquireInfoViewController.m
//  GDRMMobile
//
//  Created by yu hongwu on 12-4-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "InquireInfoViewController.h"
#import "Systype.h"
#import "RoadSegment.h"
#import "Citizen.h"
#import "OrgInfo.h"
#import "UserInfo.h"
#import "AppConstants.h"

#define FONT_SIZE 17.0f
#define CELL_CONTENT_WIDTH 385.0f
#define CELL_CONTENT_MARGIN 5.0f
#define PROFESSION_INDIVIDUAL @"个体"

@interface InquireInfoViewController (){
    //判断当前信息是否保存
    bool inquireSaved;
    //位置字符串
    NSString *localityString;
}
//所选问题的标识
@property (nonatomic,copy)   NSString *askID;
@property (nonatomic,retain) NSMutableArray *caseInfoArray;
@property (nonatomic,retain) UIPopoverController *pickerPopOver;

-(void)loadCaseInfoArray;
-(void)keyboardWillShow:(NSNotification *)aNotification;
-(void)keyboardWillHide:(NSNotification *)aNotification;
-(void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up;
-(void)insertString:(NSString *)insertingString intoTextView:(UITextView *)textView;
-(NSString *)getEventDescWithCitizenName:(NSString *)citizenName;
@end

@implementation InquireInfoViewController

@synthesize uiButtonAdd = _uiButtonAdd;
@synthesize inquireTextView = _inquireTextView;
@synthesize textAsk = _textAsk;
@synthesize textAnswer = _textAnswer;
@synthesize textNexus = _textNexus;
@synthesize textParty = _textParty;
@synthesize textLocality = _textLocality;
@synthesize textInquireDate = _textInquireDate;
@synthesize caseInfoListView = _caseInfoListView;
@synthesize caseID=_caseID;
@synthesize caseInfoArray=_caseInfoArray;
@synthesize pickerPopOver=_pickerPopOver;
@synthesize askID=_askID;
@synthesize answererName=_answererName;
@synthesize delegate=_delegate;
@synthesize navigationBar = _navigationBar;


- (void)viewDidLoad
{
	
	//remove UINavigationBar inner shadow in iOS 7
    [_navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    _navigationBar.shadowImage = [[UIImage alloc] init];
	

    self.askID=@"";
    self.textAsk.text=@"";
    self.textAnswer.text=@"";
    inquireSaved=YES;
    self.textNexus.text=@"当事人";
    
//    NSString *imagePath=[[NSBundle mainBundle] pathForResource:@"询问笔录-bg" ofType:@"png"];
//    self.view.layer.contents=(id)[[UIImage imageWithContentsOfFile:imagePath] CGImage];
    
    //监视键盘出现和隐藏通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.inquireTextView addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:NULL];
    
    [super viewDidLoad];
    self.caseInfoListView.frame = CGRectMake(1, 412, 388, 350);
    [self.view addSubview:self.caseInfoListView];
}

- (void)viewDidAppear:(BOOL)animated{
    //生成常见案件信息答案
    [self loadCaseInfoArray];
    //载入询问笔录
    if (![self.answererName isEmpty]) {
        [self loadInquireInfoForCase:self.caseID andAnswererName:self.answererName];
    } else {
        [self loadInquireInfoForCase:self.caseID andAnswererName:@""];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.inquireTextView removeObserver:self forKeyPath:@"text"];
}

- (void)viewDidUnload
{
    [self setCaseID:nil];
    [self setCaseInfoArray:nil];
    [self setInquireTextView:nil];
    [self setTextAsk:nil];
    [self setTextAnswer:nil];
    [self setAskID:nil];
    [self setTextNexus:nil];
    [self setTextParty:nil];
    [self setTextLocality:nil];
    [self setTextInquireDate:nil];
    [self setAnswererName:nil];
    [self setUiButtonAdd:nil];
    [self setCaseInfoListView:nil];
    [self setDelegate:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


//添加常用问答
- (IBAction)btnAddRecord:(id)sender{
    if (![self.textAsk.text isEmpty]) {
        NSString *insertingString=[NSString stringWithFormat:@"%@",self.textAsk.text];
        if (self.textAnswer && ![self.textAnswer.text isEmpty]) {
           insertingString = [NSString stringWithFormat:@"%@\n%@",insertingString,self.textAnswer.text ];
        }
        [self insertString:insertingString intoTextView:self.inquireTextView];
    } else {        
        [self insertString:self.textAnswer.text intoTextView:self.inquireTextView];
    }
}

//返回按钮，若未保存，则提示
-(IBAction)btnDismiss:(id)sender{
    if ([self.caseID isEmpty] || [self.textParty.text isEmpty] || inquireSaved) {
        [self.delegate loadInquireForAnswerer:self.textParty.text];
        [self dismissModalViewControllerAnimated:YES];
    } else {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"当前询问笔录已修改，尚未保存，是否返回？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];    
        [alert show];
    }    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self dismissModalViewControllerAnimated:YES];
    }
}


//键盘出现和消失时，变动TextView的大小
-(void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up{
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect newFrame = self.inquireTextView.frame;
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    if (keyboardFrame.size.height>360) {
        newFrame.size.height = up?269:635;
    } else {
        newFrame.size.height =  up?323:635;
    }
    self.inquireTextView.frame = newFrame;
    
    [UIView commitAnimations];   
}

-(void)keyboardWillShow:(NSNotification *)aNotification{
    [self moveTextViewForKeyboard:aNotification up:YES];
}

-(void)keyboardWillHide:(NSNotification *)aNotification{
    [self moveTextViewForKeyboard:aNotification up:NO];
}

//保存当前询问笔录信息
-(IBAction)btnSave:(id)sender{
    if (![self.textParty.text isEmpty]) {
        inquireSaved=YES;
        [self saveInquireInfoForCase:self.caseID andAnswererName:self.textParty.text];
    } else {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"无法保存" message:@"缺少被询问人姓名，无法正常保存。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)loadInquireInfoForCase:(NSString *)caseID andAnswererName:(NSString *)aAnswererName{
    self.textAnswer.text = @"";
    self.textAsk.text = @"";
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"CaseInquire" inManagedObjectContext:context];
    NSPredicate *predicate;
    if ([aAnswererName isEmpty]) {
        predicate=[NSPredicate predicateWithFormat:@"proveinfo_id==%@",caseID];
    } else {
        predicate=[NSPredicate predicateWithFormat:@"(proveinfo_id==%@) && (answerer_name==%@)",caseID,aAnswererName];
    }    
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];   
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    NSArray *tempArray=[context executeFetchRequest:fetchRequest error:nil];
    CaseInquire *caseInquire;
    if (tempArray.count>0) {
        caseInquire=[tempArray objectAtIndex:0];
        self.textParty.text=caseInquire.answerer_name;
        self.textNexus.text=caseInquire.relation;
        self.inquireTextView.text=caseInquire.inquiry_note;
        if ([caseInquire.locality isEmpty]) {
            self.textLocality.text=localityString;
        } else {
            self.textLocality.text=caseInquire.locality;
        }        
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        self.textInquireDate.text=[dateFormatter stringFromDate:caseInquire.date_inquired];
    } else {
        NSString *currentUserID=[[NSUserDefaults standardUserDefaults] stringForKey:USERKEY];
        NSString *currentUserName=[[UserInfo userInfoForUserID:currentUserID] valueForKey:@"username"];
        NSArray *inspectorArray = [[NSUserDefaults standardUserDefaults] objectForKey:INSPECTORARRAYKEY];
        NSString * namenum;
        if (inspectorArray.count < 1) {
            namenum = [UserInfo exelawidofuserInfoForusername:currentUserName];
        } else {
            NSString * inspectorName = [inspectorArray objectAtIndex:0];
            namenum = [UserInfo exelawidofuserInfoForusername: inspectorName];
        }
        self.textParty.text = aAnswererName;
//        NSString *currentUserID=[[NSUserDefaults standardUserDefaults] stringForKey:USERKEY];
        NSString * organizationName = [[OrgInfo orgInfoForOrgID:[UserInfo userInfoForUserID:currentUserID].organization_id] valueForKey:@"orgname"];
        NSString * text = [NSString stringWithFormat:@"%@%@%@%@%@",@"问：你好，我们是",organizationName,@"的路政员，请看，这是我的执法证件，执法证件号码是",namenum,@",向你了解一些情况，希望你如实回答，你对你的回答是要负法律责任，你明白吗？\n答：明白。" ];
        self.inquireTextView.text = text;
//        self.inquireTextView.text = @"问：您好，我们是广东省公路管理局南二环高速公路路政大队一中队的路政员，向你了解一些情况，希望你如实回答，你对你的回答是要负法律责任，你明白吗？\n答：明白。";
        self.textLocality.text=localityString;
    }
    inquireSaved=YES;
}

-(void)loadInquireInfoForCase:(NSString *)caseID andNexus:(NSString *)aNexus{
    self.textAnswer.text=@"";
    self.textAsk.text=@"";
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"CaseInquire" inManagedObjectContext:context];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"(proveinfo_id==%@) && (relation==%@)",caseID,aNexus];
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];   
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    NSArray *tempArray=[context executeFetchRequest:fetchRequest error:nil];
    CaseInquire *caseInquire;
    if (tempArray.count>0) {
        caseInquire=[tempArray objectAtIndex:0];
        self.textParty.text=caseInquire.answerer_name;
        self.textNexus.text=caseInquire.relation;
        self.inquireTextView.text=caseInquire.inquiry_note;
        if ([caseInquire.locality isEmpty]) {
            self.textLocality.text=localityString;
        } else {
            self.textLocality.text=caseInquire.locality;
        }        
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        self.textInquireDate.text=[dateFormatter stringFromDate:caseInquire.date_inquired];
    } else {
        self.inquireTextView.text=[[Systype typeValueForCodeName:@"询问笔录固定用语"] lastObject];
        self.textLocality.text=localityString;
    }
    inquireSaved=YES;
}

-(void)saveInquireInfoForCase:(NSString *)caseID andAnswererName:(NSString *)aAnswererName{
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"CaseInquire" inManagedObjectContext:context];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"(proveinfo_id==%@) && (answerer_name==%@)",caseID,aAnswererName];
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    NSArray *tempArray=[context executeFetchRequest:fetchRequest error:nil];
    CaseInquire *caseInquire;
    if (tempArray.count>0) {
        caseInquire=[tempArray objectAtIndex:0];
    } else {
        caseInquire=[CaseInquire newDataObjectWithEntityName:@"CaseInquire"];
        caseInquire.proveinfo_id=self.caseID;
        caseInquire.answerer_name=aAnswererName;
    }
    NSString *currentUserID=[[NSUserDefaults standardUserDefaults] stringForKey:USERKEY];
    NSString *currentUserName=[[UserInfo userInfoForUserID:currentUserID] valueForKey:@"username"];
    NSArray *inspectorArray = [[NSUserDefaults standardUserDefaults] objectForKey:INSPECTORARRAYKEY];
    if (inspectorArray.count < 1) {
        caseInquire.inquirer_name = currentUserName;
    } else {
        NSString *inspectorName = [inspectorArray objectAtIndex:0];
        caseInquire.inquirer_name = inspectorName;
    }
    caseInquire.recorder_name = currentUserName;
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    caseInquire.date_inquired=[dateFormatter dateFromString:self.textInquireDate.text];
    caseInquire.locality=self.textLocality.text;
    caseInquire.inquiry_note=self.inquireTextView.text;
    
    entity=[NSEntityDescription entityForName:@"Citizen" inManagedObjectContext:context];
    predicate=[NSPredicate predicateWithFormat:@"(proveinfo_id==%@) && (party==%@)",self.caseID,aAnswererName];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    tempArray=[context executeFetchRequest:fetchRequest error:nil];
    if (tempArray.count>0) {
        Citizen *citizen=[tempArray objectAtIndex:0];
        caseInquire.relation=citizen.nexus;
        caseInquire.sex=citizen.sex;
        caseInquire.age=citizen.age;
        caseInquire.company_duty=[NSString stringWithFormat:@"%@ %@",citizen.org_name?citizen.org_name:@"",citizen.org_principal_duty?citizen.org_principal_duty:@""];
        caseInquire.phone=citizen.tel_number;
        caseInquire.postalcode=citizen.postalcode;
        caseInquire.address=citizen.address;
    }    
    [[AppDelegate App] saveContext];
}


//文本框点击事件
- (IBAction)textTouched:(UITextField *)sender {
    switch (sender.tag) {
        case 100:{
            //点击问
            [self pickerPresentForIndex:2 fromRect:sender.frame];
        }
            break;
        case 101:{
            //点击答
            [self pickerPresentForIndex:3 fromRect:sender.frame];
        }
            break;
        case 102:{
            //被询问人类型
            [self pickerPresentForIndex:0 fromRect:sender.frame];
        }
            break;
        case 103:{
            //被询问人
            [self pickerPresentForIndex:1 fromRect:sender.frame];
        }
            break;
        case 104:{
            //询问地点
            if ([self.pickerPopOver isPopoverVisible]) {
                [self.pickerPopOver dismissPopoverAnimated:YES];
            }
        }
            break;
        case 105:{
            //询问时间
            if ([self.pickerPopOver isPopoverVisible]) {
                [self.pickerPopOver dismissPopoverAnimated:YES];
            } else {
                DateSelectController *datePicker=[self.storyboard instantiateViewControllerWithIdentifier:@"datePicker"];
                datePicker.delegate=self;
                datePicker.pickerType=1;
                datePicker.datePicker.maximumDate=[NSDate date];
                [datePicker showdate:self.textInquireDate.text];
                self.pickerPopOver=[[UIPopoverController alloc] initWithContentViewController:datePicker];
                [self.pickerPopOver presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
                datePicker.dateselectPopover=self.pickerPopOver;
            }
        }
            break;
        default:
            break;
    }
}

//弹窗
-(void)pickerPresentForIndex:(NSInteger )pickerType fromRect:(CGRect)rect{
    if ([_pickerPopOver isPopoverVisible]) {
        [_pickerPopOver dismissPopoverAnimated:YES];
    } else {
        AnswererPickerViewController *pickerVC=[[AnswererPickerViewController alloc] initWithStyle:
                                                UITableViewStylePlain];
        pickerVC.pickerType=pickerType;
        pickerVC.delegate=self;
        self.pickerPopOver=[[UIPopoverController alloc] initWithContentViewController:pickerVC];
        if (pickerType == 0 || pickerType == 1 ) {
            pickerVC.tableView.frame=CGRectMake(0, 0, 140, 176);
            self.pickerPopOver.popoverContentSize=CGSizeMake(140, 176);
        } 
        if (pickerType == 2 || pickerType ==3) {
            pickerVC.tableView.frame=CGRectMake(0, 0, 388, 280);
            [pickerVC.tableView setRowHeight:70];
            self.pickerPopOver.popoverContentSize=CGSizeMake(388, 280);
        } 
        [_pickerPopOver presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
        pickerVC.pickerPopover=self.pickerPopOver;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.caseInfoArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    UILabel *label = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"CaseInfoAnswserCell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CaseInfoAnswserCell"];
        
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        [label setLineBreakMode:UILineBreakModeWordWrap];
        [label setMinimumFontSize:FONT_SIZE];
        [label setNumberOfLines:0];
        [label setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        [label setTag:1];
        
        [[cell contentView] addSubview:label];
        
    }
    NSString *text = [self.caseInfoArray objectAtIndex:[indexPath row]];
    
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    if (!label)
        label = (UILabel*)[cell viewWithTag:1];
    
    [label setText:text];
    [label setFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), MAX(size.height, 44.0f))];
    
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSString *text = [self.caseInfoArray objectAtIndex:[indexPath row]];
    
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat height = MAX(size.height, 44.0f);
    
    return height + (CELL_CONTENT_MARGIN * 2);
}
//将选中的答案填到textfield和textview中
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    UILabel *label = (UILabel*)[cell viewWithTag:1];
    [self insertString:label.text intoTextView:self.inquireTextView];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}




//载入案件数据常用答案
-(void)loadCaseInfoArray{
    if (self.caseInfoArray==nil) {
        self.caseInfoArray=[[NSMutableArray alloc] initWithCapacity:1];
    } else {
        [self.caseInfoArray removeAllObjects];
    }
    
    
    CaseInfo *caseInfo=[CaseInfo caseInfoForID:self.caseID];
    NSString *dateString;
    NSString *reasonString;
    if (caseInfo) {
        NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateFormat:@"yyyy年MM月dd日 HH时mm分"];
        dateString=[formatter stringFromDate:caseInfo.happen_date];

        
        NSInteger stationStartM=caseInfo.station_start.integerValue%1000;
        NSString *stationStartKMString=[NSString stringWithFormat:@"%d", caseInfo.station_start.integerValue/1000];
        NSString *stationStartMString=[[AppConstants numberFormatter] stringFromNumber:[NSNumber numberWithInteger:stationStartM]];
        NSString *stationString;
        if([caseInfo.side rangeOfString:@"收费站" options:NSBackwardsSearch].location == 2 || [caseInfo.place rangeOfString:@"匝道" options:NSBackwardsSearch].location == 1){
            stationString = @"";
        }else{
            if (caseInfo.station_end.integerValue == 0 || caseInfo.station_end.integerValue == caseInfo.station_start.integerValue  ) {
                stationString=[NSString stringWithFormat:@"K%@+%@处",stationStartKMString,stationStartMString];
            } else {
                NSInteger stationEndM=caseInfo.station_end.integerValue%1000;
                NSString *stationEndKMString=[NSString stringWithFormat:@"%d",caseInfo.station_end.integerValue/1000];
                NSString *stationEndMString=[[AppConstants numberFormatter] stringFromNumber:[NSNumber numberWithInteger:stationEndM]];
                stationString=[NSString stringWithFormat:@"K%@+%@至K%@+%@处",stationStartKMString,stationStartMString,stationEndKMString,stationEndMString ];
            }
        }
        NSString *roadName=[RoadSegment roadNameFromSegment:caseInfo.roadsegment_id];
        
        localityString=[NSString stringWithFormat:@"%@%@%@",roadName,caseInfo.side,stationString];
        reasonString=[NSString stringWithFormat:@"%@",caseInfo.case_reason];

    }

    
    [self generatePersonalQuestionsAndAnswers];
    [self.caseInfoListView reloadData];
}
-(void)generatePersonalQuestionsAndAnswers{
    if (_answererName && ![_answererName isEmpty]) {
        Citizen *citizen = [Citizen citizenByCitizenParty:_answererName case:self.caseID ];
        if(citizen){
            [self.caseInfoArray addObject:@"问：请问你的姓名，身份证号码，年龄，住址，任职单位及职务。"];
            NSString *str = @"";
            if ([citizen.org_principal_duty isEqual:PROFESSION_INDIVIDUAL] || citizen.org_principal_duty == nil || [citizen.org_principal_duty isEmpty]) {
                str = [NSString stringWithFormat:@"答：我叫%@，身份证号码是%@，%@岁，住址是%@，个体。",
                       citizen.party ? citizen.party : @"",
                       citizen.card_no ? citizen.card_no : @"",
                       citizen.age.stringValue,
                       citizen.address ? citizen.address : @""];
            }else{
                str = [NSString stringWithFormat:@"答：我叫%@，身份证号码是%@，%@岁，住址是%@，任职于%@，职务是%@。",
                       citizen.party ? citizen.party : @"",
                       citizen.card_no ? citizen.card_no : @"",
                       citizen.age.stringValue,
                       citizen.address ? citizen.address : @"",
                       citizen.org_name ? citizen.org_name : @"",
                       citizen.org_principal_duty ? citizen.org_principal_duty : @""];
            }
            [self.caseInfoArray addObject:str];
            [self.caseInfoArray addObject:@"问：请问你驾驶车辆的车型、牌号及车辆所属单位和地址？"];
            NSString *automobile_pattern = [citizen.automobile_pattern stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([automobile_pattern isEqualToString:@"重型半挂牵引车"]) {
                NSArray *array = [citizen.automobile_number componentsSeparatedByString:@"/"];
                NSString *number = @"";
                NSString *number2 = @"";
                if([array count] > 1){
                    number = array[0];
                    number2 = array[1];
                }else if([array count] == 1){
                    number = array[0];
                  
                }
                if ([[number2 substringFromIndex:number2.length-1 ] isEqualToString:@"挂"]) {
                    number2 = [number2 substringToIndex:number2.length-1];
                }
                str = [NSString stringWithFormat:@"答：我驾驶的车型是%@，重型半挂牵引车车牌是%@，挂车车牌是%@挂，车辆所属单位是%@，地址是%@。",
                       citizen.automobile_pattern ? citizen.automobile_pattern : @"",
                       number,number2,
                       citizen.carowner ? citizen.org_name : @"",
                       citizen.automobile_address ? citizen.automobile_address : @""];
            }else{
                str = [NSString stringWithFormat:@"答：我驾驶车辆的车型是%@，车牌号码是%@，车辆所属单位是%@，地址是%@。",
                       citizen.automobile_pattern ? citizen.automobile_pattern : @"",
                       citizen.automobile_number ? citizen.automobile_number : @"",
                       citizen.carowner ? citizen.org_name : @"",
                       citizen.automobile_address ? citizen.automobile_address : @""];
            }
            [self.caseInfoArray addObject:str];
            [self.caseInfoArray addObject:@"问：请你讲述一下事故经过？"];
            str = [NSString stringWithFormat:@"答：我%@",[self getEventDescWithCitizenName:citizen.automobile_number]];
            [self.caseInfoArray addObject:str];
            [self.caseInfoArray addObject:@"问：请问你所驾驶的车辆有无购买保险？请你提供保险公司名称及保险单号？"];
            if (![citizen.insurance_company isEmpty] || ![citizen.insurance_no isEmpty]) {
                str = [NSString stringWithFormat:@"答：有，保险公司是%@，保险单号是%@。",
                       citizen.insurance_company ? citizen.insurance_company : @"",
                       citizen.insurance_no ? citizen.insurance_no : @""];
            }else{
                str = @"答：无。";
            }
            [self.caseInfoArray addObject:str];
            [self.caseInfoArray addObject:[AnswererPickerViewController generateNoticeAskSentence:self.caseID citizen:citizen]];
            [self.caseInfoArray addObject:@"答：无异议。"];
            [self.caseInfoArray addObject:@"问：你对以上笔录如无异议请签字捺印。"];
            [self.caseInfoArray addObject:@"答：好。"];
        }
    }
}
-(NSString *)getEventDescWithCitizenName:(NSString *)citizenName{
    CaseInfo *caseInfo=[CaseInfo caseInfoForID:self.caseID];
    //高速名称，以后确定道路根据caseInfo.roadsegment_id获取
    NSString *roadName=[RoadSegment roadNameFromSegment:caseInfo.roadsegment_id];
    NSString *caseDescString=@"";    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日HH时mm分"];
    NSString *happenDate=[dateFormatter stringFromDate:caseInfo.happen_date];
    

    NSInteger stationStartM=caseInfo.station_start.integerValue%1000;
    NSString *stationStartKMString=[NSString stringWithFormat:@"%d", caseInfo.station_start.integerValue/1000];
    NSString *stationStartMString=[[AppConstants numberFormatter] stringFromNumber:[NSNumber numberWithInteger:stationStartM]];
     NSString *stationString = @"";
    if([caseInfo.side rangeOfString:@"收费站" options:NSBackwardsSearch].location == 2 || [caseInfo.place rangeOfString:@"匝道" options:NSBackwardsSearch].location == 1){
        stationString = @"";
    }else{
        stationString=[NSString stringWithFormat:@"K%@+%@处",stationStartKMString,stationStartMString];
    }
    NSArray *citizenArray=[Citizen allCitizenNameForCase:self.caseID];
    if (citizenArray.count>0) {
        if (citizenArray.count==1) {
            Citizen *citizen=[citizenArray objectAtIndex:0];
            
            caseDescString=[caseDescString stringByAppendingFormat:@"于%@驾驶%@行至%@%@%@，在公路%@%@发生交通事故。",happenDate,[citizen automobileName],roadName,caseInfo.side,stationString,caseInfo.place,caseInfo.case_reason];
        }
        if (citizenArray.count>1) {
            for (Citizen *citizen in citizenArray) {
                if ([citizen.automobile_number isEqualToString:citizenName]) {
                    caseDescString=[caseDescString stringByAppendingFormat:@"于%@驾驶%@行至%@%@%@，与",happenDate,[citizen automobileName],roadName,caseInfo.side,stationString];
                }
            }
            NSString *citizenString=@"";
            for (Citizen *citizen in citizenArray) {
                if (![citizen.automobile_number isEqualToString:citizenName]) {
                    if ([citizenString isEmpty]) {
                        citizenString=[citizenString stringByAppendingFormat:@"%@",[citizen automobileName]];
                    } else {
                        citizenString=[citizenString stringByAppendingFormat:@"、%@",[citizen automobileName]];
                    }
                }
            }
            caseDescString=[caseDescString stringByAppendingFormat:@"，在公路%@%@发生碰撞，造成交通事故。",caseInfo.place,caseInfo.case_reason];
        }
    }
    return caseDescString;
}

-(NSString *)getDeformDescWithCitizenName:(NSString *)citizenName{
    NSString *deformString=@"";
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSEntityDescription *deformEntity=[NSEntityDescription entityForName:@"CaseDeformation" inManagedObjectContext:context];
    NSPredicate *deformPredicate=[NSPredicate predicateWithFormat:@"proveinfo_id ==%@ && citizen_name==%@",self.caseID,citizenName];
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
    [fetchRequest setEntity:deformEntity];
    [fetchRequest setPredicate:deformPredicate];
    NSArray *deformArray=[context executeFetchRequest:fetchRequest error:nil];
    if (deformArray.count>0) {
        for (CaseDeformation *deform in deformArray) {
            NSString *roadSizeString=[deform.rasset_size stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([roadSizeString isEmpty]) {
                roadSizeString=@"";
            } else {
                roadSizeString=[NSString stringWithFormat:@"（%@）",roadSizeString];
            }
            NSString *remarkString=[deform.remark stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([remarkString isEmpty]) {
                remarkString=@"";
            } else {
                remarkString=[NSString stringWithFormat:@"（%@）",remarkString];
            }
            NSString *quantity=[[NSString alloc] initWithFormat:@"%.2f",deform.quantity.floatValue];
            NSCharacterSet *zeroSet=[NSCharacterSet characterSetWithCharactersInString:@".0"];
            quantity=[quantity stringByTrimmingTrailingCharactersInSet:zeroSet];
            deformString=[deformString stringByAppendingFormat:@"、%@%@%@%@%@",deform.roadasset_name,roadSizeString,quantity,deform.unit,remarkString];
        }
        NSCharacterSet *charSet=[NSCharacterSet characterSetWithCharactersInString:@"、"];
        deformString=[deformString stringByTrimmingCharactersInSet:charSet];
    } else {
        deformString=@"";
    }
    return deformString;
}

//在光标位置插入文字
-(void)insertString:(NSString *)insertingString intoTextView:(UITextView *)textView  
{
    
    //如果insertingString的开头是"答："或者是"问：",则在前面要插入换行
    NSRange findedRange = [insertingString rangeOfString:@"答："];
    if (findedRange.location == NSNotFound || findedRange.location != 0) {
        findedRange = [insertingString rangeOfString:@"问："];
    }
    if (findedRange.location != NSNotFound && findedRange.location == 0) {
        insertingString = [@"\n" stringByAppendingString:insertingString];
    }
    NSRange range = textView.selectedRange;
    if (range.location != NSNotFound) {
        NSString * firstHalfString = [textView.text substringToIndex:range.location];
        NSString * secondHalfString = [textView.text substringFromIndex: range.location];
        textView.scrollEnabled = NO;  // turn off scrolling
        
        textView.text=[NSString stringWithFormat:@"%@%@%@",
                       firstHalfString,
                       insertingString,
                       secondHalfString
                       ];
        range.location += [insertingString length];
        textView.selectedRange = range;
        textView.scrollEnabled = YES;  // turn scrolling back on.
    } else {
        textView.text = [textView.text stringByAppendingString:insertingString];
        [textView becomeFirstResponder];
    }    
}

//delegate，返回caseID
-(NSString *)getCaseIDDelegate{
    return self.caseID;
}

//delegate，设置被询问人名称
-(void)setAnswererDelegate:(NSString *)aText{
    self.answererName = aText;
    [self loadInquireInfoForCase:self.caseID andAnswererName:aText];
    [self loadCaseInfoArray];
}

//delegate，设置被询问人类型
-(void)setNexusDelegate:(NSString *)aText{
    if (![self.textNexus.text isEqualToString:aText]) {
        self.textNexus.text=aText;
        self.textParty.text=@"";
        [self loadInquireInfoForCase:self.caseID andNexus:aText];
        [self loadCaseInfoArray];
    }
}

//delegate，返回被询问人类型
-(NSString *)getNexusDelegate{
    if (self.textNexus.text==nil) {
        return @"";
    } else {
        return self.textNexus.text;
    }
}

//设置询问时间
-(void)setDate:(NSString *)date{
    self.textInquireDate.text=date;
}

//设置常用答案
-(void)setAnswerSentence:(NSString *)answerSentence{
    self.textAnswer.text=answerSentence;
}

//设置常用问题及问题编号
-(void)setAskSentence:(NSString *)askSentence withAskID:(NSString *)askID{
    self.askID=askID;
    self.textAsk.text=askSentence;    
}

//返回问题编号
-(NSString *)getAskIDDelegate{
    return self.askID;
}


//询问记录改变，保存标识设置为NO
-(void)textViewDidChange:(UITextView *)textView{
    inquireSaved=NO;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"text"]) {
        inquireSaved=NO;
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField.tag==105 || textField.tag==102 || textField.tag==103) {
        return NO;
    } else {
        return YES;
    }
}
-(Citizen *)getCitizen{
    return [Citizen citizenForParty:self.textParty.text case:self.caseID];
}
@end
