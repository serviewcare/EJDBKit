EJDBKit Framework
=================

The EJDBKit framework is an attempt at wrapping the [EJDB](https://github.com/Softmotions/ejdb) C library made by the folks over at [Softmotions](http://softmotions.com) into a convenient and easy to use Objective-C framework. For more information on EJDB check out [ejdb.org](http://ejdb.org).

Current Status
=================

It is definitely in a useable state but I would wait a bit before using it
in a production environment. Having said that, I plan on actively working on
this project until, at the very least, I'm satisfied it is a complete and correct
implementation.

Usage
==================

**EJDBDatabase** - This is the object you will likely use most often. It allows you to open/close a database and create/remove/query collections.

Example:

Open a database:

```objc
 EJDBDatabase *db = [[EJDBDatabase alloc] initWithPath:@"some/path" 
                                          dbFileName:@"foo.db"];
 [db openWithError:NULL];
```

Create a collection:

```objc
 EJDBCollection *collection = [db ensureCollectionWithName:@"foo" error:NULL];

```

**EJDBCollection** - This is the object through which you can save objects to the database, i.e. the collection in the database.

Using your newly created collection you can now
insert an object into the collection via a standard NSDictionary instance:

```objc
NSDictionary *dict1 = @{@"first name" : @"foo",@"last name" : @"bar"};
[collection saveObject:dict];
```
Or...multiple objects at once:

```objc
[collection saveObjects:@[dict1,dict2,dict3]];
```

So at this point you're probably wondering what object types are supported for inserting/fetching, here they are:

| Supported Objective-C types |
|----------|
| NSString |
| NSNumber |
| NSDate   |
| NSDictionary|
| NSArray|
| NSData |
| NSNull |

Querying a collection:

```objc
//Find all objects whose first name starts with 'f'
NSDictionary *theQuery = @{@"first name":@{@"$begin":@"f"}};

NSArray *results = [_db findObjectsWithQuery:theQuery 
						inCollection:collection error:NULL];
//results will contain dict1 as created in the preceeding section.
```

Querying with hints (order by,etc)

```objc
NSDictionary *theQuery = @{@"first name":@{@"$begin":@"f"}};

//Only return the 'first name' column, analagous to select `first name` from foo
NSDictionary *hints = @{@"$fields":@{@"first name": @1};

NSArray *results = [_db findObjectsWithQuery:theQuery
						hints:hints
						inCollection:collection error:NULL];
```

Don't need your collection anymore? Just remove it like so:

```objc
[db removeCollectionWithName:@"foo"];
```

That's about it for now. Do watch this space as it will be updated
shortly with even more information about how to use the framework. Pretty easy so far, right? :)


Building
===========================
If you'd like to participate in working on the framework itself, there are a few steps involved but it's not too bad! :)

1)	 Obviously...clone this project.

2) 	After it's cloned, the ejdb dependancy is included as a submodule so you'll have to get it via:

```
git submodule init
git submodule update

```

3) 	After the submodule is pulled down. You'll need to build the tcejdb libraries...fortunately this should be as simple as running the shell script (under EJDBKit folder):

```
    ./ejdb-build.sh
``` 

4)	After a bunch of compilation/building/etc you should be good to go!

If you just want to just use the framework, after completing the above steps
you need to do a few more things:

5) Run the shell script (again, under EJDBKit folder):

```
./build-universal.sh
```
Once the script finishes running you'll have a folder named build and contained within it you'll find a file name **libEJDBKit.a**. This is the universal library that you'll need to include in your project.

6) Drag the **libEJDBKit.a** file into your project and make sure to check the **Copy items into destination groups' folder** when presented with the Add Files dialog.

7) Link the **libz.dylib** library in **"Link Binary With Libraries"** by pressing the + button and selecting it from the provided list.

8) Next you need to add the tcejdb header files into your project. You'll find
the folder under **EJDBKit/ejdb/include/**. Drag the **tcejdb** folder into
your project and make sure to check the **Copy items into destination groups' folder** when presented with the Add Files dialog.

9) In your precompiled header file (.pch) add the following statement:
```
#include "tcejdb/ejdb.h"

```

10) Add the following import statement where you'd like to use the framework:

```objc
#import <EJDBKit/EJDBKit.h>

```

And you're all set.

I find it unholy having to add the tcejdb header files to the project and having to write the include statement in the .pch file but unfortunately I haven't yet figured out how to get it working any other way (any build masters out there willing to help??).
Rest assured, I will be working on simplifying all of this as much as possible.

iOS versions supported
=======================

The tcejdb library is built with a base of iOS 5.0 and deployment target of iOS 6.1.
I can't vouch for earlier versions and I'm not really concerned either (come on folks we'll have 7.0 soon)!

Collaboration
==============
As always, the more folks working on this, the better,stronger and (hopefully)faster the framework
will become. So contact me at darkstar.jd AT gmail if you're interested!

License
==============
LGPL (same as ejdb). Any other source according to its corresponding license.