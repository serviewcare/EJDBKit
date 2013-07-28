#import <Foundation/Foundation.h>

/**
 This protocol can be adopted by custom class if you'd like to save/retrieve objects other than the supported types.
 You must implement all three methods in order for this to work. Please note: only supported objects can be saved
 from the object. What this means is, you can't provide a property that is for instance, an NSSet as it will
 not be recognized as a supported type (in fact, the code will throw an exception if you do so).
*/

@protocol BSONArchiving <NSObject>

/** 
 This method will be called when the code wants to return an OID (in other words the _id field). For obvious
 reasons having a property name called _id may not be such a good idea. You must return the name
 of the property in the class that will represent the OID.
*/
- (NSString *)oidPropertyName;

/**
 This method will be called when the code wants to encode your object into BSON. You must provide a
 dictionary with a key named "type", it's value being the name of the class. You can optionally provide a key named "_id"
 if you'd like to pass your own OID but you must make sure it is a valid OID otherwise the object will not be saved.
 In fact, since it's asserted that the OID is valid, if it isn't, the assertion fails...and you know what happens then! :)
*/
- (NSDictionary *)toDictionary;

/**
 This method will be called when the code wants to decode your object from BSON. If the query you specified contains
 the "_id" key it will be returned as the name you specified in the oidPropertyName method. This makes it convenient
 to use with key/value coding (i.e. enumerate the keys and set the values without having to set each property manually).
 Please note: If the query does return an "_id" key/value and you return a nil or some non-existent property name
 your code will blow sky high!!!!
*/
- (void)fromDictionary:(NSDictionary *)dictionary;

@end
