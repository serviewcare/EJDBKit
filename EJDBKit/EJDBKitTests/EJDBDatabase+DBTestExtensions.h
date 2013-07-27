#import "EJDBDatabase.h"

@interface EJDBDatabase (DBTestExtensions)

+ (EJDBDatabase *)createAndOpenDb;

+ (void)closeAndDeleteDb:(EJDBDatabase *)db;

@end
