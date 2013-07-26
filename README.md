EJDBKit Framework
=================

The EJDBKit framework is an attempt at wrapping ejdb C library made by the folks over at Softmotions.

Current Status
=================
THERE BE DRAGONS HERE! The framework is NOT yet complete! DO NOT use it in a production environment
or to make your next killer app. Not heeding this warning will probably cause you much pain, wailing
and gnashing of the teeth! You..have...been...warned!!!

Ok..so if you're still here, it's not all doom and gloom as I intend to actively work on this project
at least until I'm satisfied it is a complete and more imporantly correct implementation of ejdb.

Building
=================
There are a few steps but it's not too bad! :)

1st) Obviously...clone this project.
2nd) After it's cloned, the ejdb dependancy is included as a submodule so you'll have to get it via:
	git submodule init
	git submodule update
3rd) After the submodule is pulled down. You'll need to build the tcejdb libraries...fortunately
this should be as simple as:
	./ejdb-build.sh (under EJDBKit folder).
4th) After a bunch of compilation/building/etc you should be good to go!

Usage
==================
WATCH THIS SPACE!!! :)


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
In the spirit of cooperation and working together, for the parts that I created/create, the license is LGPL (same as ejdb). Anything else is licensed under its corresponding license.

