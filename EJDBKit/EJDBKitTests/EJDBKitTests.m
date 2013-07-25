#import "EJDBKitTests.h"
#import "EJDBKit.h"

@interface EJDBKitTests ()
@property (strong,nonatomic) EJDBDatabase *db;
@end

@implementation EJDBKitTests

- (void)setUp
{
    [super setUp];
    NSString *dbPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.ejdb"];
    [[NSFileManager defaultManager] removeItemAtPath:dbPath error:nil];
    _db = [[EJDBDatabase alloc]initWithPath:dbPath];
    BOOL success = [_db open];
    STAssertTrue(success, @"Db should open successfully!");
    
}

- (void)tearDown
{
    [_db close];
    
    [super tearDown];
}

- (NSDictionary *)simpleObjectTestDictionary
{
    return
    @{
      @"name" : @"Jeebus Jehosophat",
      @"age"  : [BSONNumber intNumberFromNumber:@2000],
      @"date" : [NSDate date],
      @"isMarried" : [BSONNumber boolNumberFromNumber:[NSNumber numberWithBool:YES]],
      @"money" : [BSONNumber doubleNumberFromNumber:@123.456]
    };
}

- (NSDictionary *)complexObjectTestDictionary
{
    return
    @{
      @"name" : @"Jeebus Jehosophat",
      @"age"  : [BSONNumber intNumberFromNumber:@2000],
      @"date" : [NSDate date],
      @"isMarried" : [BSONNumber boolNumberFromNumber:[NSNumber numberWithBool:YES]],
      @"money" : [BSONNumber doubleNumberFromNumber:@123.456],
      @"address" :
           @{
              @"street" : @"21 Jump street",
              @"city" : @"Heaven"
            },
      @"aScalarArray" :
           @[
              [BSONNumber intNumberFromNumber:@1],
              [BSONNumber intNumberFromNumber:@2]
            ],
      @"anObjectArray" :
           @[
              @{@"obj1": @"val1"},
              @{@"obj2" : @"val2"}
            ]
     };
}

- (void)testCollectionDoesNotExist
{
    EJDBCollection *collection = [_db collectionWithName:@"foo"];
    STAssertNil(collection, @"collection should be nil!");
}

- (void)testCollectionCreatedSuccessfully
{
    EJDBCollection *fooCollection = [_db createCollectionWithName:@"foo" options:NULL];
    STAssertNotNil(fooCollection, @"collection should not be nil!");
}

- (void)testSimpleObjectSavedSuccessfully
{
    EJDBCollection *fooCollection = [_db createCollectionWithName:@"foo" options:NULL];
    BSONObject *obj = [[BSONObject alloc]init];
    [obj encodeDictionary:[self simpleObjectTestDictionary]];
    BOOL success = [fooCollection saveObject:obj];
    STAssertTrue(success, @"Simple object should save successfully!");
}

- (void)testComplexObjectSavedSuccessfully
{
    EJDBCollection *fooCollection = [_db createCollectionWithName:@"foo" options:NULL];
    BSONObject *obj = [[BSONObject alloc]init];
    [obj encodeDictionary:[self complexObjectTestDictionary]];
    BOOL success = [fooCollection saveObject:obj];
    STAssertTrue(success, @"Complex object should save successfully!");
}


//ejdbexport(_db.db, "/var/tmp/ejdbexport", NULL, JBJSONEXPORT, NULL);

@end
