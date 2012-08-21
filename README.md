hammer_of_justice
=================

### The Hammer of Justice will crush your application

Not really, but it can. It is used to extract lines from Apache logs, format them, and then replay them for load testing. Please do not use the Hammer of Justice against your production servers, as it might leave a smoking hole.

### Usage

We assume several things - all of the log files have been copied to a central location, and that location is accessible to this script. We also assume that the log files are named like "/server1/apache/access.log".

### Disclaimers

This was hacked into place by viking coders. Do not use it. ever. If you do use it, please make sure that you have edited it to fit your environment. If you fail to do this, things *will* go wrong.