#import <XCTest/XCTest.h>
#import "EJDBDatabase+DBTestExtensions.h"
#import "EJDBQueryBuilder.h"
#import "EJDBQuery.h"
#import "EJDBModel.h"
#import "EJDBModelFixtures.h"

@interface EJDBModelTests : XCTestCase

@end

@interface EJDBModelTests ()
@property (strong,nonatomic) EJDBDatabase *db;
@property (strong,nonatomic) EJDBCollection *collection;
@property (strong,nonatomic) EJDBCollection *relatedCollection;
@end

@implementation EJDBModelTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    _db = [EJDBDatabase createAndOpenDb];
    _collection = [_db ensureCollectionWithName:@"TestSupportedObject" error:NULL];
    _relatedCollection = [_db ensureCollectionWithName:@"TestRelatedObject" error:NULL];
}

- (void)tearDown
{
    [EJDBDatabase closeAndDeleteDb:_db];
    _db = nil;
    _collection = nil;
    _relatedCollection = nil;
    [super tearDown];
}

- (TestSupportedObject *)validFilledModelObject
{
    TestSupportedObject *testObj = [[TestSupportedObject alloc]initWithDatabase:_db];
    testObj.anInteger = 100;
    testObj.aBool = true;
    testObj.aFloat = 123.456;
    testObj.aDouble = 12345.678901;
    testObj.aString = @"My string value!";
    testObj.aNumber = @1000;
    testObj.aDict = @{@"key1" : @"value1",@"key2" : @"value2"};
    testObj.anArray = @[@1,@2,@3];
    testObj.someData = [NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]]
                                                       pathForResource:@"ejdblogo3" ofType:@"png"]];
    testObj.aLongLong = 9100200300400500600LL;
    testObj.aDate = [NSDate date];
    return testObj;
}

- (void)testInitializingSupportedObjectSucceeds
{
    TestSupportedObject *testObj;
    XCTAssertNoThrow(testObj = [[TestSupportedObject alloc]init],@"Initializing a valid ejdbmodel object should not throw exception!");
}

- (void)testSupportedPrimitiveAndObjectTypes
{
    TestSupportedObject *testObj = [[TestSupportedObject alloc]init];
    XCTAssertNoThrow(testObj.anInteger = 2, @"setting primitive int on object should not throw exception!");
    XCTAssertNoThrow(testObj.aBool = true, @"setting primitive bool on object should not throw exception!");
    XCTAssertNoThrow(testObj.aFloat = 1.25f, @"setting primitive float on object should not throw exception!");
    XCTAssertNoThrow(testObj.aDouble = 25.75f,@"setting primitive double on object should not throw exception!");
    XCTAssertNoThrow(testObj.aLongLong = 1234567890LL, @"setting primitive long long on object should not throw exception!");
    XCTAssertNoThrow(testObj.anInteger, @"getting primitive int from object should not throw exception!");
    XCTAssertNoThrow(testObj.aBool, @"getting primitive bool from object should not throw exception!");
    XCTAssertNoThrow(testObj.aFloat, @"getting primitive float from object should not throw exception!");
    XCTAssertNoThrow(testObj.aDouble, @"getting primitive double from object should not throw exception!");
    XCTAssertNoThrow(testObj.aLongLong, @"getting primitive long long from object should not throw exception!");
    XCTAssertNoThrow(testObj.aString, @"getting nil string value from object should not throw exception!");
    XCTAssertNoThrow(testObj.aNumber, @"getting nil number value from object should not throw exception!");
    XCTAssertNoThrow(testObj.aDict, @"getting nil dictionary value from object should not throw exception!");
    XCTAssertNoThrow(testObj.anArray, @"getting nil array value from object should not throw exception!");
    XCTAssertNoThrow(testObj.aDate, @"getting nil date value from object should not throw exception!");
    XCTAssertNoThrow(testObj.someData, @"getting nil data value from object should not throw exception!");
}

- (void)testToDictionaryWithNilPropertiesDoesntThrowException
{
    TestSupportedObject *testObj = [[TestSupportedObject alloc]init];
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
    XCTAssertEqualObjects(dictionary[@"aLongLong"], [NSNull null], @"dictionary representation of unset primitive long long should be = [NSNull null]!");
    XCTAssertEqualObjects(dictionary[@"aString"], [NSNull null], @"dictionary representation of unset string object should be = [NSNull null]!");
    XCTAssertEqualObjects(dictionary[@"aNumber"], [NSNull null], @"dictionary representation of unset number object should be = [NSNull null]!");
    XCTAssertEqualObjects(dictionary[@"aDict"], [NSNull null], @"dictionary representation of unset dictionary object should be = [NSNull null]!");
    XCTAssertEqualObjects(dictionary[@"anArray"], [NSNull null], @"dictionary representation of unset array object should be = [NSNull null]!");
    XCTAssertEqualObjects(dictionary[@"aDate"], [NSNull null], @"dictionary representation of unset date object should be = [NSNull null]!");
    XCTAssertEqualObjects(dictionary[@"someData"], [NSNull null], @"dictionary representation of unset data object should be = [NSNull null]!");
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
    XCTAssertTrue(success, @"Saving empty supported object to collection should succeed!");
}

- (void)testRetrievingEmptySupportedObjectFromCollectionSucceeds
{
    TestSupportedObject *testObj = [[TestSupportedObject alloc]init];
    [_collection saveObject:testObj];
    EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:_collection query:nil];
    TestSupportedObject *fetchedObject = [query fetchObject];
    XCTAssertNotNil(fetchedObject, @"fetched model object should not be nil!");
}

- (void)testSavingSupportedObjectWithPropertiesFilledToCollectionSucceeds
{
    BOOL success = [_collection saveObject:[self validFilledModelObject]];
    XCTAssertTrue(success, @"Saving model object with values filled should succeed!");
}

- (void)testRetrievingFilledSupportedObjectFromCollectionSucceeds
{
    TestRelatedObject *relatedObject = [[TestRelatedObject alloc]initWithDatabase:_db];
    relatedObject.name = @"First Name Last Name";
    [_relatedCollection saveObject:relatedObject];
    TestSupportedObject *objectToSave = [self validFilledModelObject];
    objectToSave.relatedObj = relatedObject;
    [_collection saveObject:objectToSave];
    EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:_collection query:nil];
    TestSupportedObject *fetchedObject = [query fetchObject];
    NSTimeInterval timeInterval = round([fetchedObject.aDate timeIntervalSinceDate:objectToSave.aDate]);
    XCTAssertTrue(timeInterval == 0, @"object to save date and fetched object date time intervals should have 0 seconds between them!");
    XCTAssertTrue(fetchedObject.anInteger == objectToSave.anInteger, @"fetched integer value should be 100!");
    XCTAssertTrue(fetchedObject.aBool == objectToSave.aBool, @"fetched bool value should be true!");
    XCTAssertTrue(fetchedObject.aFloat == objectToSave.aFloat, @"fetched float value should be 123.456!");
    XCTAssertTrue(fetchedObject.aDouble == objectToSave.aDouble, @"fetched double value should be 25.75!");
    XCTAssertTrue(fetchedObject.aLongLong == objectToSave.aLongLong, @"fetched long long value should equal saved long long value!");
    XCTAssertTrue([fetchedObject.aString isEqualToString:objectToSave.aString], @"fetched string object value should be equal to My stringValue!");
    XCTAssertTrue([fetchedObject.aNumber isEqualToNumber:objectToSave.aNumber], @"fetched number object value should be equal to 1000!");
    XCTAssertTrue([fetchedObject.aDict isEqualToDictionary:objectToSave.aDict],@"fetched dict object value should be equal to saved dict value!");
    XCTAssertTrue([fetchedObject.anArray isEqualToArray:objectToSave.anArray], @"fetched array object value should be equal to saved array value!");
    XCTAssertTrue([fetchedObject.someData isEqualToData:objectToSave.someData], @"fetched data object value should be equal to saved data value!");
    XCTAssertTrue([fetchedObject.relatedObj.oid isEqual:objectToSave.relatedObj.oid], @"fetched related object value should be equal to saved related object value!");
}

- (void)testSavingAndRetrievingArrayOfRelatedObjectsSucceeds
{
    TestRelatedObject *relObj1 = [[TestRelatedObject alloc]initWithDatabase:_db];
    relObj1.name = @"related object 1";
    TestRelatedObject *relObj2 = [[TestRelatedObject alloc]initWithDatabase:_db];
    relObj2.name = @"related object 2";
    TestRelatedObject *relObj3 = [[TestRelatedObject alloc]initWithDatabase:_db];
    relObj3.name = @"unrelated object 3";
    [_relatedCollection saveObjects:@[relObj1,relObj2,relObj3]];
    TestSupportedObject *model = [[TestSupportedObject alloc]initWithDatabase:_db];
    model.relatedObjects = @[relObj1,relObj2];
    [_collection saveObject:model];
    EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:_collection query:nil];
    TestSupportedObject *fetchedObject = [query fetchObject];
    XCTAssertTrue([fetchedObject.relatedObjects count] == 2, @"Array of related objects count should be exactly 2!");
    XCTAssertTrue([[fetchedObject.relatedObjects[0] oid] isEqual:relObj1.oid], @"related object 1 should exactly equal fetched related object 1!");
    XCTAssertTrue([[fetchedObject.relatedObjects[1] oid] isEqual:relObj2.oid], @"related object 2 should exactly equal fetched related object 2!");
}

@end
