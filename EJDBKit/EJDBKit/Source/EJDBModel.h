#import <Foundation/Foundation.h>
#import "BSONArchiving.h"

@class EJDBDatabase;

@interface EJDBModel : NSObject<BSONArchiving>
@property (copy,nonatomic,readonly) NSString *oid;
@property (weak,nonatomic) EJDBDatabase *database;
- (id)initWithDatabase:(EJDBDatabase *)database;
- (NSString *)collectionName;
- (NSArray *)joinableModelArrayProperties;
@end
