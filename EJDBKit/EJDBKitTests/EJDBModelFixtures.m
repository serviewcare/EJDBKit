#import "EJDBModelFixtures.h"


@implementation EJDBModelFixtures

+ (TestRelatedObject *)relatedObject
{
    return [[TestRelatedObject alloc]init];
}

+ (TestSupportedObject *)supportedObject
{
    return [[TestSupportedObject alloc]init];
}


@end

@implementation TestSupportedObject

- (NSArray *)joinableModelArrayProperties
{
    return @[@"relatedObjects"];
}

@end

@implementation TestRelatedObject

@end
