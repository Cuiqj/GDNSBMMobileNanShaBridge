//
//  CaseProveInfo.m
//  GDRMMobile
//
//  Created by yu hongwu on 12-11-29.
//
//

#import "CaseProveInfo.h"
#import "CaseInfo.h"
#import "RoadSegment.h"
#import "Citizen.h"
#import "CaseDeformation.h"
#import "UserInfo.h"
#import "CaseInfo.h"
#import "AppConstants.h"
@interface CaseProveInfo ()
@property (nonatomic, retain, setter = setCaseInfo:) CaseInfo *_caseInfo;
@end

@implementation CaseProveInfo

@dynamic case_desc_id;
@dynamic case_short_desc;
@dynamic caseinfo_id;
//车号
@dynamic citizen_name;
@dynamic end_date_time;
@dynamic event_desc;
@dynamic invitee;
@dynamic invitee_org_duty;
@dynamic isuploaded;
@dynamic myid;
@dynamic organizer;
@dynamic organizer_org_duty;
@dynamic party;
@dynamic party_org_duty;
@dynamic prover;
@dynamic recorder;
@dynamic start_date_time;
@dynamic remark;
@dynamic secondProver;
@dynamic case_long_desc;

@synthesize _caseInfo;
  
- (NSString *) signStr{
    if (![self.caseinfo_id isEmpty]) {
        return [NSString stringWithFormat:@"caseinfo_id == %@", self.caseinfo_id];
    }else{  
        return @"";
    }
}

//读取案号对应的勘验记录
+(CaseProveInfo *)proveInfoForCase:(NSString *)caseID{
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"CaseProveInfo" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"caseinfo_id==%@",caseID];
    fetchRequest.predicate=predicate;
    fetchRequest.entity=entity;
    NSArray *fetchResult=[context executeFetchRequest:fetchRequest error:nil];
    if (fetchResult.count>0) {
        return [fetchResult objectAtIndex:0];
    } else {
        return nil;
    }
}

//读取案号对应的勘验记录
+(CaseProveInfo *)proveInfoForCase:(NSString *)caseID citizenName:(NSString*)citizeName{
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"CaseProveInfo" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"caseinfo_id==%@ && citizen_name==%@",caseID,citizeName];
    fetchRequest.predicate=predicate;
    fetchRequest.entity=entity;
    NSArray *fetchResult=[context executeFetchRequest:fetchRequest error:nil];
    if (fetchResult.count>0) {
        return [fetchResult objectAtIndex:0];
    } else {
        return nil;
    }
}

//由于现在是多当事人，但是案由确实惟一的
+(NSArray *)proveInfoByCaseId:(NSString *)caseID{
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"CaseProveInfo" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"caseinfo_id==%@",caseID];
    fetchRequest.predicate=predicate;
    fetchRequest.entity=entity;
    NSArray *fetchResult=[context executeFetchRequest:fetchRequest error:nil];
    return fetchResult;
}
+ (NSString *)generateEventDescForCase:(NSString *)caseID{
    return [self generateEventDescForCase:caseID automobileNumber:nil];
}
+ (NSString *)generateEventDescForCase:(NSString *)caseID automobileNumber:(NSString*)automobileNumber{
    
//    ----- "勘验情况及结果"按照此格式修改 2014-05-06 zhenlintie
//    李四与2013年11月10日08时18分驾驶粤A12345小轿车行至西二环南段高速公路横江互通K143+100处，在公路B匝道发送交通事故，无人员伤亡造成车辆轻微损坏，经与当事人现场勘查，结果如下：
//    1、当事车辆粤A12345（车号）小轿车（车型）损坏路产如下：立柱2根，单面波形板2片，防阻块3个（具体路产）。
//    2、当事车辆粤A12345
//    3、当事车辆粤A12345
    
    CaseInfo *caseInfo=[CaseInfo caseInfoForID:caseID];
    NSString *roadName=[RoadSegment roadNameFromSegment:caseInfo.roadsegment_id];
    
    
    NSString *caseDescString=@"";
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSString *happenDate=[[AppDelegate getContainingChineseFullDateFormatter] stringFromDate:caseInfo.happen_date];
    

    NSInteger stationStartM=caseInfo.station_start.integerValue%1000;
    NSString *stationStartKMString=[NSString stringWithFormat:@"%d", caseInfo.station_start.integerValue/1000];
    NSString *stationStartMString=[[AppConstants numberFormatter] stringFromNumber:[NSNumber numberWithInteger:stationStartM]];
    NSString *stationString;
    
    if([caseInfo.side rangeOfString:@"收费站" options:NSBackwardsSearch].location == 2 || [caseInfo.place rangeOfString:@"匝道" options:NSBackwardsSearch].location == 1){
        stationString = @"";
    }else{
        if (caseInfo.station_end.integerValue == 0 || caseInfo.station_end.integerValue == caseInfo.station_start.integerValue  ) {
            stationString=[NSString stringWithFormat:@"K%@+%@M处",stationStartKMString,stationStartMString];
        } else {
            NSInteger stationEndM=caseInfo.station_end.integerValue%1000;
            NSString *stationEndKMString=[NSString stringWithFormat:@"%d",caseInfo.station_end.integerValue/1000];
            NSString *stationEndMString=[[AppConstants numberFormatter] stringFromNumber:[NSNumber numberWithInteger:stationEndM]];
            stationString=[NSString stringWithFormat:@"K%@+%@M至K%@+%@M处",stationStartKMString,stationStartMString,stationEndKMString,stationEndMString ];
        }
    }
    
    NSString *caseStatusString=@"";
    if (caseInfo.fleshwound_sum.integerValue==0 && caseInfo.badwound_sum.integerValue==0 && caseInfo.death_sum.integerValue==0) {
        caseStatusString=[caseStatusString stringByAppendingString:@"无人员伤亡，"];
    } else {
        caseStatusString=@"";
        if (caseInfo.fleshwound_sum.integerValue!=0) {
            caseStatusString=[caseStatusString stringByAppendingFormat:@"受伤%@人，",caseInfo.fleshwound_sum];
        }
        if (caseInfo.badwound_sum.integerValue!=0) {
            caseStatusString=[caseStatusString stringByAppendingFormat:@"重伤%@人，",caseInfo.badwound_sum];
        }
        if (caseInfo.death_sum.integerValue!=0) {
            caseStatusString=[caseStatusString stringByAppendingFormat:@"死亡%@人，",caseInfo.death_sum];
        }
    }
    if (caseInfo.badcar_sum.integerValue!=0) {
        caseStatusString=[caseStatusString stringByAppendingFormat:@"损坏%@辆车",caseInfo.badcar_sum];
    } else {
        caseStatusString=[caseStatusString stringByAppendingString:@"未造成车辆损坏"];
    }
    
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
    Citizen *citizen = nil;
    if(automobileNumber != nil && ![automobileNumber isEmpty]){
        citizen=[Citizen citizenByCitizenName:automobileNumber nexus:@"当事人" case:caseID];
    }else{
        NSArray *citizenArray=[Citizen allCitizenNameForCase:caseID];
        if (citizenArray.count>0) {
            citizen=[citizenArray objectAtIndex:0];
        }
    }
        
    NSString *aotomobile = @"当事车辆";
    NSString *aotomobileDeform1 = [@"\n1、" stringByAppendingFormat:@"%@%@",aotomobile,[citizen automobileName]];
    NSString *aotomobileDeform2 = [@"\n2、" stringByAppendingFormat:@"%@%@",aotomobile,[citizen automobileName]];
    NSString *aotomobileDeform3 = [@"\n3、" stringByAppendingFormat:@"%@%@",aotomobile,[citizen automobileName]];
    
    caseDescString=[caseDescString stringByAppendingFormat:@"　　%@于%@驾驶%@行至%@%@%@，在公路%@%@发生交通事故，%@，经与当事人现场勘查，结果如下：",citizen.party,happenDate,[citizen automobileName],roadName,caseInfo.side,stationString,caseInfo.place,caseInfo.case_reason,caseStatusString];
    
    NSEntityDescription *deformEntity=[NSEntityDescription entityForName:@"CaseDeformation" inManagedObjectContext:context];
    NSPredicate *deformPredicate=[NSPredicate predicateWithFormat:@"proveinfo_id ==%@ && (citizen_name==%@ || citizen_name==%@)",caseID,citizen.automobile_number,@"共同"];
    [fetchRequest setEntity:deformEntity];
    [fetchRequest setPredicate:deformPredicate];
    NSArray *deformArray=[context executeFetchRequest:fetchRequest error:nil];
    if (deformArray.count>0) {
        NSString *deformsString=@"";
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
//            NSCharacterSet *zeroSet=[NSCharacterSet characterSetWithCharactersInString:@".0"];
//            quantity=[quantity stringByTrimmingTrailingCharactersInSet:zeroSet];
            quantity = [quantity stringDeleteZeroByfloatstring:quantity];
            deformsString=[deformsString stringByAppendingFormat:@"%@%@%@%@%@、",deform.roadasset_name,roadSizeString,quantity,deform.unit,remarkString];
        }
        deformsString = [deformsString stringByReplacingCharactersInRange:NSMakeRange(deformsString.length-1, 1) withString:@"。"];
        NSCharacterSet *charSet=[NSCharacterSet characterSetWithCharactersInString:@"、"];
        deformsString=[deformsString stringByTrimmingCharactersInSet:charSet];
        caseDescString=[caseDescString stringByAppendingFormat:@"%@损坏路产如下：%@%@%@",aotomobileDeform1,deformsString,aotomobileDeform2,aotomobileDeform3];
    } else {
        caseDescString=[caseDescString stringByAppendingFormat:@"%@没有损坏路产。%@%@",aotomobileDeform1,aotomobileDeform2,aotomobileDeform3];
    }
    
    return caseDescString;
}


- (NSString *) case_mark2{
    if (!_caseInfo) {
        [self setCaseInfo:[CaseInfo caseInfoForID:self.caseinfo_id]];
    }
    return _caseInfo.case_mark2;
}

- (NSString *) full_case_mark3{
    if (!_caseInfo) {
        [self setCaseInfo:[CaseInfo caseInfoForID:self.caseinfo_id]];
    }
    return _caseInfo.full_case_mark3;
}

- (NSString *) weater{
    if (!_caseInfo) {
        [self setCaseInfo:[CaseInfo caseInfoForID:self.caseinfo_id]];
    }
    return _caseInfo.weater;
}

- (NSString *) prover1{
    NSArray *chunks = [self.prover componentsSeparatedByString: @","];
    if([chunks count]==2)
    {
        //勘验人1 单位职务
        return [chunks objectAtIndex:0];
    }else{
        return self.prover;
    }
}

- (NSString *) prover1_org_duty{
    NSArray *chunks = [self.prover componentsSeparatedByString: @","];
    if([chunks count]==2)
    {
        //勘验人1 单位职务
        return [UserInfo orgAndDutyForUserName:[chunks objectAtIndex:0]];
    }
    else
    {
        return [UserInfo orgAndDutyForUserName:self.prover];
    }
}

- (NSString *) prover2{
    NSArray *chunks = [self.prover componentsSeparatedByString: @","];
    if(chunks && [chunks count]>=2)
    {
        //勘验人2 单位职务
        return [chunks objectAtIndex:1];
    }else{
        return self.secondProver;
        return @"";
    }
}

- (NSString *) prover2_org_duty{
    NSArray *chunks = [self.prover componentsSeparatedByString: @","];
    if(chunks && [chunks count]>=2)
    {
        //勘验人1 单位职务
        return [UserInfo orgAndDutyForUserName:[chunks objectAtIndex:1]];
    }
    else if ([self.secondProver length] > 0)
    {
        return [UserInfo orgAndDutyForUserName:self.secondProver];
    }else {
        return @"";
    }
}
- (NSString *) citizen_org_duty{
    Citizen *citizen = [Citizen citizenForCitizenName:self.citizen_name nexus:@"当事人" case:self.caseinfo_id];
    return [NSString stringWithFormat:@"%@%@", citizen.org_name, citizen.org_principal_duty];
}

- (NSString *) recorder_org_duty{
    return [UserInfo orgAndDutyForUserName:self.recorder];
}

@end
