# Change Log

## 2.2.0

Thank you [brrusselburg](https://github.com/brrusselburg) for this release.

* Actualised dependencies ([#2](https://github.com/RuBAN-GT/bungie_client/pull/2))
* Code style updates

## 2.1.3

Hotfix

## ~~2.1.2 (2017-09-06)~~

Bad gem

* ~~Allow "Cookie#dot_domain" for `httpclient`.~~

## 2.1.1 (2017-06-30)

### Changes

* Client methods can allow to enter headers.

## 2.1.0 (2017-06-25)

### Fixes

* Empty hashes for `BungieClient::Wrapper#call_service` method.

### Changes

* Move `Default` class to `BungieClient::Wrapper`.

### Removed

* `BungieClient::Wrappers` namespace with `User` class

## 2.0.0 (2017-06-21)

### Features:

* Change HTTP Client to [Faraday](https://github.com/lostisland/faraday).

### Added

* Specs to gem.

### Changed

* Move services list to `BungieClient::Service` class.
* Move services generator to Rake tasks.

### Removed

* `get_response` and `post_response` methods, now it works in default `get` and `post` method from `BungieClient::Client`.
* cookies support in `BungieClient::Client`.
