//
//  AtonementNotice.m
//  GDRMMobile
//
//  Created by yu hongwu on 12-11-15.
//
//

#import "AtonementNotice.h"
#import "Systype.h"
#import "CaseInfo.h"
#import "CaseDeformation.h"
#import "RoadSegment.h"
#import "AppConstants.h"
@implementation AtonementNotice

@dynamic myid;
@dynamic caseinfo_id;
@dynamic citizen_name;
@dynamic code;
@dynamic date_send;
@dynamic check_organization;
@dynamic case_desc;
@dynamic witness;
@dynamic pay_reason;
@dynamic pay_mode;
@dynamic organization_id;
@dynamic remark;
@dynamic isuploaded;

- (NSString *) signStr{
    if (![self.caseinfo_id isEmpty]) {
        return [NSString stringWithFormat:@"caseinfo_id == %@", self.caseinfo_id];
    }else{
        return @"";
    }
}

+ (NSArray *)AtonementNoticesForCase:(NSString *)caseID{
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"caseinfo_id==%@",caseID];
    fetchRequest.predicate=predicate;
    fetchRequest.entity=entity;
    return [context executeFetchRequest:fetchRequest error:nil];
}

+ (NSString *)generateEventDescForCase:(NSString *)caseID citizen:(Citizen*)targetCitizen{
    CaseInfo *caseInfo=[CaseInfo caseInfoForID:caseID];
    NSString *roadName=[RoadSegment roadNameFromSegment:caseInfo.roadsegment_id];
    
    
    NSString *caseDescString=@"";
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日HH时mm分"];
    NSString *happenDate=[dateFormatter stringFromDate:caseInfo.happen_date];
    

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
    
    NSArray *citizenArray=[Citizen allCitizenNameForCase:caseID];
    if (citizenArray.count>0) {
        // modified by cjl
        Citizen *citizen=[citizenArray objectAtIndex:0];
        if (citizenArray.count==1) {
             caseDescString=[caseDescString stringByAppendingFormat:@"%@驾驶%@行至%@%@%@，在公路%@%@发生交通事故，%@，经与当事人现场勘查，损坏路产详见赔（补）偿清单。",happenDate,[citizen automobileName],roadName,caseInfo.side,stationString,caseInfo.place,caseInfo.case_reason,caseStatusString];
        }
        if (citizenArray.count>1) {
            
            caseDescString=[caseDescString stringByAppendingFormat:@"%@于%@驾驶%@行至%@%@%@，与",targetCitizen.party,happenDate,[targetCitizen automobileName],roadName,caseInfo.side,stationString];
            BOOL flag = TRUE;
            for (int i=0;i<citizenArray.count;i++) {
                citizen=[citizenArray objectAtIndex:i];
                if (![citizen.automobile_number isEqual:targetCitizen.automobile_number]) {
                    if (flag) {
                        caseDescString=[caseDescString stringByAppendingFormat:@"%@驾驶的%@",citizen.party,[citizen automobileName]];
                        flag = FALSE;
                    }
                    else {
                        caseDescString=[caseDescString stringByAppendingFormat:@"、%@驾驶的%@",citizen.party,[citizen automobileName]];
                    }
                }
            }
            caseDescString=[caseDescString stringByAppendingFormat:@"在公路%@%@发生碰撞，造成交通事故，%@，经与当事人现场勘查，损坏路产详见赔（补）偿清单。",caseInfo.place,caseInfo.case_reason,caseStatusString];
        }
    }
    return caseDescString;
}

- (NSString *)organization_info{
    return self.organization_id;
}

- (NSString *)bank_name{
    return [[Systype typeValueForCodeName:@"交款地点"] objectAtIndex:0];
}

+ (NSArray *)AtonementNoticesForCase:(NSString *)caseID citizenName:(NSString*)citizenName{
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"caseinfo_id==%@ and citizen_name==%@",caseID,citizenName];
    fetchRequest.predicate=predicate;
    fetchRequest.entity=entity;
    return [context executeFetchRequest:fetchRequest error:nil];
}
@end
