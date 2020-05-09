//
//  CaseMapPrinterViewController.m
//  GDRMMobile
//
//  Created by yu hongwu on 12-11-29.
//
//

#import "CaseMapPrinterViewController.h"
#import "CaseMap.h"
#import "CaseInfo.h"
#import "CaseProveInfo.h"
#import "Citizen.h"
#import "DateSelectController.h"

@interface CaseMapPrinterViewController ()

@end

@implementation CaseMapPrinterViewController
@synthesize labelTime = _labelTime;
@synthesize labelLocality = _labelLocality;
@synthesize labelCitizen = _labelCitizen;
@synthesize labelWeather = _labelWeather;
@synthesize labelRoadType = _labelRoadType;
@synthesize textViewRemark = _textViewRemark;
@synthesize labelDraftMan = _labelDraftMan;
@synthesize labelDraftTime = _labelDraftTime;
@synthesize mapImage = _mapImage;
@synthesize caseID = _caseID;

- (void)viewDidLoad
{
    [super setCaseID:self.caseID];
    [self LoadPaperSettings:@"CaseMapTable"];
    [self loadPageInfo];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setLabelTime:nil];
    [self setLabelLocality:nil];
    [self setLabelCitizen:nil];
    [self setLabelWeather:nil];
    [self setLabelRoadType:nil];
    [self setTextViewRemark:nil];
    [self setLabelDraftMan:nil];
    [self setLabelDraftTime:nil];
    [self setMapImage:nil];
    [self setLabelEventReason:nil];
    [self setLabelCaseMark:nil];
    [self setLabelTime:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)loadPageInfo{
    CaseMap *caseMap = [CaseMap caseMapForCase:self.caseID];
    if (caseMap) {
        self.labelRoadType.text = caseMap.road_type;
        self.textViewRemark.text = caseMap.remark;
        self.labelDraftMan.text = caseMap.draftsman_name;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setDateFormat:@"yyyy年MM月dd日HH时mm分"];
        self.labelDraftTime.text = [dateFormatter stringFromDate:caseMap.draw_time];
        NSArray *pathArray=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath=[pathArray objectAtIndex:0];
        NSString *mapPath=[NSString stringWithFormat:@"CaseMap/%@",self.caseID];
        mapPath=[documentPath stringByAppendingPathComponent:mapPath];
        NSString *mapName = @"casemap.jpg";
        NSString *filePath=[mapPath stringByAppendingPathComponent:mapName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            UIImage *imageFile = [[UIImage alloc] initWithContentsOfFile:filePath];
            self.mapImage.image = imageFile;
        }
        CaseInfo *caseInfo = [CaseInfo caseInfoForID:self.caseID];
        self.labelTime.text = [dateFormatter stringFromDate:caseMap.draw_time];
        self.labelTime.delegate = self;
        self.labelTime.tag = 101;
//        NSString *locality = [[NSString alloc] initWithFormat:@"西二环南段%@%dKm+%03dm",caseInfo.side,caseInfo.station_start.integerValue/1000,caseInfo.station_start.integerValue%1000];
//        self.labelLocality.text = locality;
        self.labelLocality.text = caseInfo.full_happen_place;
        self.labelEventReason.text = [[CaseProveInfo proveInfoForCase:self.caseID] case_short_desc];
        
        self.labelCaseMark.text = [NSString stringWithFormat:@"%@年%@号", caseInfo.case_mark2, caseInfo.full_case_mark3];
        self.labelWeather.text = caseInfo.weater;
        CaseProveInfo *caseProveInfo = [CaseProveInfo proveInfoForCase:self.caseID];
        if (caseProveInfo) {
            self.labelProver.text = caseProveInfo.prover;
        }
        Citizen *citizen = [Citizen citizenForCitizenName:caseProveInfo.citizen_name nexus:@"当事人" case:self.caseID];
        self.labelCitizen.text = citizen.automobile_number;
    }
}

- (IBAction)textFieldDateAndTimeTap:(id)sender {
    
    [self performSegueWithIdentifier:@"toDateAndTimePicker" sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSString *segueIdentifier= [segue identifier];
    if ([segueIdentifier isEqualToString:@"toDateAndTimePicker"]) {
        DateSelectController *dsVC=segue.destinationViewController;
        dsVC.dateselectPopover=[(UIStoryboardPopoverSegue *) segue popoverController];
        dsVC.delegate=self;
        dsVC.pickerType=1;
        dsVC.textFieldTag = self.labelTime.tag;
        dsVC.datePicker.maximumDate=[NSDate date];
        CaseMap *caseMap = [CaseMap caseMapForCase:self.caseID];
        [dsVC showPastDate:caseMap.draw_time];
    }
}

- (void)setPastDate:(NSDate *)date withTag:(int)tag
{
    CaseMap *caseMap = [CaseMap caseMapForCase:self.caseID];
    caseMap.draw_time = date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日HH时mm分"];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    self.labelTime.text = [dateFormatter stringFromDate:caseMap.draw_time];
}



- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return NO;
}


- (void)pageSaveInfo
{
    CaseMap *caseMap = [CaseMap caseMapForCase:self.caseID];
    caseMap.remark = self.textViewRemark.text;
    
    [[AppDelegate App] saveContext];
}

- (NSURL *)toFullPDFWithPath_deprecated:(NSString *)filePath{
    if (![filePath isEmpty]) {
        CGRect pdfRect=CGRectMake(0.0, 0.0, paperWidth, paperHeight);
        UIGraphicsBeginPDFContextToFile(filePath, CGRectZero, nil);
        UIGraphicsBeginPDFPageWithInfo(pdfRect, nil);
        [self drawStaticTable:@"CaseMapTable"];
        CaseMap *caseMap = [CaseMap caseMapForCase:self.caseID];
        [self drawDateTable:@"CaseMapTable" withDataModel:caseMap];
        CaseInfo *caseInfo = [CaseInfo caseInfoForID:self.caseID];
        [self drawDateTable:@"CaseMapTable" withDataModel:caseInfo];
        CaseProveInfo *caseProveInfo = [CaseProveInfo proveInfoForCase:self.caseID];
        [self drawDateTable:@"CaseMapTable" withDataModel:caseProveInfo];
        Citizen *citizen = [Citizen citizenForCitizenName:caseProveInfo.citizen_name nexus:@"当事人" case:self.caseID];
        [self drawDateTable:@"CaseMapTable" withDataModel:citizen];
        
        UIGraphicsEndPDFContext();
        return [NSURL fileURLWithPath:filePath];
    } else {
        return nil;
    }
}

-(NSURL *)toFormedPDFWithPath_deprecated:(NSString *)filePath{
    if (![filePath isEmpty]) {
        NSString *formatFilePath = [NSString stringWithFormat:@"%@.format.pdf", filePath];
        CGRect pdfRect=CGRectMake(0.0, 0.0, paperWidth, paperHeight);
        UIGraphicsBeginPDFContextToFile(formatFilePath, CGRectZero, nil);
        UIGraphicsBeginPDFPageWithInfo(pdfRect, nil);
        CaseMap *caseMap = [CaseMap caseMapForCase:self.caseID];
        [self drawDateTable:@"CaseMapTable" withDataModel:caseMap];
        CaseInfo *caseInfo = [CaseInfo caseInfoForID:self.caseID];
        [self drawDateTable:@"CaseMapTable" withDataModel:caseInfo];
        CaseProveInfo *caseProveInfo = [CaseProveInfo proveInfoForCase:self.caseID];
        [self drawDateTable:@"CaseMapTable" withDataModel:caseProveInfo];
        Citizen *citizen = [Citizen citizenForCitizenName:caseProveInfo.citizen_name nexus:@"当事人" case:self.caseID];
        [self drawDateTable:@"CaseMapTable" withDataModel:citizen];
        
        UIGraphicsEndPDFContext();
        return [NSURL fileURLWithPath:formatFilePath];
    } else {
        return nil;
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return YES;
}

#pragma mark - CasePrintProtocol

- (NSString *)templateNameKey
{
    return DocNameKeyPei_LuZhengAnJianXianChangKanYanTu;
}

- (id)dataForPDFTemplate
{
    NSString *caseNo = @"";
    id dateData = @{};
    NSString *place = @"";
    NSString *eventReason = @"";
    NSString *comment = @"";
    NSString *draftsman = @"";
    NSString *inquestman = @"";
    NSString *imagePath = @"";
    CaseInfo *caseInfo = [CaseInfo caseInfoForID:self.caseID];
    if (caseInfo) {
        caseNo = [NSString stringWithFormat:@"%@年%@号",caseInfo.case_mark2,caseInfo.full_case_mark3];
        CaseMap *caseMap = [CaseMap caseMapForCase:self.caseID];
        
        NSString *dateString = NSStringFromNSDateAndFormatter(caseMap.draw_time, NSDateFormatStringCustom1);
        dateData = DateDataFromDateString(dateString);
        dateData = (dateData == nil ? @{} : dateData);
        place = NSStringNilIsBad(caseInfo.full_happen_place);
        CaseProveInfo *proveInfo = [CaseProveInfo proveInfoForCase:self.caseID];
        if (proveInfo) {
            eventReason = NSStringNilIsBad(proveInfo.case_short_desc);
            inquestman = NSStringNilIsBad(proveInfo.prover);
        }
        
        
        if (caseMap) {
            comment = NSStringNilIsBad(caseMap.remark);
            draftsman = NSStringNilIsBad(caseMap.draftsman_name);
            imagePath = caseMap.map_file;
        }
        
    }
    return @{
             @"caseNo": caseNo,
             @"date": dateData,
             @"place": place,
             @"eventReason": eventReason,
             @"comment": comment,
             @"draftsman": draftsman,
             @"inquestman": inquestman,
             @"imagePath": imagePath,
             };
}


@end
