#import <Foundation/Foundation.h>

/**
 This protocol is implemented by both EJDBQueryBuilder and EJDBFIQueryBuilder classes to allow for more convenient query creation in various parts of the framework.
*/

@protocol EJDBQueryBuilderDelegate <NSObject>

/** 
 This should return a properly formatted ejdb query dictionary.
*/
- (NSDictionary *)query;

/**
 This should return a properly formatted ejdb hints dictionary.
*/
- (NSDictionary *)hints;

@end
