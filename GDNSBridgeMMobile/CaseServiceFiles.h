//
//  CaseServiceFiles.h
//  GDRMMobile
//
//  Created by yu hongwu on 12-11-15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BaseManageObject.h"

@interface CaseServiceFiles : BaseManageObject

@property (nonatomic, retain) NSString * receipt_date;
@property (nonatomic, retain) NSString * receipter_name;
@property (nonatomic, retain) NSString * service_file;
@property (nonatomic, retain) NSString * servicereceipt_id;
@property (nonatomic, retain) NSString * servicer_name;
@property (nonatomic, retain) NSString * myid;
@property (nonatomic, retain) NSString * remark;
@property (nonatomic, retain) NSNumber * isuploaded;

+ (NSArray *)caseServiceFilesForCase:(NSString *)caseID;
+ (NSArray *)caseServiceFilesForCaseServiceReceipt:(NSString *)receiptID;
+ (CaseServiceFiles *)newCaseServiceFilesForCaseServiceReceipt:(NSString *)receiptID;
+ (NSArray *)addDefaultCaseServiceFilesForCase:(NSString *)caseID  forCaseServiceReceipt:(NSString *)receiptID;

@end
