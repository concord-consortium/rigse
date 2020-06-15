
Running bundle posting load tests on rails-portal running in production mode.

Install httperf with your favorite package manager (mine is brew):

    $ brew install httperf

screencast on Rack and Metal in Rails 2.3:

* http://railslab.newrelic.com/2009/06/05/episode-14-rack-metal

load-testing and httperf references:

* http://railslab.newrelic.com/2009/06/23/episode-15-load-testing-part-1
* http://railslab.newrelic.com/2009/06/23/episode-16-load-testing-part-2
* http://www.comlore.com/httperf/httperf-quickstart-guide.pdf

Blog post and github repo for generating load tests for httperf from server logs:

* http://www.igvita.com/2008/09/30/load-testing-with-log-replay/
* https://github.com/igrigorik/autoperf

## Setup xproject.local as an apache virtual host to run the rails-portal

I use a reverse proxy below because I use Passenger with Ruby 1.9.2 and the rails-portal runs on Ruby 1.8.7.

Add to /etc/hosts:

    127.0.0.1       xproject.local

Add to: /etc/apache2/extra/httpd-vhosts.conf

    # Proxying to passenger-standalone running under Ruby 1.8.7                                                                                                                                             
    # http://blog.phusion.nl/2010/09/21/phusion-passenger-running-multiple-ruby-versions/                                                                                                                   
    # /Users/stephen/dev/test/xproject-git                                                                                                                                                                  
    # passenger start -a 127.0.0.1 -p 3003 -d                                                                                                                                                               

    <VirtualHost xproject.local:80>
       ServerName xproject.local
       DocumentRoot /Users/stephen/dev/test/xproject-git/public
       PassengerEnabled off
       AllowEncodedSlashes On
       ProxyRequests Off
       KeepAlive Off
       <Proxy *>
          Order deny,allow
          Allow from all
       </Proxy>
       ProxyPass / http://127.0.0.1:3003/  retry=0
       ProxyPassReverse / http://127.0.0.1:3003/
       ErrorLog "/Users/stephen/dev/test/xproject-git/log/assessments.localhost-error_log"
       CustomLog "/Users/stephen/dev/test/xproject-git/log/assessments.localhost-access_log" common
    </VirtualHost>
  
    # after making changes ...                                                                                                                                                                              
    # testing the config: apachectl configtest                                                                                                                                                              
    # restarting apache: sudo apachectl restart                                                                                                                                                             
    # or tailing the general apache2 error log                                                                                                                                                              
    # tail -n 200 -f /var/log/apache2/error_log

Test the apache config and restart.

Start passenger stand-alone in production mode on port 3003:

    $ cd xproject
    $ passenger start -e production -a 127.0.0.1 -p 3003 -d

Confirm that the app is responding: http://xproject.local/

We'll be adding a bunch of records into the database, save a dump of your current database into db/development_data.sql to easily restore the initial state:

    $ rake db:dump

Check to see how many Dataservice::BundleContent models you are starting with:

    $ bin/rails runner "puts Dataservice::BundleContent.count"
    => 2

cd to the httperf dir:

    $ cd benchmarks/httperf

Check the os settings for maximum number of open files -- httperf uses select() and uses a new file descriptor for each connection it opens concurrently. I was getting this warning running httperf:

    httperf: warning: open file limit > FD_SETSIZE; limiting max. # of open files to FD_SETSIZE

On my Mac the maximum open files descriptors was set to 256

    $ ulimit -acore 
    file size          (blocks, -c) 0
    data seg size           (kbytes, -d) unlimited
    file size               (blocks, -f) unlimited
    max locked memory       (kbytes, -l) unlimited
    max memory size         (kbytes, -m) unlimited
    open files                      (-n) 256
    pipe size            (512 bytes, -p) 1
    stack size              (kbytes, -s) 8192
    cpu time               (seconds, -t) unlimited
    max user processes              (-u) 266
    virtual memory          (kbytes, -v) unlimited

Increase the maximum number of file descriptors to 1024:

    $ ulimit -n 1024



    curl -i --header "Content-Type: application/xml" --header "Content-Encoding: b64gzip" --header "Content-md5: 2f90a99d87961e3ffdf585cd0c523b42 --cookie _rails_portal_session=520923139d1eb51aea3715a82ad94cba; --data @curl-data/dataservice_bundle_loggers_1_bundle_contents.bundle.med.txt" http://xproject3.local/dataservice/bundle_loggers/1/bundle_contents.bundle


This measures the time to post 100 OTrunk session bundles:

    $ httperf --hog --server xproject.local --add-header="Content-Type: application/xml\nContent-Encoding: b64gzip\nContent-md5: 2f90a99d87961e3ffdf585cd0c523b42\n" --wsesslog 100,0,sessions/dataservice_bundle_loggers_1_bundle_contents.bundle.med.txt

The results running both httperf and the rails-portal server on the same machine:

    Maximum connect burst length: 1

    Total: connections 100 requests 100 replies 100 test-duration 23.803 s

    Connection rate: 4.2 conn/s (238.0 ms/conn, <=2 concurrent connections)
    Connection time [ms]: min 76.6 avg 238.0 max 930.9 median 326.5 stddev 142.6
    Connection time [ms]: connect 0.1
    Connection length [replies/conn]: 1.000

    Request rate: 4.2 req/s (238.0 ms/req)
    Request size [B]: 7192.0

    Reply rate [replies/s]: min 4.2 avg 4.3 max 4.4 stddev 0.1 (4 samples)
    Reply time [ms]: response 237.9 transfer 0.0
    Reply size [B]: header 357.0 content 0.0 footer 0.0 (total 357.0)
    Reply status: 1xx=0 2xx=100 3xx=0 4xx=0 5xx=0

    CPU time [s]: user 4.77 system 18.97 (user 20.0% system 79.7% total 99.7%)
    Net I/O: 31.0 KB/s (0.3*10^6 bps)

    Errors: total 0 client-timo 0 socket-timo 0 connrefused 0 connreset 0
    Errors: fd-unavail 0 addrunavail 0 ftab-full 0 other 0

    Session rate [sess/s]: min 4.20 avg 4.20 max 4.40 stddev 0.12 (100/100)
    Session: avg 1.00 connections/session
    Session lifetime [s]: 0.2
    Session failtime [s]: 0.0
    Session length histogram: 0 100

If you ran the previous test once you should have 100 more Dataservice::BundleContent models than you starting with:

    $ bin/rails runner "puts Dataservice::BundleContent.count"
    => 102

When you are done restore the previous state of the database:

    $ rake db:load

JRuby is about 33% times faster running this test than MRI Ruby v1.8.7

Install and setup JRuby for running the rails-portal:

    $ rvm install jruby-head
    $ rvm use jruby-head
    $ rvm use gemset global
    $ gem install ruby-debug bundler
    $ rvm use jruby@xproject
    $ bundle install

Start the server in production mode using mongrel:

    $ script/server -e production

Run the same bundle post tests specifying localhost as the server and port 3000:

    $ httperf --hog --server localhost --port 3000 --add-header="Content-Type: application/xml\nContent-Encoding: b64gzip\nContent-md5: 2f90a99d87961e3ffdf585cd0c523b42\n" --wsesslog 100,0,sessions/dataservice_bundle_loggers_1_bundle_contents.bundle.med.txt

JRuby starts at about 5 bundle posts a second but after warming up hotspot by the third run of httperf the rate is up to 9.9:

    Maximum connect burst length: 1

    Total: connections 100 requests 100 replies 100 test-duration 11.087 s

    Connection rate: 9.0 conn/s (110.9 ms/conn, <=2 concurrent connections)
    Connection time [ms]: min 91.4 avg 110.9 max 527.8 median 105.5 stddev 42.9
    Connection time [ms]: connect 0.2
    Connection length [replies/conn]: 1.000

    Request rate: 9.0 req/s (110.9 ms/req)
    Request size [B]: 7187.0

    Reply rate [replies/s]: min 8.4 avg 8.9 max 9.4 stddev 0.7 (2 samples)
    Reply time [ms]: response 110.5 transfer 0.2
    Reply size [B]: header 216.0 content 0.0 footer 0.0 (total 216.0)
    Reply status: 1xx=0 2xx=100 3xx=0 4xx=0 5xx=0

    CPU time [s]: user 2.23 system 8.76 (user 20.1% system 79.0% total 99.1%)
    Net I/O: 65.2 KB/s (0.5*10^6 bps)

    Errors: total 0 client-timo 0 socket-timo 0 connrefused 0 connreset 0
    Errors: fd-unavail 0 addrunavail 0 ftab-full 0 other 0

    Session rate [sess/s]: min 8.40 avg 9.02 max 9.40 stddev 0.71 (100/100)
    Session: avg 1.00 connections/session
    Session lifetime [s]: 0.1
    Session failtime [s]: 0.0
    Session length histogram: 0 100

If instead you start the server with JRuby with hotspot optimized for server operation:

        $ jruby --server script/server -e production

After running the httperf test several times the server is now processing bundle posts at over 11/s:

    Maximum connect burst length: 1

    Total: connections 100 requests 100 replies 100 test-duration 9.031 s

    Connection rate: 11.1 conn/s (90.3 ms/conn, <=2 concurrent connections)
    Connection time [ms]: min 79.5 avg 90.3 max 134.3 median 89.5 stddev 7.1
    Connection time [ms]: connect 0.1
    Connection length [replies/conn]: 1.000

    Request rate: 11.1 req/s (90.3 ms/req)
    Request size [B]: 7187.0

    Reply rate [replies/s]: min 10.8 avg 10.8 max 10.8 stddev 0.0 (1 samples)
    Reply time [ms]: response 90.0 transfer 0.2
    Reply size [B]: header 216.0 content 0.0 footer 0.0 (total 216.0)
    Reply status: 1xx=0 2xx=100 3xx=0 4xx=0 5xx=0

    CPU time [s]: user 1.82 system 7.19 (user 20.2% system 79.6% total 99.8%)
    Net I/O: 80.0 KB/s (0.7*10^6 bps)

    Errors: total 0 client-timo 0 socket-timo 0 connrefused 0 connreset 0
    Errors: fd-unavail 0 addrunavail 0 ftab-full 0 other 0

    Session rate [sess/s]: min 10.80 avg 11.07 max 10.80 stddev 0.00 (100/100)
    Session: avg 1.00 connections/session
    Session lifetime [s]: 0.1
    Session failtime [s]: 0.0
    Session length histogram: 0 100
    