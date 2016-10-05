# NearMeDC API Transformer
NearMeDC API Transformer is a micro ETL endpoint service that transforms Socrata API data into a geojson the NearMeDC App is expecting. This transformer is largely a modification of Spyglass, a [Code for America](https://github.com/codeforamerica) project by the [Charlotte Team](http://team-charlotte.tumblr.com/) for the [2014 fellowship](http://www.codeforamerica.org/geeks/our-geeks/2014-fellows/).


## What does it do?

This is a registry of micro ETL endpoints. It is largely based on Citygram and they have some documentation outlining what exactly this does: [overview documentation](https://github.com/codeforamerica/citygram/wiki/Getting-Started-with-Citygram).

Below is a specific example of the information flow:

Socrata Dataset API Endpoint -> NearMeDC API Transformer -> NearMeDC App

### Setup

* [Install Ruby](https://github.com/codeforamerica/howto/blob/master/Ruby.md)

```
git statcp .env.sample .env
gem install bundler
bundle install
bundle exec rackup
```
