RBM scrapes the Rose bandwidth usage page and collections stats of a user's bandwidth usage. It currently uses this to send push notifications (via boxcar) when a user's bandwidth usage passes a certain point ("warn level") or when the bandwidth class of a users changes.

It also displays the last 36 hours of entries as a graph, although work to make this a more useful and intuitive graph still needs to be done. Devices are named using either their host name or network addresses, or a user provided name which takes precedence over both.

# Usage

The bandwidth monitor is divided into two parts, the web server and the scrape server. Both components currently run independently of each other.

**To start the web server:** `ruby server.rb`

**To start the scrape server:** `ruby scrape_server.rb`

By default the scrape server will start in development mode, to put it into production use the `--production` flag.

# Installation

The following gems are required to run RBM

- [sinatra](http://www.sinatrarb.com/)
- [datamapper](http://datamapper.org/)
- [haml](http://haml-lang.com/)
- [ruby-ntlm](https://github.com/macks/ruby-ntlm)
- [nokogiri](http://nokogiri.org/)
- [json](http://flori.github.com/json/)
- [boxcar_api](http://github.com/boxcar/boxcar_api)

# Future Work

## Normalized bandwidth charts (i.e., bytes downloaded over time)

This feature is currently on hold since I can't seem to figure out a way to pull out individual upload/download statistcs from the data Rose provides.

This will also include stats such as time until bandwidth cap is reduced.

## API access for creating/retrieving bandwidth entries

For 3RD party applications who need access to long term data for a user. RBM holds onto usage data forever, so an API to access this may be of use.

Also an API for notification providers to discover and register a user (with their consent) would be useful.

# Security Concerns

Currently RBM scrapes from the Rose bandwidth page by using NTLM, which requires RBM to store and retrieve a user's password. Suitable warnings are included on the registration page, but note that running this on a shared server will result in plain text passwords being stored in the sqlite database.