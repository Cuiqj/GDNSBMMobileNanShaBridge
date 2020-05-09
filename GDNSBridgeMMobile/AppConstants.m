//
//  AppConstants.m
//  GDXERHMMobile
//
//  Created by yu hongwu on 14-10-9.
//
//

#import "AppConstants.h"

@implementation AppConstants
+(NSNumberFormatter*)numberFormatter{
    static NSNumberFormatter *numFormatter;
    if(numFormatter == nil){
        numFormatter =[[NSNumberFormatter alloc] init];
        [numFormatter setPositiveFormat:@"000"];
    }
    return numFormatter;
}
@end


