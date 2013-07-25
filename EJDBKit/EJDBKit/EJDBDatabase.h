#import <Foundation/Foundation.h>
#include <tcejdb/ejdb.h>

@class EJDBCollection;
@class EJDBQuery;

@interface EJDBDatabase : NSObject

@property (assign,nonatomic,readonly) EJDB *db;

- (id)initWithPath:(NSString *)path;

- (BOOL)open;

- (BOOL)openWithMode:(int)mode;

- (EJDBCollection *)collectionWithName:(NSString *)name;

- (EJDBCollection *)createCollectionWithName:(NSString *)name;

- (EJDBCollection *)createCollectionWithName:(NSString *)name options:(EJCOLLOPTS *)options;

- (EJDBQuery *)createQuery:(NSDictionary *)query forCollection:(EJDBCollection *)collection error:(__autoreleasing NSError *)error;

- (void)close;

@end
