#import "EJDBDatabaseTests.h"
#import "EJDBDatabase.h"
#import "EJDBCollection.h"
#import "EJDBQuery.h"
#import "EJDBQueryBuilder.h"
#import "EJDBFIQueryBuilder.h"
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
    XCTAssertTrue(success, @"Db should open successfully!");
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
    XCTAssertNil(objects, @"Objects should be nil for bad query!");
    XCTAssertNotNil(error, @"Error for bad query should not be nil!");
}

- (void)testCreateQueryFails
{
    NSError *error;
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    EJDBQuery *query = [_db createQuery:@{@"$name" : @"joe blow"} hints:nil forCollection:collection];
    XCTAssertNil([query fetchObjectWithError:&error], @"Query object for bad query should be nil!");
    XCTAssertNotNil(error, @"Error for bad query creation should not be nil!");
}

- (void)testTransactionFails
{
    NSError *error;
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    BOOL success = [_db transactionInCollection:collection error:&error transaction:^BOOL(EJDBCollection *collection, NSError *__autoreleasing *error) {
        [_db findObjectsWithQuery:@{@"$name" : @"joe blow"} inCollection:collection error:error];
        XCTAssertNotNil(*error, @"Error in transaction block should not be nil!");
        return YES;
    }];
    XCTAssertFalse(success, @"Failed transaction should return NO!");
    XCTAssertNotNil(error, @"Error from transaction should not be nil!");
}


- (void)testDbIsOpen
{
    XCTAssertTrue([_db isOpen], @"Database should be open!");
}

- (void)testCollectionDoesNotExist
{
    EJDBCollection *collection = [_db collectionWithName:@"foo"];
    XCTAssertNil(collection, @"Collection should not exist!");
}

- (void)testCollectionCreationSuccess
{
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    XCTAssertNotNil(collection, @"Collection should be created with success!");
}

- (void)testCollectionRemovalSuccess
{
    [_db ensureCollectionWithName:@"foo" error:NULL];
    [_db removeCollectionWithName:@"foo"];
    XCTAssertNil([_db collectionWithName:@"foo"], @"Collection should not exist!");
}

- (void)testCollectionNames
{
    [_db ensureCollectionWithName:@"a" error:NULL];
    [_db ensureCollectionWithName:@"b" error:NULL];
    NSArray *collectionNames = [_db collectionNames];
    XCTAssertTrue([collectionNames count] == 2, @"Collection count should be exactly 2!.");
}

- (void)testOpenCollections
{
    [_db ensureCollectionWithName:@"a" error:NULL];
    [_db ensureCollectionWithName:@"b" error:NULL];
    NSArray *collections = [_db collections];
    XCTAssertTrue([collections count] == 2, @"Collection list must have exactly 2 collections!");
}

- (void)testFindObjectsSuccessfully
{
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    [collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    NSArray *results = [_db findObjectsWithQuery:@{@"name":@{@"$begin":@"j"}} inCollection:collection error:NULL];
    XCTAssertNotNil(results, @"results should not be nil!");
    XCTAssertTrue([results count] == 2, @"results count should be exactly 2");
}

- (void)testFindObjectsWithHintsSuccessfully
{
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    [collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    NSArray *results = [_db findObjectsWithQuery:@{@"name":@{@"$begin":@"j"}}
                         hints:@{@"$fields":@{@"name": @YES}}
                         inCollection:collection error:NULL];
    XCTAssertNotNil(results, @"results should not be nil!");
    XCTAssertTrue([results count] == 2, @"results count should be exactly 2");
    XCTAssertNil([results[0] valueForKey:@"address"], @"address field should not exist!");
}

- (void)testFindObjectsWithQueryBuilderSuccessfully
{
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    [collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    EJDBQueryBuilder *builder = [[EJDBQueryBuilder alloc]init];
    [builder path:@"name" beginsWith:@"j"];
    [builder onlyFields:@[@"name"]];
    NSArray *results = [_db findObjectsWithQueryBuilder:builder inCollection:collection error:NULL];
    XCTAssertNotNil(results, @"results should not be nil!");
    XCTAssertTrue([results count] == 2, @"results count should be exactly 2");
    XCTAssertNil([results[0] valueForKey:@"address"], @"address field should not exist!");
}

- (void)testFindObjectsWithFIQueryBuilderSuccessfully
{
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    [collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    EJDBFIQueryBuilder *builder = [EJDBFIQueryBuilder build].beginsWith(@"name",@"j")
                                                            .onlyFields(@[@"name"]);
    NSArray *results = [_db findObjectsWithQueryBuilder:builder inCollection:collection error:NULL];
    XCTAssertNotNil(results, @"results should not be nil!");
    XCTAssertTrue([results count] == 2, @"results count should be exactly 2");
    XCTAssertNil([results[0] valueForKey:@"address"], @"address field should not exist!");
}

- (void)testCreatedQueryNotNil
{
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    EJDBQuery *query = [_db createQuery:@{@"name" : @"joe blow"} hints:nil forCollection:collection];
    XCTAssertNotNil(query, @"Query should not be nil!");
}

- (void)testQueryCreatedWithQueryBuilderNotNil
{
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    EJDBQueryBuilder *builder = [[EJDBQueryBuilder alloc] init];
    [builder path:@"name" matches:@"joe blow"];
    EJDBQuery *query = [_db createQueryWithBuilder:builder forCollection:collection];
    XCTAssertNotNil(query, @"Query should not be nil!");
}

- (void)testQueryCreatedWithFIQueryBuilderNotNil
{
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    EJDBFIQueryBuilder *builder = [EJDBFIQueryBuilder build].match(@"name",@"joe blow");
    EJDBQuery *query = [_db createQueryWithBuilder:builder forCollection:collection];
    XCTAssertNotNil(query, @"Query should not be nil!");
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
        XCTAssertNil(*error, @"Error should be nil!");
        return YES;
    }];
    
    NSArray *results = [_db findObjectsWithQuery:@{@"age" : @36} inCollection:collection error:NULL];
    XCTAssertTrue([results count] == 2, @"Results of query after commiting transaction should be exactly 2!");
}

- (void)testTransactionAbort
{
    NSError *error;
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    [_db transactionInCollection:collection error:&error transaction:^BOOL(EJDBCollection *collection,NSError **error) {
        [collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
        XCTAssertNil(*error, @"Error should be nil!");
        return NO;
    }];
    NSArray *results = [_db findObjectsWithQuery:@{@"age" : @35} inCollection:collection error:NULL];
    XCTAssertTrue([results count] == 0, @"Results of query after aborting transaction should be exactly 0!");
}

- (void)testExportAsBSONSuccess
{
    EJDBCollection *collectionA = [_db ensureCollectionWithName:@"a" error:NULL];
    EJDBCollection *collectionB = [_db ensureCollectionWithName:@"b" error:NULL];
    [collectionA saveObjects:[EJDBTestFixtures simpleDictionaries]];
    [collectionB saveObjects:[EJDBTestFixtures complexDictionaries]];
    NSString *exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"ejdbtest/export"];
    BOOL success = [_db exportCollections:@[@"a",@"b"] toDirectory:exportPath asJSON:NO];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    [fileManager fileExistsAtPath:exportPath isDirectory:&isDir];
    NSArray *exportDirContents = [fileManager contentsOfDirectoryAtPath:exportPath error:NULL];
    XCTAssertTrue(success, @"Export as BSON should return success!");
    XCTAssertTrue(isDir, @"Export directory should exist!");
    XCTAssertTrue([exportDirContents count] == 4, @"BSON export directory should contain exactly 4 files!");
}

- (void)testExportAsJSONSuccess
{
    EJDBCollection *collectionA = [_db ensureCollectionWithName:@"a" error:NULL];
    EJDBCollection *collectionB = [_db ensureCollectionWithName:@"b" error:NULL];
    [collectionA saveObjects:[EJDBTestFixtures simpleDictionaries]];
    [collectionB saveObjects:[EJDBTestFixtures complexDictionaries]];
    NSString *exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"ejdbtest/export"];
    BOOL success = [_db exportCollections:@[@"a",@"b"] toDirectory:exportPath asJSON:YES];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    [fileManager fileExistsAtPath:exportPath isDirectory:&isDir];
    NSArray *exportDirContents = [fileManager contentsOfDirectoryAtPath:exportPath error:NULL];
    XCTAssertTrue(success, @"Export as JSON should return success!");
    XCTAssertTrue(isDir, @"Export directory should exist!");
    XCTAssertTrue([exportDirContents count] == 4, @"JSON export directory should contain exactly 4 files!");
}

- (void)testExportAllSuccess
{
    EJDBCollection *collectionA = [_db ensureCollectionWithName:@"a" error:NULL];
    EJDBCollection *collectionB = [_db ensureCollectionWithName:@"b" error:NULL];
    [collectionA saveObjects:[EJDBTestFixtures simpleDictionaries]];
    [collectionB saveObjects:[EJDBTestFixtures complexDictionaries]];
    NSString *exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"ejdbtest/export"];
    BOOL success = [_db exportAllCollectionsToDirectory:exportPath asJSON:NO];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    [fileManager fileExistsAtPath:exportPath isDirectory:&isDir];
    NSArray *exportDirContents = [fileManager contentsOfDirectoryAtPath:exportPath error:NULL];
    XCTAssertTrue(success, @"Export all collections as BSON should return success!");
    XCTAssertTrue(isDir, @"Export directory should exist!");
    XCTAssertTrue([exportDirContents count] == 4, @"BSON export directory should contain exactly 4 files!");
}

- (void)testImportSuccess
{
    NSString *bundlePath = [[NSBundle bundleForClass:[self class]]bundlePath];
    NSString *importPath;
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    importPath = [bundlePath stringByAppendingPathComponent:@"import"];
#else
    importPath = [bundlePath stringByAppendingPathComponent:@"Contents/Resources/import"];
#endif
    BOOL success = [_db importCollections:@[@"a",@"b"] fromDirectory:importPath options:EJDBImportReplace];
    XCTAssertTrue(success, @"Import of collections a and b should be successful!");
}

- (void)testImportFail
{
    NSError *error;
    NSString *bundlePath = [[NSBundle bundleForClass:[self class]]bundlePath];
    NSString *importPath = [bundlePath stringByAppendingPathComponent:@"pathNotExists"];
    BOOL success = [_db importCollections:@[@"a",@"b"] fromDirectory:importPath options:EJDBImportReplace];
    XCTAssertFalse(success, @"Import of collections a and b from non-existent directory should not be successful!");
    [_db populateError:&error];
    XCTAssertNotNil(error, @"Error for failed import should not be nil!");
}

- (void)testImportAllSuccess
{
    NSString *bundlePath = [[NSBundle bundleForClass:[self class]]bundlePath];
    NSString *importPath;
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    importPath = [bundlePath stringByAppendingPathComponent:@"import"];
#else
    importPath = [bundlePath stringByAppendingPathComponent:@"Contents/Resources/import"];
#endif
    BOOL success = [_db importAllCollectionsFromDirectory:importPath options:EJDBImportReplace];
    XCTAssertTrue(success, @"Import of collections a and b from non-existent directory should not be successful!");
}

@end
