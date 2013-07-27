#import "EJDBDatabase+DBTestExtensions.h"

@implementation EJDBDatabase (DBTestExtensions)

+ (EJDBDatabase *)createAndOpenDb
{
    EJDBDatabase *db = [[EJDBDatabase alloc]initWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"ejdbtest"] dbFileName:@"test.db"];
    [db openWithError:NULL];
    return db;
}

+ (void)closeAndDeleteDb:(EJDBDatabase *)db
{
    [db close];
    [[NSFileManager defaultManager] removeItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"ejdbtest"]
                                               error:NULL];
    db = nil;
}


@end
