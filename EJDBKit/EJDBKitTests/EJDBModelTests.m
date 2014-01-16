#import <XCTest/XCTest.h>
#import "EJDBDatabase+DBTestExtensions.h"
#import "EJDBQuery.h"
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


@interface TestObjectUnsupportedPropertyAttribute : EJDBModel
@property (readonly) int aReadonlyProperty;
@end

@implementation TestObjectUnsupportedPropertyAttribute
@dynamic aReadonlyProperty;
@end

@interface TestObjectUnsupportedPrimitiveProperty : EJDBModel
@property (nonatomic) short aShort;
@end

@implementation TestObjectUnsupportedPrimitiveProperty
@dynamic aShort;
@end

@interface TestObjectUnsupportedObjectProperty : EJDBModel
@property (strong,nonatomic) NSSet *aSet;
@end

@implementation TestObjectUnsupportedObjectProperty
@dynamic aSet;
@end


@interface EJDBModelTests : XCTestCase

@end

@interface EJDBModelTests ()
@property (strong,nonatomic) EJDBDatabase *db;
@property (strong,nonatomic) EJDBCollection *collection;
@end

@implementation EJDBModelTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    _db = [EJDBDatabase createAndOpenDb];
    _collection = [_db ensureCollectionWithName:@"foo" error:NULL];
}

- (void)tearDown
{
    [EJDBDatabase closeAndDeleteDb:_db];
    _db = nil;
    _collection = nil;
    [super tearDown];
}

- (TestSupportedObject *)validEmptyModelObject
{
    TestSupportedObject *testObj = [[TestSupportedObject alloc]init];
    return testObj;
}

- (void)testInitializingSupportedObjectSucceeds
{
    TestSupportedObject *testObj;
    XCTAssertNoThrow(testObj = [[TestSupportedObject alloc]init],@"Initializing a valid ejdbmodel object should not throw exception!");
}

- (void)testInitializingObjectWithUnsupportedPropertyAttributeThrowsException
{
    TestObjectUnsupportedPropertyAttribute *testObj;
    XCTAssertThrows(testObj = [[TestObjectUnsupportedPropertyAttribute alloc]init],
                    @"Initializing an ejdbmodel with an unsupported dynamic property attribute should throw exception!");
}

- (void)testInitialzingObjectWithUnsupportedPrimitivePropertyTypeThrowsException
{
    TestObjectUnsupportedPrimitiveProperty *testObj;
    XCTAssertThrows(testObj = [[TestObjectUnsupportedPrimitiveProperty alloc]init],
                    @"Initializing an ejdbmodel with an unsupported primitive property type should throw exception!");
}

- (void)testInitializingObjectWithUnsupportedObjectTypeThrowsException
{
    TestObjectUnsupportedObjectProperty *testObj;
    XCTAssertThrows(testObj = [[TestObjectUnsupportedObjectProperty alloc]init],
                    @"Initializing an ejdbmodel with an unsupported object property type should throw exception!");
}

- (void)testSupportedPrimitiveAndObjectTypes
{
    TestSupportedObject *testObj = [[TestSupportedObject alloc]init];
    XCTAssertNoThrow([testObj setAnInteger:2], @"setting primitive int on object should not throw exception!");
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

- (void)testToDictionaryWithNilPropertiesDoesntThrowException
{
    TestSupportedObject *testObj = [self validEmptyModelObject];
    NSDictionary *dictionary;
    XCTAssertNoThrow(dictionary = [testObj toDictionary],@"getting dictionary representation of empty model object should not throw exception!");
}

- (void)testToDictionaryWithNilPropertyValuesAreByDefaultNull
{
    TestSupportedObject *testObj = [[TestSupportedObject alloc]init];
    NSDictionary *dictionary = [testObj toDictionary];
    XCTAssertEqualObjects(dictionary[@"anInteger"], [NSNull null], @"dictionary representation of unset primitive int should be = [NSNull null]!");
    XCTAssertEqualObjects(dictionary[@"aBool"], [NSNull null], @"dictionary representation of unset primitive bool should be = [NSNull null]!");
    XCTAssertEqualObjects(dictionary[@"aFloat"], [NSNull null], @"dictionary representation of unset primitive float should be = [NSNull null]!");
    XCTAssertEqualObjects(dictionary[@"aDouble"], [NSNull null], @"dictionary representation of unset primitive double should be = [NSNull null]!");
    XCTAssertEqualObjects(dictionary[@"aString"], [NSNull null], @"dictionary representation of unset string object should be = [NSNull null]!");
    XCTAssertEqualObjects(dictionary[@"aNumber"], [NSNull null], @"dictionary representation of unset number object should be = [NSNull null]!");
    XCTAssertEqualObjects(dictionary[@"aDict"], [NSNull null], @"dictionary representation of unset dictionary object should be = [NSNull null]!");
    XCTAssertEqualObjects(dictionary[@"anArray"], [NSNull null], @"dictionary representation of unset array object should be = [NSNull null]!");
    XCTAssertEqualObjects(dictionary[@"aDate"], [NSNull null], @"dictionary representation of unset date object should be = [NSNull null]!");
}

- (void)testToDictionaryConformsToPersistanceRequirements
{
    TestSupportedObject *testObj = [[TestSupportedObject alloc]init];
    NSDictionary *dictionary = [testObj toDictionary];
    XCTAssertNotNil(dictionary[@"type"], @"dictionary representation must contain a type entry!");
}

- (void)testSavingEmptySupportedObjectToCollectionSucceeds
{
    TestSupportedObject *testObj = [[TestSupportedObject alloc]init];
    BOOL success = [_collection saveObject:testObj];
    XCTAssertTrue(success, @"Saving empty supported object to collection should succed!");
}

- (void)testRetrievingEmptySupportedObjectFromCollectionSucceeds
{
    TestSupportedObject *testObj = [[TestSupportedObject alloc]init];
    [_collection saveObject:testObj];
    EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:_collection query:nil];
    TestSupportedObject *fetchedObject = [query fetchObject];
    XCTAssertNotNil(fetchedObject, @"fetched model object should not be nil!");
}


@end
