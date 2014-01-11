#import <Foundation/Foundation.h>

@protocol EJDBQueryBuilderDelegate <NSObject>

- (NSDictionary *)query;

- (NSDictionary *)hints;

@end
