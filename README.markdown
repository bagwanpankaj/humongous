# Humongous

Humongous: A Ruby way to browse and maintain MongoDB instances, using HTML5.

## Installation

create a dependency in your Gemfile

    gem 'humongous'

then run

    bundle install

and humongous will be up and running. or 

    gem install humongous

in IRB

just require it by running

    require 'humongous'

and then run

    Humongous.run!

#### Command Line Utility

Humongous provides command line utility. Here is example how to use.

on console/terminal run

    humongous

| **Options**           | **What value do they take**                                         |
|:----------------------|--------------------------------------------------------------------:|
| -K or --kill          | kill the running process and exit                                   |
| -S, --status          | display the current running PID and URL then quit                   |
| -s, --server SERVER   | Login credential(required for bitly)                                |
| -o, --host HOST       | listen on HOST (default: 0.0.0.0)                                   |
| -p, --port PORT       | use PORT (default: 5678)                                            |
| -x, --no-proxy        | ignore env proxy settings (e.g. http_proxy)                         |
| -F, --foreground      | don't daemonize, run in the foreground                              |
| -L, --no-launch       | don't launch the browser                                            |
| -d, --debug           | raise the log level to :debug (default: :info)                      |
| --app-dir APP_DIR     | set the app dir where files are stored                              |
| -h, --help            | Show this message                                                   |

## Credits

* [MongoHub](http://mongohub.todayclose.com/) (For giving inspiration for simplest UI and navigation.)

## More Info

For detailed info visit my blog [http://BagwanPankaj.com](http://bagwanpankaj.com)

For more info write me at me[at]bagwanpankaj.com

Copyright (c) 2010 Bagwan Pankaj: http://bagwanpankaj.com, released under the MIT license

## TODO's

There are lot of things and area to improve and develop. Since it in pre release now, any bug report, issues and feature request is highly appreciated.

* Error Handling
* Authentication module
* Better UI (need a real contribution here)
* Better documentation
* Example series

## Contributing to shortly
 
* Fork, branch, code, and then send me a pull request. :)

## Copyright

Copyright (c) 2012 [Bagwan Pankaj]. See LICENSE.txt for further details.

