#import "EJDBDatabaseTests.h"
#import "EJDBDatabase.h"
#import "EJDBCollection.h"
#import "BSONNumber.h"


@interface EJDBDatabaseTests ()
@property (strong,nonatomic) EJDBDatabase *db;
@end

@implementation EJDBDatabaseTests

- (void)setUp
{
    [super setUp];
    NSString *dbPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.ejdb"];
    [[NSFileManager defaultManager] removeItemAtPath:dbPath error:nil];
    _db = [[EJDBDatabase alloc]initWithPath:dbPath];
    BOOL success = [_db openWithError:NULL];
    STAssertTrue(success, @"Db should open successfully!");
}

- (void)tearDown
{
    [_db removeCollectionWithName:@"foo"];
    [_db close];
    [super tearDown];
}

- (void)testDbIsOpen
{
    STAssertTrue([_db isOpen], @"Database should be open!");
}

- (void)testCollectionDoesNotExist
{
    EJDBCollection *collection = [_db collectionWithName:@"foo"];
    STAssertNil(collection, @"Collection should not exist!");
}

- (void)testCollectionCreationSuccess
{
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    STAssertNotNil(collection, @"Collection should be created with success!");
}

- (void)testCollectionRemovalSuccess
{
    [_db ensureCollectionWithName:@"foo" error:NULL];
    [_db removeCollectionWithName:@"foo"];
    STAssertNil([_db collectionWithName:@"foo"], @"Collection should not exist!");
}

- (void)testOpenCollections
{
    [_db ensureCollectionWithName:@"a" error:NULL];
    [_db ensureCollectionWithName:@"b" error:NULL];
    NSArray *collections = [_db collections];
    STAssertTrue([collections count] == 2, @"Collection list must have exactly 2 collections!");
}

- (void)testFindObjectsSuccessfully
{
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    NSDictionary *obj1 = @{@"name" : @"joe blow", @"address" : @"21 jump street"};
    NSDictionary *obj2 = @{@"name" : @"jane doe", @"address": @"13 elm street"};
    [collection saveObjects:@[obj1,obj2]];
    NSArray *results = [_db findObjectsWithQuery:@{@"name":@{@"$begin":@"j"}} inCollection:collection error:NULL];
    STAssertNotNil(results, @"results should not be nil!");
    STAssertTrue([results count] == 2, @"results count should be exactly 2");
}

- (void)testFindObjectsWithHintsSuccessfully
{
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    NSDictionary *obj1 = @{@"name" : @"joe blow", @"address" : @"21 jump street"};
    NSDictionary *obj2 = @{@"name" : @"jane doe", @"address": @"13 elm street"};
    [collection saveObjects:@[obj1,obj2]];
    NSArray *results = [_db findObjectsWithQuery:@{@"name":@{@"$begin":@"j"}}
                         hints:@{@"$fields":@{@"name": [BSONNumber intNumberFromNumber:@1]}}
                         inCollection:collection error:NULL];
    STAssertNotNil(results, @"results should not be nil!");
    STAssertTrue([results count] == 2, @"results count should be exactly 2");
    STAssertNil([results[0] valueForKey:@"address"], @"address field should not exist!");
}


//Maybe the next 2 methods should be brought into collection tests instead of here.
- (void)testSaveObjectSuccessfully
{
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    NSDictionary *obj1 = @{@"name" : @"joe blow", @"address" : @"21 jump street"};
    BOOL success = [collection saveObject:obj1];
    STAssertTrue(success, @"object should be saved successfully!");
}

- (void)testSaveObjectsSuccessfully
{
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    NSDictionary *obj1 = @{@"name" : @"joe blow", @"address" : @"21 jump street"};
    NSDictionary *obj2 = @{@"name" : @"jane doe", @"address": @"13 elm street"};
    BOOL success = [collection saveObjects:@[obj1,obj2]];
    STAssertTrue(success, @"objects should be saved successfully!");
}


@end
