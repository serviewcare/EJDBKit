#import "EJDBDatabaseTests.h"
#import "EJDBDatabase.h"
#import "EJDBCollection.h"
#import "EJDBQuery.h"
#import "EJDBTestFixtures.h"

@interface EJDBDatabaseTests ()
@property (strong,nonatomic) EJDBDatabase *db;
@property (copy,nonatomic) NSString *dbParentDir;
@property (copy,nonatomic) NSString *dbFileName;
@end

@implementation EJDBDatabaseTests

- (void)setUp
{
    [super setUp];
    _dbParentDir = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"ejdbtest"]copy];
    _dbFileName = [@"test.db" copy];
    _db = [[EJDBDatabase alloc]initWithPath:_dbParentDir dbFileName:_dbFileName];
    BOOL success = [_db openWithError:NULL];
    STAssertTrue(success, @"Db should open successfully!");
}

- (void)tearDown
{
    [_db removeCollectionWithName:@"foo"];
    [_db close];
    [[NSFileManager defaultManager] removeItemAtPath:_dbParentDir error:nil];
    _dbParentDir = nil;
    _dbFileName = nil;
    _db = nil;
    [super tearDown];
}

- (void)testFindWithQueryFails
{
    NSError *error;
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    NSArray *objects = [_db findObjectsWithQuery:@{@"$name" : @"joe blow"} inCollection:collection error:&error];
    STAssertNil(objects, @"Objects should be nil for bad query!");
    STAssertNotNil(error, @"Error for bad query should not be nil!");
}

- (void)testCreateQueryFails
{
    NSError *error;
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    EJDBQuery *query = [_db createQuery:@{@"$name" : @"joe blow"} forCollection:collection error:&error];
    
    STAssertNil([query fetchObjectWithError:&error], @"Query object for bad query should be nil!");
    STAssertNotNil(error, @"Error for bad query creation should not be nil!");
}

- (void)testTransactionFails
{
    NSError *error;
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    BOOL success = [_db transactionInCollection:collection error:&error transaction:^BOOL(EJDBCollection *collection, NSError *__autoreleasing *error) {
        [_db findObjectsWithQuery:@{@"$name" : @"joe blow"} inCollection:collection error:error];
        STAssertNotNil(*error, @"Error in transaction block should not be nil!");
        return YES;
    }];
    STAssertFalse(success, @"Failed transaction should return NO!");
    STAssertNotNil(error, @"Error from transaction should not be nil!");
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

- (void)testCollectionNames
{
    [_db ensureCollectionWithName:@"a" error:NULL];
    [_db ensureCollectionWithName:@"b" error:NULL];
    NSArray *collectionNames = [_db collectionNames];
    STAssertTrue([collectionNames count] == 2, @"Collection count should be exactly 2!.");
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
    [collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    NSArray *results = [_db findObjectsWithQuery:@{@"name":@{@"$begin":@"j"}} inCollection:collection error:NULL];
    STAssertNotNil(results, @"results should not be nil!");
    STAssertTrue([results count] == 2, @"results count should be exactly 2");
}

- (void)testFindObjectsWithHintsSuccessfully
{
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    [collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    NSArray *results = [_db findObjectsWithQuery:@{@"name":@{@"$begin":@"j"}}
                         hints:@{@"$fields":@{@"name": @YES}}
                         inCollection:collection error:NULL];
    STAssertNotNil(results, @"results should not be nil!");
    STAssertTrue([results count] == 2, @"results count should be exactly 2");
    STAssertNil([results[0] valueForKey:@"address"], @"address field should not exist!");
}

- (void)testCreatedQueryNotNil
{
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    EJDBQuery *query = [_db createQuery:@{@"name" : @"joe blow"} forCollection:collection error:NULL];
    STAssertNotNil(query, @"Query should not be nil!");
}

- (void)testTransactionCommit
{
    NSError *error;
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    [_db transactionInCollection:collection error:&error transaction:^BOOL(EJDBCollection *collection,NSError **error) {
        NSArray *simpleDictionaries = [EJDBTestFixtures simpleDictionaries];
        NSMutableDictionary *simpleDict2 = [NSMutableDictionary dictionaryWithDictionary:simpleDictionaries[1]];
        [simpleDict2 setObject:@36 forKey:@"age"];
        [collection saveObjects:@[simpleDictionaries[0],simpleDict2]];
        STAssertNil(*error, @"Error should be nil!");
        return YES;
    }];
    
    NSArray *results = [_db findObjectsWithQuery:@{@"age" : @36} inCollection:collection error:NULL];
    STAssertTrue([results count] == 2, @"Results of query after commiting transaction should be exactly 2!");
}

- (void)testTransactionAbort
{
    NSError *error;
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    [_db transactionInCollection:collection error:&error transaction:^BOOL(EJDBCollection *collection,NSError **error) {
        [collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
        STAssertNil(*error, @"Error should be nil!");
        return NO;
    }];
    NSArray *results = [_db findObjectsWithQuery:@{@"age" : @35} inCollection:collection error:NULL];
    STAssertTrue([results count] == 0, @"Results of query after aborting transaction should be exactly 0!");
}

@end
