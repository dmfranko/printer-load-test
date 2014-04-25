printer-load-test
=================

Load test a LPR printer.

You'll need to install the work_queue gem.

`sudo gem install work_queue`

##Usage

ruby printer-load.rb printserver/queue number_of_concurrent_printers number_of_jobs

##Output

You'll get something like the below when the test is finished.

Total count: 1
Start Time : 2014-04-25 16:44:58 -0400
End Time : 2014-04-25 16:45:14 -0400
Total Duration : 16.086905 seconds
