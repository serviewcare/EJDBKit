#import "EJDBCollectionTests.h"
#import "EJDBDatabase+DBTestExtensions.h"
#import "EJDBCollection.h"
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
    [super tearDown];
}

- (void)testSaveObjectSuccessfully
{
    NSDictionary *obj1 = [EJDBTestFixtures simpleDictionaries][0];
    BOOL success = [_collection saveObject:obj1];
    STAssertTrue(success, @"object should be saved successfully!");
}
 
- (void)testSaveObjectsSuccessfully
{
    BOOL success = [_collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    STAssertTrue(success, @"objects should be saved successfully!");
}

- (void)testRemoveDictionaryWithOIDSucceeds
{
    [_collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    NSArray *results = [_db findObjectsWithQuery:@{@"name" : @"joe blow"} inCollection:_collection error:NULL];
    NSDictionary *fooObj = results[0];
    BOOL success = [_collection removeObjectWithOID:[fooObj objectForKey:@"_id"]];
    STAssertTrue(success, @"Should remove joe blow dictionary successfully!");
    NSArray *resultsWithoutFoo = [_db findObjectsWithQuery:@{@"name" : @"joe blow"} inCollection:_collection error:NULL];
    STAssertTrue([resultsWithoutFoo count] == 0, @"Results for joe blow query should return 0!");
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
    STAssertTrue(success, @"Should remove foo object successfully!");
    NSArray *resultsWithoutFoo = [_db findObjectsWithQuery:@{@"name" : @"foo"} inCollection:_collection error:NULL];
    STAssertTrue([resultsWithoutFoo count] == 0, @"Results for foo query should return 0!");
}

- (void)testRemovingUnsupportedObjectFails
{
    NSSet *unsupportedObj = [NSSet setWithObject:@"Unsupported"];
    BOOL success = [_collection removeObject:unsupportedObj];
    STAssertFalse(success, @"Removing an Unsupported object should fail!");
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
    STAssertFalse(success, @"Removing a dictionary without an OID should fail!");
}

- (void)testProvidingInvalidOIDForRemovalOfObjectFails
{
    STAssertFalse([_collection removeObjectWithOID:@"123"], @"Trying to remove an object by supplying an invalid OID should fail!");
}

- (void)testFetchingObjectWithInvalidOIDReturnsNil
{
    STAssertNil([_collection fetchObjectWithOID:@"123"], @"Fetching an object with an invalid OID should return nil!");
}

- (void)testFetchingObjectWithNonExistentOIDReturnsNil
{
    STAssertNil([_collection fetchObjectWithOID:@"012345678901234567890123"],
                @"Fetching an object with a non existent OID should return nil!");
}

- (void)testFetchingDictionaryObjectShouldNotReturnNil
{
    NSString *OID =  @"012345678901234567890123";
    NSDictionary *obj1 = @{@"_id" : OID,@"name" : @"foo", @"age" : @32};
    [_collection saveObject:obj1];
    NSDictionary *fetchedObj = [_collection fetchObjectWithOID:OID];
    STAssertNotNil(fetchedObj, @"Fetching dictionary object with existing OID should not return nil!");
    STAssertTrue([obj1 isEqualToDictionary:fetchedObj], @"Created object and fetched object should be equal!");
}

- (void)testFetchingObjectShouldNotReturnNil
{
    CustomArchivableClass *obj1 = [[CustomArchivableClass alloc]init];
    obj1.oid = @"012345678901234567890123";
    obj1.name = @"foo";
    obj1.age = @32;
    [_collection saveObject:obj1];
    CustomArchivableClass *fetchedObj = [_collection fetchObjectWithOID:obj1.oid];
    STAssertNotNil(fetchedObj, @"Fetching custom object with existing OID should not return nil!");
    STAssertTrue([[fetchedObj toDictionary] isEqualToDictionary:[obj1 toDictionary]], @"Created object and fetched object should be equal!");
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
    STAssertEquals(updateCount, 1, @"Update query should update exactly 1 object!");
    NSDictionary *fetchedObject = [_collection fetchObjectWithOID:@"012345678901234567890123"];
    STAssertEquals([[fetchedObject objectForKey:@"age"]intValue], 35, @"Age of foo should be 35 after update!");
}

- (void)testSettingIndexSuccess
{
    BOOL success = [_collection setIndexOption:EJDBIndexStringCaseInsensitive forFieldPath:@"name"];
    STAssertTrue(success, @"Index set should return YES!");
}

- (void)testCreatingCollectionSuccess
{
    NSError *error;
    EJDBCollection *collection = [[EJDBCollection alloc]initWithName:@"bar" db:_db];
    BOOL success = [collection openWithError:&error];
    STAssertTrue(success, @"Creating a new collection should return YES!");
    STAssertNil(error, @"Error object for creating a new collection should be nil!");
    [_db removeCollectionWithName:@"bar"];
}

- (void)testRetrievingCollectionSuccess
{
    EJDBCollection *collection = [EJDBCollection collectionWithName:@"foo" db:_db];
    STAssertNotNil(collection, @"Retrieving existing collection should not be nil!");
}

- (void)testRetrievingNonexistentCollectionReturnsNil
{
    EJDBCollection *collection = [EJDBCollection collectionWithName:@"noexist" db:_db];
    STAssertNil(collection, @"Retrieving a non existing collection should return nil!");
}

@end
