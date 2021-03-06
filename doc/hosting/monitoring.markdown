Monitoring
==========

We use three modes of monitoring the system to make sure everything is humming nicely: cron jobs, munin, and nagios.

Cron Jobs
---------

We have a number of cron jobs that email us either regular reports or reports of something looks fishy.  Our production
cron jobs are documented [here](cron-jobs.markdown).

Munin
-----

We have a munin installation that monitors various indicators of our story processing system (number of stories crawled,
number of stories in the extractor queue, etc) as well as some basic system information on the core system.  Munin
includes a web interface that provides historical data about the various metrics. We keep the mediacloud munin
installation in a [separate github repo](https://github.com/berkmancenter/mediacloud-munin).

There is an http auth protected web UI for munin.  Ask a media cloud geek for the info.

Munin's plugins have hardcoded soft ("warning") and hard ("critical") limits for how we expect the services that are
being monitored to perform. For example, the mc_services plugin expects 15+ forks of the Readability's Python daemon to
be running at any given moment:

https://github.com/berkmancenter/mediacloud-munin/blob/master/etc/munin/plugins/mc_services#L58-L67

If the number of those forks falls below 15, Munin will send out a "WARNING" email alert, and if the count falls below
1 (= Readability service is not running at all), we'll get a "CRITICAL" email alert. You'll be getting those emails
too.

Nagios
------

In addition to the munin monitoring, we monitor each of our mit servers using nagios.  Nagios monitors basic system
health (disk space, free memory, load, etc) as well as some specific media cloud metrics (presence of java processes
on Solr servers, etc).  Nagios warning thresholds are monitored in the /etc/local/nagios/etc directory of each
monitored server.  Media labs necsys runs the nagios server, which includes a web interface to disable monitoring
of specific hosts / servers as needed (ask a mc geek for the URL and auth info).

The most common nagios report is a notice that we need to update packages on the ubuntu installation, which looks like
this:

```
APT WARNING: 1 packages available for upgrade (0 critical updates).
```

To update all packages on all mit servers, I run:

```
for i in mcquery1 mcquery2 mcquery3 mcquery4 mcdb1 mcnlp civicprod civicdev; do ssh -t $i sudo apt-get upgrade; done
```

This requires many password entries and confirmations of packages, but I prefer the occasional hassle to the security
and reliability costs of automating the updates more.
