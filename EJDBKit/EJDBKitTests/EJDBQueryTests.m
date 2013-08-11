#import "EJDBQueryTests.h"
#import "EJDBDatabase+DBTestExtensions.h"
#import "EJDBQuery.h"
#import "EJDBCollection.h"
#import "EJDBTestFixtures.h"

@interface EJDBQueryTests ()
@property (strong,nonatomic) EJDBDatabase *db;
@property (strong,nonatomic) EJDBCollection *collection;
@end


@implementation EJDBQueryTests

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

- (void)testFetchCount
{
    [_collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:_collection query:@{@"name":@{@"$begin": @"j"}}];
    STAssertTrue([query fetchCount] == 2, @"Fetch count should return exactly 2 records!");
}

- (void)testFetchCountWithError
{
    NSError *error;
    [_collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:_collection query:@{@"$begin" : @"j"}];
    [query fetchCountWithError:&error];
    STAssertNotNil(error, @"Fetch count error should not be nil!");
}

- (void)testFetchObject
{
    NSString *name = [[EJDBTestFixtures simpleDictionaries][0] objectForKey:@"name"];
    [_collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:_collection
                                                      query:@{@"name":@{@"$begin":@"j"}}
                                                      hints:@{@"$fields":@{@"name": @1}}];
    NSDictionary *object = [query fetchObject];
    STAssertNotNil(object, @"Fetched object should not be nil!");
    STAssertTrue([[object objectForKey:@"name"] isEqualToString:name], @"Saved name should equal fetched name!");
}

- (void)testFetchObjectWithError
{
    NSError *error;
    [_collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:_collection
                                                      query:@{@"$name":@{@"$begin":@"j"}}
                                                      hints:@{@"$fields":@{@"name": @1}}];
    NSDictionary *object = [query fetchObjectWithError:&error];
    STAssertNil(object, @"Fetched object should be nil!");
    STAssertNotNil(error, @"Fetched object error should not be nil!");
}

- (void)testFetchObjects
{
    [_collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:_collection query:@{@"name": @{@"$begin":@"j"}}];
    NSArray *results = [query fetchObjects];
    STAssertTrue([results count] == 2, @"Fetched objects count should be exactly 2!");
    STAssertTrue([query recordCount] == 2, @"Record count should be exactly 2!");
}

- (void)testFetchObjectsWithError
{
    NSError *error;
    [_collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:_collection query:@{@"$name": @{@"$begin":@"j"}}];
    NSArray *results = [query fetchObjectsWithError:&error];
    STAssertNil(results, @"Results should be nil!");
    STAssertNotNil(error, @"Fetched objects error should not be nil!");
}

- (void)testMultipleFetchesSuccess
{
    [_collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:_collection query:nil];
    NSArray *results = [query fetchObjects];
    STAssertTrue([results count] == 3, @"First fetch should return exactly 3 results!");
    [_collection saveObject:@{@"name": @"foo"}];
    NSArray *results2 = [query fetchObjects];
    STAssertTrue([results2 count] == 4, @"Second fetch should return exactly 4 results!");
}

- (void)testRecordCount
{
    [_collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:_collection query:nil];
    [query fetchObjects];
    STAssertTrue([query recordCount] == 3, @"Record count should be exactly 3!");
}

@end