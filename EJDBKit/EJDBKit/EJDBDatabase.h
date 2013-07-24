#import <Foundation/Foundation.h>
#include <tcejdb/ejdb.h>

@class EJDBCollection;

@interface EJDBDatabase : NSObject

@property (assign,nonatomic,readonly) EJDB *db;

- (id)initWithPath:(NSString *)path;

- (BOOL)open;

- (BOOL)openWithMode:(int)mode;

- (EJDBCollection *)collectionWithName:(NSString *)name;

- (EJDBCollection *)createCollectionWithName:(NSString *)name;

- (EJDBCollection *)createCollectionWithName:(NSString *)name options:(EJCOLLOPTS *)options;

- (void)close;

@end
