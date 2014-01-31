#import <Foundation/Foundation.h>
#import "BSONArchiving.h"

@class EJDBDatabase;
@class EJDBModel;

@protocol EJDBDocument <NSObject>

- (NSString *)collectionName;

@end

@interface EJDBModel : NSObject<BSONArchiving,EJDBDocument>
@property (copy,nonatomic,readonly) NSString *oid;
@property (weak,nonatomic) EJDBDatabase *database;
@property (weak,nonatomic) id<EJDBDocument>modelObject;

- (id)initWithDatabase:(EJDBDatabase *)database;

@end
