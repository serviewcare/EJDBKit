#import "EJDBCollectionTests.h"
#import "EJDBDatabase+DBTestExtensions.h"
#import "EJDBCollection.h"
#import "EJDBQueryBuilder.h"
#import "EJDBFIQueryBuilder.h"
#import "EJDBTestFixtures.h"


@interface EJDBCollectionTests ()
@property (strong,nonatomic) EJDBDatabase *db;
@property (strong,nonatomic) EJDBCollection *collection;
@end


@implementation EJDBCollectionTests

- (void)setUp
{
    [super setUp];
    _db = [EJDBDatabase createAndOpenDb];
    _collection = [_db ensureCollectionWithName:@"foo" error:NULL];
}

- (void)tearDown
{
    [EJDBDatabase closeAndDeleteDb:_db];
    _collection = nil;
    [super tearDown];
}

- (void)testSaveObjectSuccessfully
{
    NSDictionary *obj1 = [EJDBTestFixtures simpleDictionaries][0];
    BOOL success = [_collection saveObject:obj1];
    XCTAssertTrue(success, @"object should be saved successfully!");
}

- (void)testSavingNilObjectFails
{
    BOOL success = [_collection saveObject:nil];
    XCTAssertFalse(success, @"Nil object should not be saved successfully!");
}
 
- (void)testSaveObjectsSuccessfully
{
    BOOL success = [_collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    XCTAssertTrue(success, @"objects should be saved successfully!");
}

- (void)testSavingNilObjectsFails
{
    BOOL success = [_collection saveObjects:nil];
    XCTAssertFalse(success, @"Nil objects should not be saved successfully!");
}

- (void)testRemoveDictionaryWithOIDSucceeds
{
    [_collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    NSArray *results = [_db findObjectsWithQuery:@{@"name" : @"joe blow"} inCollection:_collection error:NULL];
    NSDictionary *fooObj = results[0];
    BOOL success = [_collection removeObjectWithOID:[fooObj objectForKey:@"_id"]];
    XCTAssertTrue(success, @"Should remove joe blow dictionary successfully!");
    NSArray *resultsWithoutFoo = [_db findObjectsWithQuery:@{@"name" : @"joe blow"} inCollection:_collection error:NULL];
    XCTAssertTrue([resultsWithoutFoo count] == 0, @"Results for joe blow query should return 0!");
}

- (void)testRemoveObjectWithOIDSucceeds
{
    CustomArchivableClass *obj1 = [EJDBTestFixtures validArchivableClass];
    obj1.name = @"foo";
    obj1.age = @32;
    CustomArchivableClass *obj2 = [EJDBTestFixtures validArchivableClass];
    obj2.name = @"bar";
    obj2.age = @25;
    [_collection saveObjects:@[obj1,obj2]];
    NSArray *results = [_db findObjectsWithQuery:@{@"name" : @"foo"} inCollection:_collection error:NULL];
    CustomArchivableClass *fooObj = results[0];
    BOOL success = [_collection removeObject:fooObj];
    XCTAssertTrue(success, @"Should remove foo object successfully!");
    NSArray *resultsWithoutFoo = [_db findObjectsWithQuery:@{@"name" : @"foo"} inCollection:_collection error:NULL];
    XCTAssertTrue([resultsWithoutFoo count] == 0, @"Results for foo query should return 0!");
}

- (void)testRemovingUnsupportedObjectFails
{
    NSSet *unsupportedObj = [NSSet setWithObject:@"Unsupported"];
    BOOL success = [_collection removeObject:unsupportedObj];
    XCTAssertFalse(success, @"Removing an Unsupported object should fail!");
}

- (void)testRemovingDictionaryWithoutOIDFails
{
    NSDictionary *obj1 = [EJDBTestFixtures simpleDictionaries][0];
    [_collection saveObject:obj1];
    NSArray *results = [_db findObjectsWithQuery:@{@"name" : @"joe blow"}
                                           hints:@{@"$fields":@{@"name": @1}}
                                    inCollection:_collection error:NULL];
    NSDictionary *objWithoutOID = results[0];
    BOOL success = [_collection removeObject:objWithoutOID];
    XCTAssertFalse(success, @"Removing a dictionary without an OID should fail!");
}

- (void)testProvidingInvalidOIDForRemovalOfObjectFails
{
    XCTAssertFalse([_collection removeObjectWithOID:@"123"], @"Trying to remove an object by supplying an invalid OID should fail!");
}

- (void)testFetchingObjectWithInvalidOIDReturnsNil
{
    XCTAssertNil([_collection fetchObjectWithOID:@"123"], @"Fetching an object with an invalid OID should return nil!");
}

- (void)testFetchingObjectWithNonExistentOIDReturnsNil
{
    XCTAssertNil([_collection fetchObjectWithOID:@"012345678901234567890123"],
                @"Fetching an object with a non existent OID should return nil!");
}

- (void)testFetchingDictionaryObjectShouldNotReturnNil
{
    NSString *OID =  @"012345678901234567890123";
    NSDictionary *obj1 = @{@"_id" : OID,@"name" : @"foo", @"age" : @32};
    [_collection saveObject:obj1];
    NSDictionary *fetchedObj = [_collection fetchObjectWithOID:OID];
    XCTAssertNotNil(fetchedObj, @"Fetching dictionary object with existing OID should not return nil!");
    XCTAssertTrue([obj1 isEqualToDictionary:fetchedObj], @"Created object and fetched object should be equal!");
}

- (void)testFetchingObjectShouldNotReturnNil
{
    CustomArchivableClass *obj1 = [[CustomArchivableClass alloc]init];
    obj1.oid = @"012345678901234567890123";
    obj1.name = @"foo";
    obj1.age = @32;
    [_collection saveObject:obj1];
    CustomArchivableClass *fetchedObj = [_collection fetchObjectWithOID:obj1.oid];
    XCTAssertNotNil(fetchedObj, @"Fetching custom object with existing OID should not return nil!");
    XCTAssertTrue([[fetchedObj toDictionary] isEqualToDictionary:[obj1 toDictionary]], @"Created object and fetched object should be equal!");
}

- (void)testUpdatingObjectWithEmptyQueryAndHintsReturnsZero
{
    int updateCount = [_collection updateWithQuery:@{} hints:@{}];
    XCTAssertTrue(updateCount == 0, @"Update count with empty query and hints should be exactly 0!");
}

- (void)testUpdatingObjectWithNilQueryAndHintsReturnsZero
{
    int updateCount = [_collection updateWithQuery:nil hints:nil];
    XCTAssertTrue(updateCount == 0, @"Update count with nil query and hints should be exactly 0!");
}

- (void)testUpdatingObjectWithQueryReturnsCountOfOneRecord
{
    NSDictionary *obj1 = @{@"_id" : @"012345678901234567890123",@"name" : @"foo", @"age" : @32};
    NSDictionary *obj2 = @{@"_id" : @"123456789012345678901234", @"name": @"bar", @"age" : @25};
    [_collection saveObjects:@[obj1,obj2]];
    
    NSDictionary *query =
    @{
      @"_id": @"012345678901234567890123",
      @"$set" : @{@"age": @35}
     };
    int updateCount = [_collection updateWithQuery:query];
    XCTAssertEqual(updateCount, 1, @"Update query should update exactly 1 object!");
    NSDictionary *fetchedObject = [_collection fetchObjectWithOID:@"012345678901234567890123"];
    XCTAssertEqual([[fetchedObject objectForKey:@"age"]intValue], 35, @"Age of foo should be 35 after update!");
}

- (void)testUpdatingObjectWithQueryBuilderSucceeds
{
    NSDictionary *obj1 = @{@"_id" : @"012345678901234567890123",@"name" : @"foo", @"age" : @32};
    NSDictionary *obj2 = @{@"_id" : @"123456789012345678901234", @"name": @"bar", @"age" : @25};
    [_collection saveObjects:@[obj1,obj2]];
    EJDBQueryBuilder *builder = [[EJDBQueryBuilder alloc]init];
    [builder path:@"_id" matches:@"012345678901234567890123"];
    [builder set:@{@"age": @35}];
    int updateCount = [_collection updateWithQueryBuilder:builder];
    XCTAssertEqual(updateCount, 1, @"Update query should update exactly 1 object!");
    NSDictionary *fetchedObject = [_collection fetchObjectWithOID:@"012345678901234567890123"];
    XCTAssertEqual([[fetchedObject objectForKey:@"age"]intValue], 35, @"Age of foo should be 35 after update!");
}

- (void)testUpdatingObjectWithFIQueryBuilderSucceeds
{
    NSDictionary *obj1 = @{@"_id" : @"012345678901234567890123",@"name" : @"foo", @"age" : @32};
    NSDictionary *obj2 = @{@"_id" : @"123456789012345678901234", @"name": @"bar", @"age" : @25};
    [_collection saveObjects:@[obj1,obj2]];
    EJDBFIQueryBuilder *builder = [EJDBFIQueryBuilder build].match(@"_id",@"012345678901234567890123").set(@{@"age" : @35});
    int updateCount = [_collection updateWithQueryBuilder:builder];
    XCTAssertEqual(updateCount, 1, @"Update query should update exactly 1 object!");
    NSDictionary *fetchedObject = [_collection fetchObjectWithOID:@"012345678901234567890123"];
    XCTAssertEqual([[fetchedObject objectForKey:@"age"]intValue], 35, @"Age of foo should be 35 after update!");
}

- (void)testSettingIndexSuccess
{
    BOOL success = [_collection setIndexOption:EJDBIndexStringCaseInsensitive forFieldPath:@"name"];
    XCTAssertTrue(success, @"Index set should return YES!");
}

- (void)testCreatingCollectionSuccess
{
    NSError *error;
    EJDBCollection *collection = [[EJDBCollection alloc]initWithName:@"bar" db:_db];
    BOOL success = [collection openWithError:&error];
    XCTAssertTrue(success, @"Creating a new collection should return YES!");
    XCTAssertNil(error, @"Error object for creating a new collection should be nil!");
    [_db removeCollectionWithName:@"bar"];
}

- (void)testRetrievingCollectionSuccess
{
    EJDBCollection *collection = [EJDBCollection collectionWithName:@"foo" db:_db];
    XCTAssertNotNil(collection, @"Retrieving existing collection should not be nil!");
}

- (void)testRetrievingNonexistentCollectionReturnsNil
{
    EJDBCollection *collection = [EJDBCollection collectionWithName:@"noexist" db:_db];
    XCTAssertNil(collection, @"Retrieving a non existing collection should return nil!");
}

@end
