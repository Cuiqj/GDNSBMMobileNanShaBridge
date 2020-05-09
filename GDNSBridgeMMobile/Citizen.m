//
//  Citizen.m
//  GDRMMobile
//
//  Created by yu hongwu on 12-11-19.
//
//

#import "Citizen.h"


@implementation Citizen

@dynamic address;
@dynamic age;
@dynamic automobile_address;
@dynamic automobile_number;
@dynamic automobile_owner;
@dynamic automobile_pattern;
@dynamic bad_desc;
@dynamic card_name;
@dynamic card_no;
@dynamic carowner;
@dynamic carowner_address;
@dynamic proveinfo_id;
@dynamic compensate_money;
@dynamic driver;
@dynamic isuploaded;
@dynamic myid;
@dynamic nation;
@dynamic nationality;
@dynamic nexus;
@dynamic org_name;
@dynamic org_principal;
@dynamic org_principal_duty;
@dynamic org_principal_tel_number;
@dynamic org_tel_number;
@dynamic original_home;
@dynamic party;
@dynamic patry_type;
@dynamic postalcode;
@dynamic profession;
@dynamic proportion;
@dynamic remark;
@dynamic sex;
@dynamic tel_number;
@dynamic org_full_name;
@dynamic insurance_company;
@dynamic insurance_no;

- (NSString *) signStr{
    if (![self.proveinfo_id isEmpty]) {
        return [NSString stringWithFormat:@"proveinfo_id == %@", self.proveinfo_id];
    }else{
        return @"";
    }
}

+ (NSArray *)allCitizenNameForCase:(NSString *)caseID{
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Citizen" inManagedObjectContext:context];
    fetchRequest.entity=entity;
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"proveinfo_id==%@ && nexus==%@",caseID,@"当事人"];
    fetchRequest.predicate=predicate;
    return [context executeFetchRequest:fetchRequest error:nil];
}



+ (Citizen *)citizenForName:(NSString *)autoNumber nexus:(NSString *)nexus case:(NSString *)caseID{
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
    NSEntityDescription *entity=[NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    fetchRequest.entity=entity;
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"proveinfo_id==%@ && nexus==%@ && automobile_number==%@",caseID,nexus,autoNumber];
    fetchRequest.predicate=predicate;
    if ([context countForFetchRequest:fetchRequest error:nil]>0) {
        return [[context executeFetchRequest:fetchRequest error:nil] lastObject];
    } else {
        return nil;
    }
}

+ (Citizen *)citizenForParty:(NSString *)party case:(NSString *)caseID{
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
    NSEntityDescription *entity=[NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    fetchRequest.entity=entity;
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"proveinfo_id==%@ && nexus==%@ && party==%@",caseID,@"当事人",party];
    fetchRequest.predicate=predicate;
    if ([context countForFetchRequest:fetchRequest error:nil]>0) {
        return [[context executeFetchRequest:fetchRequest error:nil] lastObject];
    } else {
        return nil;
    }
}

//add by lxm 2013.05.10
+ (Citizen *)citizenForCitizenName:(NSString *)name nexus:(NSString *)nexus case:(NSString *)caseID{
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
    NSEntityDescription *entity=[NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    fetchRequest.entity=entity;
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"proveinfo_id==%@ && nexus==%@",caseID,nexus];
    fetchRequest.predicate=predicate;
    if ([context countForFetchRequest:fetchRequest error:nil]>0) {
        return [[context executeFetchRequest:fetchRequest error:nil] lastObject];
    } else {
        return nil;
    }
}
+ (Citizen *)citizenByCitizenName:(NSString *)name nexus:(NSString *)nexus case:(NSString *)caseID{
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
    NSEntityDescription *entity=[NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    fetchRequest.entity=entity;
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"proveinfo_id==%@ && nexus==%@ && automobile_number==%@",caseID,nexus,name];
    fetchRequest.predicate=predicate;
    if ([context countForFetchRequest:fetchRequest error:nil]>0) {
        return [[context executeFetchRequest:fetchRequest error:nil] lastObject];
    } else {
        return nil;
    }
}
+ (Citizen *)citizenByCitizenParty:(NSString *)party nexus:(NSString *)nexus case:(NSString *)caseID{
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
    NSEntityDescription *entity=[NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    fetchRequest.entity=entity;
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"proveinfo_id==%@ && nexus==%@ && party==%@",caseID,nexus,party];
    fetchRequest.predicate=predicate;
    if ([context countForFetchRequest:fetchRequest error:nil]>0) {
        return [[context executeFetchRequest:fetchRequest error:nil] lastObject];
    } else {
        return nil;
    }
}
+ (Citizen *)citizenByCitizenParty:(NSString *)party case:(NSString *)caseID{
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
    NSEntityDescription *entity=[NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    fetchRequest.entity=entity;
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"proveinfo_id==%@ && party==%@",caseID,party];
    fetchRequest.predicate=predicate;
    if ([context countForFetchRequest:fetchRequest error:nil]>0) {
        return [[context executeFetchRequest:fetchRequest error:nil] lastObject];
    } else {
        return nil;
    }
}
//add by mjj 2014.08.27
+ (NSArray *)citizenForCitizenName:(NSString *)nexus case:(NSString *)caseID{
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
    NSEntityDescription *entity=[NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    fetchRequest.entity=entity;
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"proveinfo_id==%@ && nexus==%@",caseID,nexus];
    fetchRequest.predicate=predicate;
    return [context executeFetchRequest:fetchRequest error:nil];
    
}

-(NSString *)automobileName{
    NSString *automobile_pattern = [self.automobile_pattern stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([automobile_pattern isEqualToString:@"重型半挂牵引车"]) {
        NSArray *automobile_numbers = [self.automobile_number componentsSeparatedByString:@"/"];
        NSString *automobileName = @"重型半挂牵引车牵引";
        if ([automobile_numbers count] > 1) {
            return [NSString stringWithFormat:@"%@%@%@车",automobile_numbers[0],automobileName,automobile_numbers[1]];
        }else if([automobile_numbers count] == 1){
            return [NSString stringWithFormat:@"%@%@车",automobile_numbers[0],automobileName];        
        }
    }
    return [NSString stringWithFormat:@"%@%@",self.automobile_number,self.automobile_pattern];
}
@end
