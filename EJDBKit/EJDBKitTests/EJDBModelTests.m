#import <XCTest/XCTest.h>
#import "EJDBModel.h"

@interface TestSupportedObject : EJDBModel
@property (strong,nonatomic) NSString *aString;
@property (strong,nonatomic) NSNumber *aNumber;
@property (strong,nonatomic) NSDictionary *aDict;
@property (strong,nonatomic) NSArray *anArray;
@property (strong,nonatomic) NSDate *aDate;
@property (nonatomic) int anInteger;
@property (nonatomic) bool aBool;
@property (nonatomic) float aFloat;
@property (nonatomic) double aDouble;
@end

@implementation TestSupportedObject
@dynamic aString;
@dynamic aNumber;
@dynamic aDict;
@dynamic anArray;
@dynamic aDate;
@dynamic anInteger;
@dynamic aBool;
@dynamic aFloat;
@dynamic aDouble;
@end


@interface TestUnsupportedObject : EJDBModel
@property (nonatomic) short aShort;
@property (strong,nonatomic) NSSet *aSet;
@end

@implementation TestUnsupportedObject
@dynamic aShort;
@dynamic aSet;
@end


@interface EJDBModelTests : XCTestCase

@end

@implementation EJDBModelTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testSupportedTypes
{
    TestSupportedObject *testObj = [[TestSupportedObject alloc]init];
    XCTAssertNoThrow(testObj.anInteger = 2, @"setting primitive int on object should not throw exception!");
    XCTAssertNoThrow(testObj.aBool = true, @"setting primitive bool on object should not throw exception!");
    XCTAssertNoThrow(testObj.aFloat = 1.25f, @"setting primitive float on object should not throw exception!");
    XCTAssertNoThrow(testObj.aDouble = 25.75f,@"setting primitive double on object should not throw exception!");
    XCTAssertNoThrow(testObj.anInteger, @"getting primitive int from object should not throw exception!");
    XCTAssertNoThrow(testObj.aBool, @"getting primitive bool from object should not throw exception!");
    XCTAssertNoThrow(testObj.aFloat, @"getting primitive float from object should not throw exception!");
    XCTAssertNoThrow(testObj.aDouble, @"getting primitive double from object should not throw exception!");
    XCTAssertNoThrow(testObj.aString, @"getting nil string value from object should not throw exception!");
    XCTAssertNoThrow(testObj.aNumber, @"getting nil number value from object should not throw exception!");
    XCTAssertNoThrow(testObj.aDict, @"getting nil dictionary value from object should not throw exception!");
    XCTAssertNoThrow(testObj.anArray, @"getting nil array value from object should not throw exception!");
    XCTAssertNoThrow(testObj.aDate, @"getting nil date value from object should not throw exception!");
}

- (void)testUnsupportedTypes
{
    TestUnsupportedObject *testObj = [[TestUnsupportedObject alloc]init];
    XCTAssertThrows(testObj.aShort = 2, @"setting unsupported primitive on model object should throw exception!");
    NSArray *array = @[@1,@2,@3];
    XCTAssertThrows(testObj.aSet = [NSSet setWithArray:array], @"setting unsupported object on model object should throw exception!");
}





@end
