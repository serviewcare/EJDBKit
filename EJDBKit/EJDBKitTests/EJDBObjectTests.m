/**
 These tests are not complete and are for an up and coming feature! Disregard for now!!!!
*/
 

#import "EJDBObjectTests.h"
#import "EJDBObject.h"

@class TestRelatedEJDBObject;

@interface TestEJDBObject : EJDBObject
@property (copy,nonatomic) NSString *name;
@property (strong,nonatomic) NSNumber *age;
@property (strong,nonatomic) NSNumber *money;
@property (strong,nonatomic) NSDate *date;
@property (strong,nonatomic) NSDictionary *dict;
@property (strong,nonatomic) NSArray *arr;
@property (weak,nonatomic) TestRelatedEJDBObject *scores;
@property (assign,nonatomic) int num;
@end

@implementation TestEJDBObject
@end

@interface TestRelatedEJDBObject : EJDBObject
@property (strong,nonatomic) NSArray *scores;
@end

@implementation TestRelatedEJDBObject
@end


@implementation EJDBObjectTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{

    [super tearDown];
}

- (void)testObject1EqualsObject2
{
    TestRelatedEJDBObject *relatedObject = [[TestRelatedEJDBObject alloc]init];
    relatedObject.scores = @[@1,@2,@3,@4,@5];
    
    TestEJDBObject *obj1 = [[TestEJDBObject alloc]init];
    obj1.name = @"AName";
    obj1.age = @225;
    obj1.money = @123.456;
    obj1.date = [NSDate date];
    obj1.dict = @{@"this" : @"is",@"my" : @"dictionary"};
    obj1.arr = @[@"These",@"are",@"my",@"elements"];
    obj1.scores = relatedObject;
    NSDictionary *saveableDictionaryObj1 = [obj1 toDictionary];
    TestEJDBObject *obj2 = [[TestEJDBObject alloc]init];
    [obj2 fromDictionary:saveableDictionaryObj1];
    NSDictionary *saveeableDictionaryObj2 = [obj2 toDictionary];
    STAssertEqualObjects(saveableDictionaryObj1, saveeableDictionaryObj2, @"Obj1 and Obj2 dictionaries should be equal!");
}


@end
