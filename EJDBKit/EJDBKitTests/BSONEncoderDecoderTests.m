#import "BSONEncoderDecoderTests.h"
#import "BSONEncoder.h"
#import "EJDBCollection.h"
#import "EJDBDatabase+DBTestExtensions.h"
#import "EJDBTestFixtures.h"
//#import "ArchivableClasses.h"

@interface BSONEncoderDecoderTests ()
@property (strong,nonatomic) EJDBDatabase *db;
@end

@implementation BSONEncoderDecoderTests

- (void)setUp
{
    [super setUp];
    _db = [EJDBDatabase createAndOpenDb];
}

- (void)tearDown
{
    [EJDBDatabase closeAndDeleteDb:_db];
    [super tearDown];
}

- (void)testEncodingDecodingA1Object
{
    NSDictionary *inDictionary = [EJDBTestFixtures complexDictionaries][0];
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    [collection saveObject:inDictionary];
    NSArray *results = [_db findObjectsWithQuery:@{@"name" : @"Антонов"} inCollection:collection error:NULL];
    NSDictionary *outDictionary = results[0];
    STAssertTrue([inDictionary isEqualToDictionary:outDictionary], @"Encoded and Decoded dictionaries should be the same!");
}

- (void)testEncodingDecodingA2Object
{
    NSDictionary *inDictionary = [EJDBTestFixtures complexDictionaries][1];
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    [collection saveObject:inDictionary];
    NSArray *results = [_db findObjectsWithQuery:@{@"name" : @"Адаманский"} inCollection:collection error:NULL];
    NSDictionary *outDictionary = results[0];
    STAssertTrue([inDictionary isEqualToDictionary:outDictionary], @"Encoded and Decoded dictionaries should be the same!");
}

- (void)testEncodingDate
{
    NSDate *date = [NSDate date];
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    NSDictionary *inDictionary = @{@"name" : @"foo",@"aDate": date};
    [collection saveObject:inDictionary];
    NSArray *results = [_db findObjectsWithQuery:@{@"name" : @"foo"} inCollection:collection error:NULL];
    NSDictionary *outDictionary = results[0];
    STAssertEquals(floor([[inDictionary objectForKey:@"aDate"]timeIntervalSince1970]),
                   floor([[outDictionary objectForKey:@"aDate"]timeIntervalSince1970]),
                   @"Date in and date out should be equal!");
}

- (void)testEncodingDecodingNSData
{
    NSData *imageDataIn = [NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]]
                                                          pathForResource:@"ejdblogo3" ofType:@"png"]];
    NSDictionary *inDictionary = @{@"name":@"logo",@"image": imageDataIn};
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    [collection saveObject:inDictionary];
    NSArray *results = [_db findObjectsWithQuery:@{@"name" : @"logo"} inCollection:collection error:NULL];
    NSDictionary *outDictionary = results[0];
    NSData *imageDataOut = [outDictionary objectForKey:@"image"];
    STAssertTrue([imageDataIn isEqualToData:imageDataOut], @"Image in and Image out data should be equal!");
}

- (void)testEncodingDecodingNSNull
{
    NSDictionary *inDictionary = @{@"name": @"null obj",@"nullval":[NSNull null]};
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    [collection saveObject:inDictionary];
    NSArray *results = [_db findObjectsWithQuery:@{@"name" : @"null obj"} inCollection:collection error:NULL];
    NSDictionary *outDictionary = results[0];
    STAssertTrue([[inDictionary objectForKey:@"nullval"]
                  isEqual:[outDictionary objectForKey:@"nullval"]], @"Out null obj should match in!");
}

- (void)testShouldEncodeDecodeCustomClass
{
    CustomArchivableClass *obj =  [EJDBTestFixtures validArchivableClass];
    obj.name = @"foo";
    obj.age = @22;
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    [collection saveObject:obj];
    NSArray *results = [_db findObjectsWithQuery:@{@"name" : @"foo"} inCollection:collection error:NULL];
    CustomArchivableClass *outObj = results[0];
    STAssertTrue([outObj isKindOfClass:[CustomArchivableClass class]],@"Saved object should be an Instance of CustomArchivableClass!");
}

/*
 Gotcha here!!! Don't assume that the custom class is automatically created! You must
 create it yourself after fetching the result!
*/
- (void)testShouldEncodeDecodeNestedCustomClass
{
    CustomArchivableClass *customObj = [EJDBTestFixtures validArchivableClass];
    customObj.name = @"foo";
    customObj.age  = @22;
    NSDictionary *obj = @{@"SomeKey": @"SomeValue", @"customObject" : customObj};
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    [collection saveObject:obj];
    NSArray *results = [_db findObjectsWithQuery:@{@"SomeKey" : @"SomeValue"} inCollection:collection error:NULL];
    NSDictionary *savedObj = results[0];
    CustomArchivableClass *customSavedObj = [[CustomArchivableClass alloc]init];
    [customSavedObj fromDictionary:[savedObj objectForKey:@"customObject"]];
    STAssertTrue([customObj.name isEqual:customSavedObj.name] &&
                 [customObj.age isEqual:customSavedObj.age] &&
                 [customObj.type isEqual:customSavedObj.type], @"Encoded custom object should equal decoded custom object!");
}


- (void)testBogusOIDClassShouldFail
{
    BogusOIDClass *bogusObj =  [EJDBTestFixtures bogusOIDClass];
    bogusObj.name = @"bogus";
    bogusObj.age = @1;
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    STAssertFalse([collection saveObject:bogusObj], @"Saving an object with an invalid OID should fail!");
}

- (void)testSavingNonSupportedObjectShouldFail
{
    NSSet *unsupportedObj = [NSSet setWithObject:@"Something"];
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    ;
    STAssertFalse([collection saveObject:unsupportedObj], @"Saving an unsupported object should fail!");
}

/*
 Unfortunately, lcov doesn't see this as being covered though if you step through the code in debugger it certainly
 does throw an exception!
*/
- (void)testInvalidOIDShouldThrowException
{
    NSDictionary *inDictionary = @{@"_id": @"123"};
    BSONEncoder *encoder = [[BSONEncoder alloc]init];
    STAssertThrows([encoder encodeDictionary:inDictionary], @"Should throw an exception when attempting to create an object with an Invalid OID!");
}

- (void)testShouldThrowExceptionOnUnsupportedType
{
    NSDictionary *inDictionary = @{@"unsupported type" : [NSSet setWithArray:@[@1,@2]]};
    BSONEncoder *encoder = [[BSONEncoder alloc]init];
    STAssertThrows([encoder encodeDictionary:inDictionary], @"Should throw an exception when attempting to create an object with an unsupported class!");
}

@end