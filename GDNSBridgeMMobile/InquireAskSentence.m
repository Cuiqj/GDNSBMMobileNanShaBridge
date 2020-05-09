//
//  InquireAskSentence.m
//  GDRMMobile
//
//  Created by yu hongwu on 12-11-14.
//
//

#import "InquireAskSentence.h"


@implementation InquireAskSentence

@dynamic myid;
@dynamic the_index;
@dynamic sentence;
+(void)deleteInsertRecord:(NSString *)myId{
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"InquireAskSentence" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"myid == %@",myId];
    fetchRequest.predicate=predicate;
    fetchRequest.entity=entity;
    NSArray *fetchResult=[context executeFetchRequest:fetchRequest error:nil];
    for (NSManagedObject *obj in fetchResult) {
        [context deleteObject:obj];
    }
}
@end
