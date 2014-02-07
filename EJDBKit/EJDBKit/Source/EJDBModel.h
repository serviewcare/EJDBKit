#import <Foundation/Foundation.h>
#import "BSONArchiving.h"

@class EJDBDatabase;

/**
 This class was created in an effort to make saving objects to the database more convenient. Subclassing this class for each of your collections relieves
 you of having to work with dictionaries and implementing the BSONArchiving protocol. In addition, you can reference other
 collections by providing either a single EJDBModel property or an NSArray property that contain EJDBModels that point to another collection.
 The following rules are very important to keep in mind:
 
 1) Only readable/writeable and non dynamic properties will be recognized and saved to the collection.Dynamic and read only properties will be ignored!
 
 2) Supported primitive types are: int, long long, bool, float and double. All other primitive types will be ignored i.e. not saved!
 
 If you will be referencing other collections:
 
 1) The default implementation of collectionName just returns the name of the class of your EJDBModel subclass. This means that when
 the model looks for the referenced collection it will assume that the collection name is the same as what you returned from the collectionName method.
 If this is not the case, you MUST override the collectionName method and return the name of the collection!
 
 2) The default implementation of joinableModelArrayProperties returns an empty array. If you have any NSArray properties that contain ejdbmodel subclasses
 that reference another collection you MUST override the joinableModelArrayProperties method and add a string to the object that matches the name of the property for each
 array property!
 
 3) DO NOT create a nsarray property that contains ejdbmodels that reference seperate collections else bad things will happen!
 
 If you don't heed the above rules (especially rules regarding referencing collections) you may encounter barrel throwing gorillas, fire breathing dragons
 and the wrath of Murphy! :)
*/
@interface EJDBModel : NSObject<BSONArchiving>
/** The oid of this model. */
@property (copy,nonatomic,readonly) NSString *oid;
/** The database that this model belongs to. */
@property (weak,nonatomic) EJDBDatabase *database;
/**
 The designated initializer for this class. It's recommended that you use this as opposed to setting the database property later.
 @param database - The EJDBDatabase this model belongs to.
 @since v0.6.0
*/
- (id)initWithDatabase:(EJDBDatabase *)database;
/**
 Override this method if you are using collection joins and your collection name does not match the class name of your EJDBModel subclass.
 The default implementation simply returns the string representation of the class name.
 @returns The name of the collection this model will be stored in.
 @since v0.6.0
*/
- (NSString *)collectionName;
/**
 Override this method if you are using collection joins and you have one or more NSArray properties that contain EJDBModels that reference other collections.
 You MUST ensure that each string in the array matches your NSArray property name exactly!
 The default implementation returns an empty array.
*/
- (NSArray *)joinableModelArrayProperties;
@end
