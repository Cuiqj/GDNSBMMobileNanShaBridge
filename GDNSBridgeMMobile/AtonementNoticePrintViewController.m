//
//  AtonementNoticePrintViewController.m
//  GDRMMobile
//
//  Created by yu hongwu on 12-11-29.
//
//

#import "AtonementNoticePrintViewController.h"
#import "AtonementNotice.h"
#import "CaseDeformation.h"
#import "CaseProveInfo.h"
#import "Citizen.h"
#import "CaseInfo.h"
#import "RoadSegment.h"
#import "OrgInfo.h"
#import "UserInfo.h"
#import "NSNumber+NumberConvert.h"
#import "Systype.h"
#import "MatchLaw.h"
#import "MatchLawDetails.h"
#import "LawItems.h"
#import "LawbreakingAction.h"
#import "Laws.h"
#import "PartyPickerViewController.h"
#import "AppConstant.h"
@interface AtonementNoticePrintViewController ()
@property (nonatomic,retain) AtonementNotice *notice;
@property(nonatomic,retain)UIPopoverController *partyPickerpopover;
- (void)generateDefaultsForNotice:(AtonementNotice *)notice;
-(double)calculateSum;
@end

@implementation AtonementNoticePrintViewController
@synthesize labelCaseCode = _labelCaseCode;
@synthesize textParty = _textParty;
@synthesize textPartyAddress = _textPartyAddress;
@synthesize textCaseReason = _textCaseReason;
@synthesize textOrg = _textOrg;
@synthesize textViewCaseDesc = _textViewCaseDesc;
@synthesize textWitness = _textWitness;
@synthesize textViewPayReason = _textViewPayReason;
@synthesize textPayMode = _textPayMode;
@synthesize textCheckOrg = _textCheckOrg;
@synthesize labelDateSend = _labelDateSend;
@synthesize textBankName = _textBankName;
@synthesize caseID = _caseID;
@synthesize notice = _notice;

- (void)viewDidLoad
{
    [super setCaseID:self.caseID];
    [self LoadPaperSettings:@"AtonementNoticeTable"];
    /*modify by lxm 不能实时更新*/
    [self.view setFrame:CGRectMake(0, 0, 500, 1200)];
    if (![self.caseID isEmpty]) {
        NSArray *noticeArray = [AtonementNotice AtonementNoticesForCase:self.caseID];
        if (noticeArray.count>0) {
            self.notice = [noticeArray objectAtIndex:0];
        } else {
            self.notice = [AtonementNotice newDataObjectWithEntityName:@"AtonementNotice"];
            self.notice.caseinfo_id = self.caseID;
            NSArray *citizens = [Citizen citizenForCitizenName:@"当事人" case:self.caseID];
            if ([citizens count]>0) {
                self.notice.citizen_name = ((Citizen*)[citizens objectAtIndex:0 ]).automobile_number;
            }
            [self generateDefaultsForNotice:self.notice];
            [[AppDelegate App] saveContext];
        }
//        [self generateDefaultsForNotice:self.notice];
        [self loadPageInfo];
    }
    [super viewDidLoad];


    //  [self generateDefaultAndLoad];
    [self pageSaveInfo];

}

- (void)viewDidUnload
{
    [self setLabelCaseCode:nil];
    [self setTextParty:nil];
    [self setTextPartyAddress:nil];
    [self setTextCaseReason:nil];
    [self setTextOrg:nil];
    [self setTextViewCaseDesc:nil];
    [self setTextWitness:nil];
    [self setTextViewPayReason:nil];
    [self setTextPayMode:nil];
    [self setTextCheckOrg:nil];
    [self setLabelDateSend:nil];
    [self setNotice:nil];
	[self setTextBankName:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)loadPageInfo{
    CaseInfo *caseInfo = [CaseInfo caseInfoForID:self.caseID];
    Citizen *citizen = [Citizen citizenByCitizenName:self.notice.citizen_name nexus:@"当事人" case:self.caseID];
    CaseProveInfo *proveInfo = [CaseProveInfo proveInfoForCase:self.caseID citizenName:citizen.automobile_number];
    self.labelCaseCode.text = [[NSString alloc] initWithFormat:@"(%@)年%@交赔字第%@号",caseInfo.case_mark2, [[AppDelegate App].projectDictionary objectForKey:@"cityname"], caseInfo.full_case_mark3];
    
    NSLog(@"%@ -------  %@",caseInfo,citizen);
    self.textParty.text = citizen.party;
    self.textPartyAddress.text = citizen.address;
    self.textCaseReason.text = proveInfo.case_short_desc;
    

    self.textOrg.text = self.notice.organization_id;
    
    
    NSString * temp1 = NSStringNilIsBad(self.notice.case_desc);
    NSString *replaceString = @"损坏路产详见赔（补）偿清单。";
    // 经测试，字符串长处大概超过160时，将打印不下
    NSRange rang = [temp1 rangeOfString:replaceString];
    
    if (rang.length>0) {
        self.textViewCaseDesc.text = temp1;
    }else
    {
        NSRange subRange = [temp1 rangeOfString:@"经与当事人现场勘查，"];
        if (NSNotFound != subRange.location){
            self.textViewCaseDesc.text = [[temp1 substringToIndex:subRange.location+subRange.length ] stringByAppendingString:replaceString];
        }
        else{
            self.textViewCaseDesc.text = temp1;
        }
    }
    
    
    self.textViewPayReason.text = self.notice.pay_reason;
    
//    NSArray *temp=[Citizen allCitizenNameForCase:self.caseID];
//    NSArray *citizenList=[[temp valueForKey:@"automobile_number"] mutableCopy];
    
    double summary = 0.0;
    BOOL flag = FALSE;
//    if (citizenList.count > 0) {
        NSArray *deformations = [CaseDeformation deformationsForCase:self.caseID forCitizen:citizen.automobile_number];
        for (CaseDeformation *t in deformations) {
            if (t.total_price.doubleValue < 0.0) {
                flag = TRUE;
                break;
            }
        }
        summary=[[deformations valueForKeyPath:@"@sum.total_price.doubleValue"] doubleValue];
//    }
    NSNumber *sumNum = @(summary);
    if(summary > 10000){
        self.textWitness.text = @"现场照片、勘验检查笔录、询问笔录、现场堪验图";
    }else{
        self.textWitness.text = @"现场照片、勘验检查笔录、询问笔录";
    }
    
    if(self.notice.pay_mode != nil && ![self.notice.pay_mode isEmpty]){
        self.textPayMode.text = self.notice.pay_mode;
    }else{
        if (flag == TRUE) {
            self.textPayMode.text = HIGHWAY_PROPERTY_UNDETERMINED;
        }else{
            NSString *numString = [sumNum numberConvertToChineseCapitalNumberString];
            self.textPayMode.text = [NSString stringWithFormat:@"路产损失费人民币%@（￥%.2f元）",numString,summary];
        }
    }
    self.textBankName.text = [[Systype typeValueForCodeName:@"交款地点"] count]? [[Systype typeValueForCodeName:@"交款地点"] objectAtIndex:0]:@"请配置交款地点";
    self.textCheckOrg.text = self.notice.check_organization;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyy     年      MM      月      dd      日"];
    self.labelDateSend.text = [dateFormatter stringFromDate:self.notice.date_send];
}

//我写的保存
- (void)pageSaveInfo{
    [self savePageInfo];
}
- (void)savePageInfo{
    self.notice.organization_id = self.textOrg.text;
    self.notice.case_desc = self.textViewCaseDesc.text;
    self.notice.pay_mode = self.textPayMode.text;
    self.notice.pay_reason = self.textViewPayReason.text;
    self.notice.check_organization = self.textCheckOrg.text;
    self.notice.witness = self.textWitness.text;
    [[AppDelegate App] saveContext];
}

- (void)generateDefaultAndLoad{
    [self generateDefaultsForNotice:self.notice];
    [self loadPageInfo];
}

- (void)generateDefaultsForNotice:(AtonementNotice *)notice{
    CaseProveInfo *proveInfo = [CaseProveInfo proveInfoForCase:self.caseID citizenName:self.notice.citizen_name];

    Citizen *citizen = [Citizen citizenByCitizenName:notice.citizen_name nexus:@"当事人" case:self.caseID];
    notice.case_desc = [AtonementNotice generateEventDescForCase:self.caseID citizen:citizen];
    

    if([self calculateSum] > 10000){
        notice.witness = @"现场照片、勘验检查笔录、询问笔录、现场堪验图";
    }else{
        notice.witness = @"现场照片、勘验检查笔录、询问笔录";
    }
    NSString *currentUserID=[[NSUserDefaults standardUserDefaults] stringForKey:USERKEY];
    NSString * Orgname = [[OrgInfo orgInfoForOrgID:[UserInfo userInfoForUserID:currentUserID].organization_id] valueForKey:@"orgname"];
    notice.organization_id = Orgname;
    notice.check_organization = [[Systype typeValueForCodeName:@"复核单位"] objectAtIndex:0];

    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MatchLaw" ofType:@"plist"];
    NSDictionary *matchLaws = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSString *payReason = @"";
    if (matchLaws) {
        NSString *breakStr = @"";
        NSString *matchStr = @"";
        NSString *payStr = @"";
        
        
        NSMutableArray *breakArray = [[NSMutableArray alloc]init];
        NSMutableArray *matchArray = [[NSMutableArray alloc]init];
        NSMutableArray *payArray = [[NSMutableArray alloc]init];
        for(NSString *case_desc_id in [proveInfo.case_desc_id componentsSeparatedByString:@"#"]){
            NSDictionary *matchInfo = [[matchLaws objectForKey:@"case_desc_match_law"] objectForKey:case_desc_id];
            if (matchInfo) {
                if ([matchInfo objectForKey:@"breakLaw"]) {
                    NSArray *tempArray = (NSArray *)[matchInfo objectForKey:@"breakLaw"] ;
                    if([breakArray count] > 0){
                        for(NSString *temp in tempArray){
                            BOOL flag = FALSE;
                            for(NSString *temp2 in breakArray){
                                if([temp isEqual:temp2]){
                                    flag = TRUE;
                                }
                            }
                            if(!flag){
                                [breakArray addObject:temp];
                            }
                        }
                    }else{
                        breakArray = [[NSMutableArray alloc]initWithArray:tempArray];
                    }
                    
                }
                if ([matchInfo objectForKey:@"matchLaw"]) {
                    NSArray *tempArray = (NSArray *)[matchInfo objectForKey:@"matchLaw"] ;
                    if([matchArray count] > 0){
                        for(NSString *temp in tempArray){
                            BOOL flag = FALSE;
                            for(NSString *temp2 in matchArray){
                                if([temp isEqual:temp2]){
                                    flag = TRUE;
                                }
                            }
                            if(!flag){
                                [matchArray addObject:temp];
                            }
                        }
                    }else{
                        matchArray = [[NSMutableArray alloc]initWithArray:tempArray];
                    }
                }
                if ([matchInfo objectForKey:@"payLaw"]) {
                    NSArray *tempArray = (NSArray *)[matchInfo objectForKey:@"payLaw"] ;
                    if([payArray count] > 0){
                        for(NSString *temp in tempArray){
                            BOOL flag = FALSE;
                            for(NSString *temp2 in payArray){
                                if([temp isEqual:temp2]){
                                    flag = TRUE;
                                }
                            }
                            if(!flag){
                                [payArray addObject:temp];
                            }
                        }
                    }else{
                        payArray = [[NSMutableArray alloc]initWithArray:tempArray];
                    }
                }
            }
        }
        
        //由于目前违反的法律只有两条，所以这里就不想进行太复杂的处理的
        if([breakArray count] > 2){
            breakStr = BREAK_TWO_RULES;
        }else{
            breakStr = [breakStr stringByAppendingString:[breakArray componentsJoinedByString:@"、"]];
        }
        
        
        matchStr = [matchStr stringByAppendingString:[matchArray componentsJoinedByString:@"、"]];
        payStr = [payStr stringByAppendingString:[payArray componentsJoinedByString:@"、"]];
        //payReason = [NSString stringWithFormat:@"%@损坏路产的事实清楚，根据%@、并依照%@的规定，当事人应当依法承担民事责任，赔偿路产损失。", citizen.party,  matchStr, payStr];
        payReason = [NSString stringWithFormat:@"%@、%@、%@",   matchStr,breakStr, payStr];

        
    }
    notice.pay_reason = payReason;
    //    NSArray *deformations = [CaseDeformation deformationsForCase:self.caseID forCitizen:notice.citizen_name];
    //    double summary=[[deformations valueForKeyPath:@"@sum.total_price.doubleValue"] doubleValue];
    //    NSNumber *sumNum = @(summary);
    //    NSString *numString = [sumNum numberConvertToChineseCapitalNumberString];
    //    notice.pay_mode = [NSString stringWithFormat:@"路产损失费人民币%@（￥%.2f元）",numString,summary];
    self.notice.pay_mode = nil;
    notice.date_send = [NSDate date];
    self.notice = notice;
    [[AppDelegate App] saveContext];
}

/*test by lxm 无效*/
-(NSURL *)toFullPDFWithTable:(NSString *)filePath{
    [self savePageInfo];
    if (![filePath isEmpty]) {
        CGRect pdfRect=CGRectMake(0.0, 0.0, paperWidth, paperHeight);
        UIGraphicsBeginPDFContextToFile(filePath, CGRectZero, nil);
        UIGraphicsBeginPDFPageWithInfo(pdfRect, nil);
        [self drawStaticTable:@"AtonementNoticeTable"];
        [self drawDateTable:@"AtonementNoticeTable" withDataModel:self.notice];
        
        //add by lxm 2013.05.08
        CaseInfo *caseInfo = [CaseInfo caseInfoForID:self.caseID];
        self.labelCaseCode.text = [[NSString alloc] initWithFormat:@"(%@)年%@交赔字第%@号",caseInfo.case_mark2, [[AppDelegate App].projectDictionary objectForKey:@"cityname"], caseInfo.full_case_mark3];
        Citizen *citizen = [Citizen citizenForCitizenName:self.notice.citizen_name nexus:@"当事人" case:self.caseID];
        [self drawDateTable:@"AtonementNoticeTable" withDataModel:citizen];
        
        CaseProveInfo *proveInfo = [CaseProveInfo proveInfoForCase:self.caseID citizenName:self.notice.citizen_name];
        [self drawDateTable:@"AtonementNoticeTable" withDataModel:proveInfo];
        
        
        UIGraphicsEndPDFContext();
        return [NSURL fileURLWithPath:filePath];
    } else {
        return nil;
    }
}

-(NSURL *)toFullPDFWithPath_deprecated:(NSString *)filePath{
    [self savePageInfo];
    if (![filePath isEmpty]) {
        CGRect pdfRect=CGRectMake(0.0, 0.0, paperWidth, paperHeight);
        UIGraphicsBeginPDFContextToFile(filePath, CGRectZero, nil);
        UIGraphicsBeginPDFPageWithInfo(pdfRect, nil);
        [self drawStaticTable1:@"AtonementNoticeTable"];
        [self drawDateTable:@"AtonementNoticeTable" withDataModel:self.notice];
        
        //add by lxm 2013.05.08
        CaseInfo *caseInfo = [CaseInfo caseInfoForID:self.caseID];
        [self drawDateTable:@"AtonementNoticeTable" withDataModel:caseInfo];
        
        Citizen *citizen = [Citizen citizenForCitizenName:self.notice.citizen_name nexus:@"当事人" case:self.caseID];
        [self drawDateTable:@"AtonementNoticeTable" withDataModel:citizen];
        
        CaseProveInfo *proveInfo = [CaseProveInfo proveInfoForCase:self.caseID citizenName:self.notice.citizen_name];
        [self drawDateTable:@"AtonementNoticeTable" withDataModel:proveInfo];
        
        UIGraphicsEndPDFContext();
        return [NSURL fileURLWithPath:filePath];
    } else {
        return nil;
    }
}

-(NSURL *)toFormedPDFWithPath_deprecated:(NSString *)filePath{
    [self savePageInfo];
    if (![filePath isEmpty]) {
        CGRect pdfRect=CGRectMake(0.0, 0.0, paperWidth, paperHeight);
        NSString *formatFilePath = [NSString stringWithFormat:@"%@.format.pdf", filePath];
        UIGraphicsBeginPDFContextToFile(formatFilePath, CGRectZero, nil);
        UIGraphicsBeginPDFPageWithInfo(pdfRect, nil);
        [self drawDateTable:@"AtonementNoticeTable" withDataModel:self.notice];
        
        //add by lxm 2013.05.08
        CaseInfo *caseInfo = [CaseInfo caseInfoForID:self.caseID];
        [self drawDateTable:@"AtonementNoticeTable" withDataModel:caseInfo];
        
        Citizen *citizen = [Citizen citizenForCitizenName:self.notice.citizen_name nexus:@"当事人" case:self.caseID];
        [self drawDateTable:@"AtonementNoticeTable" withDataModel:citizen];
        
        CaseProveInfo *proveInfo = [CaseProveInfo proveInfoForCase:self.caseID citizenName:self.notice.citizen_name];
        [self drawDateTable:@"AtonementNoticeTable" withDataModel:proveInfo];
        
        UIGraphicsEndPDFContext();
        return [NSURL fileURLWithPath:formatFilePath];
    } else {
        return nil;
    }
}

#pragma CasePrintProtocol
- (NSString *)templateNameKey
{
    return DocNameKeyPei_PeiBuChangTongZhiShu;
}

- (id)dataForPDFTemplate
{
    id data = @{};
    CaseInfo *caseInfo = [CaseInfo caseInfoForID:self.caseID];
    if (caseInfo) {
        NSString *caseMark2 = caseInfo.case_mark2;
        NSString *caseMark3 = caseInfo.full_case_mark3;
        NSString *casePrefix = [[AppDelegate App].projectDictionary objectForKey:@"cityname"];
        NSString *casePrefix1 = [casePrefix substringToIndex:3];
        NSString *casePrefix2 = [casePrefix substringFromIndex:3];
        NSString *partyName = @"";
        NSString *partyAddress = @"";
        NSString *caseReason = @"";
        NSString *agency = @"";
        NSString *caseDescription = @"";
        NSString *caseEvidence = @"";
        NSString *payReason = @"";
        NSString *payDetail = @"";
        NSString *paymentPlace = @"";
        NSString *reviewOrgan = @"";
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *strDate = [dateFormatter stringFromDate:caseInfo.happen_date];
        
        NSArray * tempArr = [[NSArray alloc]initWithArray:[[strDate substringToIndex:10] componentsSeparatedByString:@"-"]];
        
        NSString *year = [tempArr objectAtIndex:0];
        
        NSString *month = [tempArr objectAtIndex:1];
        
        NSString *day = [tempArr objectAtIndex:2];
        

        AtonementNotice *notice =  self.notice;
        agency = NSStringNilIsBad(notice.organization_info);
            
        caseDescription = NSStringNilIsBad(self.textViewCaseDesc.text);
        NSArray *ttt=[notice.case_desc componentsSeparatedByString:@"分"];
            
        caseEvidence = NSStringNilIsBad(notice.witness);
        if(ttt.count>1)
         caseDescription = [ttt objectAtIndex:1];
        payReason = NSStringNilIsBad(notice.pay_reason);
        NSArray *paymentPlaces = [Systype typeValueForCodeName:@"交款地点"];
        if (paymentPlaces.count > 0) {
            paymentPlace = [paymentPlaces objectAtIndex:0];
        }else{
            paymentPlace = @"请配置交款地点";
        }
        reviewOrgan = NSStringNilIsBad(notice.check_organization);
        
        Citizen *citizen = [Citizen citizenByCitizenName:self.notice.citizen_name nexus:@"当事人" case:self.caseID];
        if (citizen) {
            partyName = NSStringNilIsBad(citizen.party);
            partyAddress = NSStringNilIsBad(citizen.address);
            
            NSArray *payments = [CaseDeformation deformationsForCase:self.caseID forCitizen:citizen.automobile_number];
            BOOL flag = FALSE;
            for (CaseDeformation *t in payments) {
                if (t.total_price.doubleValue < 0.0) {
                    flag = TRUE;
                    break;
                }
            }
            if (flag == TRUE) {
                payDetail = HIGHWAY_PROPERTY_UNDETERMINED;
            }else {
                NSNumber *paymentAll = [payments valueForKeyPath:@"@sum.total_price.doubleValue"];
                NSString *paymentString = [paymentAll numberConvertToChineseCapitalNumberString];
                payDetail = [NSString stringWithFormat:@"路产损失费人民币%@（￥%.2f元）", paymentString, paymentAll.doubleValue];
            }
        }
            
        
        
        CaseProveInfo *proveInfo = [CaseProveInfo proveInfoForCase:self.caseID citizenName:self.notice.citizen_name];
        if (proveInfo) {
            caseReason = proveInfo.case_short_desc;
        }
        data = @{
                 @"caseMark2": caseMark2,
                 @"caseMark3": caseMark3,
                 @"casePrefix":casePrefix,
                 @"casePrefix1": casePrefix1,
                 @"casePrefix2": casePrefix2,
                 @"partyName": partyName,
                 @"partyAddress": partyAddress,
                 @"caseReason": caseReason,
                 @"agencyCity": agency,
                 @"notCityOrTown": @(YES),
                 @"agency": @"",
                 @"caseDescription": caseDescription,
                 @"caseEvidence": caseEvidence,
                 @"payReason": payReason,
                 @"payDetail": payDetail,
                 @"paymentPlace": paymentPlace,
                 @"reviewOrgan": reviewOrgan,
                 @"year": year,
                 @"month": month,
                 @"day":day
                 };
    }
    
    return data;
}
-(double)calculateSum{
    NSArray *temp=[Citizen allCitizenNameForCase:self.caseID];
    NSArray *citizenList=[[temp valueForKey:@"automobile_number"] mutableCopy];
    
    double summary = 0.0;
    if (citizenList.count > 0) {
        NSArray *deformations = [CaseDeformation deformationsForCase:self.caseID forCitizen:[citizenList objectAtIndex:0]];
        summary=[[deformations valueForKeyPath:@"@sum.total_price.doubleValue"] doubleValue];
    }
    return summary;
}

- (IBAction)selectParty:(UITextField*)sender {
    if ([self.partyPickerpopover isPopoverVisible]) {
        [self.partyPickerpopover dismissPopoverAnimated:YES];
    } else {
        PartyPickerViewController *icPicker=[[PartyPickerViewController alloc] initWithStyle:UITableViewStylePlain caseId:self.caseID];
        icPicker.tableView.frame=CGRectMake(0, 0, 150, 243);
        icPicker.delegate=self;
        self.partyPickerpopover=[[UIPopoverController alloc] initWithContentViewController:icPicker];
        [self.partyPickerpopover setPopoverContentSize:CGSizeMake(150, 243)];
        [self.partyPickerpopover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        icPicker.pickerPopover=self.partyPickerpopover;
    }
}
- (void)setParty:(Citizen *)citizen{
    self.textParty.text = citizen.party;
    NSArray *noticeArray = [AtonementNotice AtonementNoticesForCase:self.caseID citizenName:citizen.automobile_number];
    if (noticeArray.count>0) {
        self.notice = [noticeArray objectAtIndex:0];
    } else {
        self.notice = [AtonementNotice newDataObjectWithEntityName:@"AtonementNotice"];
        self.notice.caseinfo_id = self.caseID;
        self.notice.citizen_name = citizen.automobile_number;
        [self generateDefaultsForNotice:self.notice];
        [[AppDelegate App] saveContext];
    }
    [self loadPageInfo];
}
@end
