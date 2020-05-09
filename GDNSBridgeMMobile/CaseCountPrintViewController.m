//
//  CaseCountPrintViewController.m
//  GuiZhouRMMobile
//
//  Created by yu hongwu on 13-1-4.
//
//

#import "CaseCountPrintViewController.h"
#import "CaseInfo.h"
#import "Citizen.h"
#import "CaseDeformation.h"
#import "CaseProveInfo.h"
#import "NSNumber+NumberConvert.h"
#import "CaseCount.h"

static NSString * const xmlName = @"CaseCountTable";

@interface CaseCountPrintViewController ()
@property (nonatomic, retain) NSMutableArray *data;
@property (nonatomic, retain) Citizen *citizen;
@property (nonatomic, retain) CaseCount *caseCount;
@property (nonatomic,retain) UIPopoverController *pickerPopover;
@end

@implementation CaseCountPrintViewController
@synthesize caseID = _caseID;
@synthesize data = _data;
@synthesize caseCount = _caseCount;
@synthesize citizen = _citizen;

-(void)viewDidLoad{
    [super setCaseID:self.caseID];
    [self LoadPaperSettings:xmlName];
    CGRect viewFrame = CGRectMake(0.0, 0.0, VIEW_SMALL_WIDTH, VIEW_SMALL_HEIGHT);
    self.view.frame = viewFrame;
    if (![self.caseID isEmpty]) {
        [self pageLoadInfo];
    }
    [super viewDidLoad];
    
    [self pageSaveInfo];
    //备注默认为“无”
    if ([self.textRemark.text isEmpty] || self.textRemark.text == nil) {
        self.textRemark.text = @"无";
    }
}

- (void)pageLoadInfo{
    CaseInfo *caseInfo = [CaseInfo caseInfoForID:self.caseID];
    
    if (caseInfo.caseAddressStr.length>0) {
        self.labelCaseAddress.text = caseInfo.caseAddressStr;
    }else
    {
        self.labelCaseAddress.text = caseInfo.full_happen_place;
    }
    
    
    self.labelHappenTime.text = [[AppDelegate getContainingChineseFullDateFormatter] stringFromDate:caseInfo.happen_date];
    
    
    
    //对于多当事人多车辆的情况
    if(self.citizen == nil ){
        //当事人的信息需要生成
        self.citizen = [Citizen citizenForCitizenName:nil nexus:@"当事人" case:self.caseID];
    }
    if (self.citizen) {
        self.textParty.text = self.citizen.party;
        self.labelAutoNumber.text = self.citizen.automobile_number;
        self.labelAutoPattern.text = self.citizen.automobile_pattern;
        self.labelTele.text = self.citizen.tel_number;
        self.labelOrg.text = self.citizen.org_name;
    }
    
    
    self.data = [[CaseDeformation deformationsForCase:self.caseID forCitizen:self.citizen.automobile_number] mutableCopy];
    
    [self reloadDataArray];
    
    CaseCount *caseCount = [CaseCount caseCountForCase:self.caseID forCitizenName:self.citizen.party];
    if(caseCount != nil){
        self.caseCount = caseCount;
        return;
    }
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"CaseCount" inManagedObjectContext:context];
    self.caseCount = [[CaseCount alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    self.caseCount.caseinfo_id = self.caseID;
    self.caseCount.citizen_name = self.citizen.party;
}

- (void)pageSaveInfo{
    self.caseCount.citizen_name = self.textParty.text;
    self.caseCount.sum = [NSNumber numberWithDouble:[[NSString stringWithString:self.labelPayReal.text] doubleValue]];
    self.caseCount.chinese_sum = [[NSNumber numberWithDouble:[self.caseCount.sum doubleValue]] numberConvertToChineseCapitalNumberString];
    self.caseCount.case_count_list = [NSArray arrayWithArray:self.data];
    
    CaseInfo *caseInfo = [CaseInfo caseInfoForID:self.caseID];
    
    caseInfo.caseAddressStr = self.labelCaseAddress.text;
    
}

//根据记录，完整默认值信息
- (void)generateDefaultInfo:(CaseDeformation  *)caseCount{
}

- (NSURL *)toFullPDFWithPath_deprecated:(NSString *)filePath{
    [self pageSaveInfo];
    if (![filePath isEmpty]) {
        CGRect pdfRect=CGRectMake(0.0, 0.0, paperWidth, paperHeight);
        UIGraphicsBeginPDFContextToFile(filePath, CGRectZero, nil);
        UIGraphicsBeginPDFPageWithInfo(pdfRect, nil);
        [self drawStaticTable:xmlName];
        CaseInfo *caseInfo = [CaseInfo caseInfoForID:self.caseID];
        //对于多当事人多车辆的情况
        if(self.citizen == nil ){
            //当事人的信息需要生成
            self.citizen = [Citizen citizenForCitizenName:nil nexus:@"当事人" case:self.caseID];
        }
        [self drawDateTable:xmlName withDataModel:caseInfo];
        [self drawDateTable:xmlName withDataModel:self.citizen];
        [self drawDateTable:xmlName withDataModel:self.caseCount];
        UIGraphicsEndPDFContext();
        return [NSURL fileURLWithPath:filePath];
    } else {
        return nil;
    }
}

- (NSURL *)toFormedPDFWithPath_deprecated:(NSString *)filePath{
    [self pageSaveInfo];
    if (![filePath isEmpty]) {
        CGRect pdfRect=CGRectMake(0.0, 0.0, paperWidth, paperHeight);
        NSString *formatFilePath = [NSString stringWithFormat:@"%@.format.pdf", filePath];
        UIGraphicsBeginPDFContextToFile(formatFilePath, CGRectZero, nil);
        UIGraphicsBeginPDFPageWithInfo(pdfRect, nil);
        CaseInfo *caseInfo = [CaseInfo caseInfoForID:self.caseID];
        //对于多当事人多车辆的情况
        if(self.citizen == nil ){
            //当事人的信息需要生成
            self.citizen = [Citizen citizenForCitizenName:nil nexus:@"当事人" case:self.caseID];
        }
        [self drawDateTable:xmlName withDataModel:caseInfo];
        [self drawDateTable:xmlName withDataModel:self.citizen];
        [self drawDateTable:xmlName withDataModel:self.caseCount];
        UIGraphicsEndPDFContext();
        return [NSURL fileURLWithPath:formatFilePath];
    } else {
        return nil;
    }
}


- (void)viewDidUnload {
    [self setLabelHappenTime:nil];
    [self setLabelCaseAddress:nil];
    [self setLabelTele:nil];
    [self setLabelAutoPattern:nil];
    [self setLabelAutoNumber:nil];
    [self setTableCaseCountDetail:nil];
    [self setTextBigNumber:nil];
    [self setLabelPayReal:nil];
    [self setTextRemark:nil];
    [self setLabelOrg:nil];
    [self setLabelCaseAddress:nil];
	[self setTextParty:nil];
    [super viewDidUnload];
}

-(void)reloadDataArray{
    [self.tableCaseCountDetail reloadData];
    BOOL flag = FALSE;
    for (CaseDeformation *t in self.data) {
        if (t.total_price.doubleValue < 0.0) {
            flag = TRUE;
            break;
        }
    }
    if (flag == TRUE) {
        self.labelPayReal.text = UNDETERMINED;
        self.textBigNumber.text = UNDETERMINED;
        self.textRemark.text = HIGHWAY_PROPERTY_UNDETERMINED;
        return;
    }
    
    self.textRemark.text = @"";
    double summary=[[self.data valueForKeyPath:@"@sum.total_price.doubleValue"] doubleValue];
    self.labelPayReal.text = [NSString stringWithFormat:@"%.2f",summary];
    NSNumber *sumNum = @(summary);
    NSString *numString = [sumNum numberConvertToChineseCapitalNumberString];
    self.textBigNumber.text = numString;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CaseCountDetailCell";
    CaseCountDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    CaseDeformation *caseDeformation = [self.data objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.labelAssetName.text = caseDeformation.roadasset_name;
    //cell.labelAssetSize.text = caseDeformation.rasset_size;
    
    if ([caseDeformation.unit rangeOfString:@"米"].location != NSNotFound) {
        cell.labelQunatity.text=[NSString stringWithFormat:@"%.2f",caseDeformation.quantity.doubleValue];
    } else {
        cell.labelQunatity.text=[NSString stringWithFormat:@"%d",caseDeformation.quantity.integerValue];
    }
    cell.labelAssetUnit.text = caseDeformation.unit;
    if (caseDeformation.price.floatValue < 0.0) {
        cell.labelPrice.text = UNDETERMINED;
        cell.labelTotalPrice.text = UNDETERMINED;
    }else {
        cell.labelPrice.text = [NSString stringWithFormat:@"%.2f元",caseDeformation.price.floatValue];
        cell.labelTotalPrice.text = [NSString stringWithFormat:@"%.2f元",caseDeformation.total_price.floatValue];
    }
    cell.labelRemark.text = caseDeformation.remark;
    return cell;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

//删除
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"toCaseCountDetailEditor" sender:[self.data objectAtIndex:indexPath.row]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toCaseCountDetailEditor"]) {
        CaseCountDetailEditorViewController *ccdeVC = [segue destinationViewController];
        ccdeVC.caseID = self.caseID;
        ccdeVC.countDetail = sender;
        ccdeVC.delegate = self;
    }
}

- (void)generateDefaultAndLoad{
    //[self generateDefaultInfo:self.caseCount];
    [self pageLoadInfo];
}

- (void)deleteCurrentDoc{
}

#pragma mark - CasePrintProtocol
- (NSString *)templateNameKey
{
    return DocNameKeyPei_PeiBuChangQingDan;
}

- (id)dataForPDFTemplate {
    
    id caseData = @{};
    CaseInfo *caseInfo = [CaseInfo caseInfoForID:self.caseID];
    if (caseInfo) {
        caseData = @{
                     @"place": NSStringNilIsBad(self.labelCaseAddress.text),
                     @"date": NSStringFromNSDateAndFormatter(caseInfo.happen_date, NSDateFormatStringCustom1)
                     };
    }
    
    id citizenData = @{};
    //对于多当事人多车辆的情况
    if(self.citizen == nil ){
        //当事人的信息需要生成
        self.citizen = [Citizen citizenForCitizenName:nil nexus:@"当事人" case:self.caseID];
    }
    if (self.citizen) {
        citizenData = @{
                        @"name":NSStringNilIsBad(self.citizen.party),
                        @"car_model":NSStringNilIsBad(self.citizen.automobile_pattern),
                        @"car_number":NSStringNilIsBad(self.citizen.automobile_number),
                        @"org":NSStringNilIsBad(self.citizen.org_name),
                        @"tel":NSStringNilIsBad(self.citizen.tel_number),
                        };
    }
    
    NSInteger emptyItemCnt = 11;
    id itemsData = [@[] mutableCopy];
    if (self.data != nil) {
        int i = 0;
        for (CaseDeformation *caseDeform in self.data) {
            if (i >= 11) {
                break;
            }
            
            id singleItem = @{
                              @"id": @(i+1),
                              @"name": caseDeform.roadasset_name,
                              @"size": caseDeform.rasset_size,
                              @"unit": caseDeform.unit,
                              @"quantity": caseDeform.quantity.doubleValue > caseDeform.quantity.integerValue ?[NSString stringWithFormat:@"%.2f",caseDeform.quantity.doubleValue]:[NSString stringWithFormat:@"%d",caseDeform.quantity.integerValue],
                              @"unit_price": caseDeform.price.doubleValue < 0.0 ? UNDETERMINED:caseDeform.price,
                              @"total_price": caseDeform.total_price.doubleValue < 0.0 ? UNDETERMINED:caseDeform.total_price.doubleValue > caseDeform.total_price.integerValue ?[NSString stringWithFormat:@"%.2f",caseDeform.total_price.doubleValue]:[NSString stringWithFormat:@"%d",caseDeform.total_price.integerValue]
                              };
            [itemsData addObject:singleItem];
            i++;
            emptyItemCnt--;
        }
    }
    /* 若不足11个，用空数据补足 */
    for (int i = 11-emptyItemCnt; i < 11; i++) {
        [itemsData addObject:@{@"id":@(i+1)}];
    }
    
    id moneyData = @{};
    if (self.data != nil && self.caseCount != nil) {
        
        NSString *chinese_sum_w = @"";
        NSString *chinese_sum_q = @"";
        NSString *chinese_sum_b = @"";
        NSString *chinese_sum_s = @"";
        NSString *chinese_sum_y = @"";
        NSString *chinese_sum_j = @"";
        NSString *chinese_sum_f = @"";
        
        if (![self.labelPayReal.text isEqualToString:UNDETERMINED]) {
            chinese_sum_w = self.caseCount.chinese_sum_w;
            chinese_sum_q = self.caseCount.chinese_sum_q;
            chinese_sum_b = self.caseCount.chinese_sum_b;
            chinese_sum_s = self.caseCount.chinese_sum_s;
            chinese_sum_y = self.caseCount.chinese_sum_y;
            chinese_sum_j = self.caseCount.chinese_sum_j;
            chinese_sum_f = self.caseCount.chinese_sum_f;
            
        }
        moneyData = @{
                      @"wan" : chinese_sum_w,
                      @"qian" : chinese_sum_q,
                      @"bai" : chinese_sum_b,
                      @"shi" : chinese_sum_s,
                      @"yuan" : chinese_sum_y,
                      @"jiao" : chinese_sum_j,
                      @"fen" : chinese_sum_f,
                      @"xiaoxie": [NSString stringWithFormat:@"￥%@",self.labelPayReal.text]
                      };
    }
    
    id commentData = @"";
    if (![self.textRemark.text isEmpty]) {
        commentData = self.textRemark.text;
    }
    id data = @{
                @"citizen":citizenData,
                @"case": caseData,
                @"items":itemsData,
                @"money":moneyData,
                @"comment":commentData
                };
    return data;
}
- (IBAction)selectParty:(UITextField*)sender {
    if ([self.pickerPopover isPopoverVisible]) {
        [self.pickerPopover dismissPopoverAnimated:YES];
    } else {
        PartyPickerViewController *icPicker=[[PartyPickerViewController alloc] initWithStyle:UITableViewStylePlain caseId:self.caseID];
        icPicker.tableView.frame=CGRectMake(0, 0, 150, 243);
        icPicker.delegate=self;
        self.pickerPopover=[[UIPopoverController alloc] initWithContentViewController:icPicker];
        [self.pickerPopover setPopoverContentSize:CGSizeMake(150, 243)];
        [self.pickerPopover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        icPicker.pickerPopover=self.pickerPopover;
    }
}
- (void)setParty:(Citizen *)citizen{
    self.citizen = citizen;
    [self pageLoadInfo];
}

@end
