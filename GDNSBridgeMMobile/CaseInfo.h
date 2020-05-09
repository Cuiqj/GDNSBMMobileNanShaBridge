//
//  CaseInfo.h
//  GDRMMobile
//
//  Created by yu hongwu on 12-11-14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BaseManageObject.h"


#define GDRM_CASE_TYPE_NAME_ARRAY ([[[AppDelegate App].projectDictionary objectForKey:@"projectname"] isEqualToString:@"xierhuan"] ? @[@"南沙大桥高[赔]", @"南沙大桥高[罚]"] : @[@"中江南高[赔]", @"中江南高[罚]"])

FOUNDATION_EXPORT NSString * const CaseTypeIDPei;// @"11"
FOUNDATION_EXPORT NSString * const CaseTypeIDFa;// @"12"
FOUNDATION_EXPORT NSString * const CaseTypeIDDefault;// @"11"

typedef enum:NSUInteger {
    kGDRMCaseTypeStartIndex = 10,
    kGDRMCaseTypeCompensation,
    kGDRMCaseTypeCriminalPunishment
} kGDRMCaseType;

@interface CaseInfo : BaseManageObject

@property (nonatomic, retain) NSString * badcar_sum;
@property (nonatomic, retain) NSString * badwound_sum;
@property (nonatomic, retain) NSString * case_mark2;
@property (nonatomic, retain) NSString * case_mark3;
@property (nonatomic, retain) NSString * case_reason;
@property (nonatomic, retain) NSString * case_style;
@property (nonatomic, retain) NSString * case_type;
@property (nonatomic, retain) NSString * case_type_id;
@property (nonatomic, retain) NSString * death_sum;
@property (nonatomic, retain) NSString * fleshwound_sum;
@property (nonatomic, retain) NSDate   * happen_date;
@property (nonatomic, retain) NSString * myid;
@property (nonatomic, retain) NSString * organization_id;
@property (nonatomic, retain) NSString * place;
@property (nonatomic, retain) NSString * roadsegment_id;
@property (nonatomic, retain) NSString * side;
@property (nonatomic, retain) NSNumber * station_end;
@property (nonatomic, retain) NSNumber * station_start;
@property (nonatomic, retain) NSString * weater;
@property (nonatomic, retain) NSNumber * isuploaded;
@property (nonatomic, retain) NSString * project_id;

@property (retain,nonatomic) NSString * caseAddressStr;

//读取案号对应的案件信息记录
+(CaseInfo *)caseInfoForID:(NSString *)caseID;

//删除对应案号的信息记录
+ (void)deleteCaseInfoForID:(NSString *)caseID;

//删除无用的空记录
+ (void)deleteEmptyCaseInfo;

//查询相同案号的案件信息
//不同年份的记录应当是不相同的，比如2015年案号是11和2014年的案号是11是允许的
+(NSArray*)caseInfoByCaseMark2:(NSString *)case_mark2 withCaseMark3:(NSString *)case_mark3;

//最大案号
+ (NSInteger)maxCaseMark3;
//最近年份的最大的案号
+ (NSInteger) maxCaseMark3:(NSString *)year;


- (NSString *)station_start_km;
- (NSString *)station_start_m;
- (NSString *)side_short;

- (NSString *)full_case_mark3;
- (NSString *)fullCaseMarkAfterK:(BOOL)isAfterK;
- (NSString *)full_happen_place;
- (NSString *)full_happen_place2;
- (NSString *)happeningPlace;
@end
