# Shipment Tracker
[![Circle CI](https://img.shields.io/circleci/project/FundingCircle/shipment_tracker/master.svg)](https://circleci.com/gh/FundingCircle/shipment_tracker)
[![Code Climate](https://img.shields.io/codeclimate/github/FundingCircle/shipment_tracker.svg)](https://codeclimate.com/github/FundingCircle/shipment_tracker)
[![Test Coverage](https://img.shields.io/codeclimate/coverage/github/FundingCircle/shipment_tracker.svg)](https://codeclimate.com/github/FundingCircle/shipment_tracker)

[![](http://i.imgur.com/VkjlJmj.jpg)](https://www.flickr.com/photos/britishlibrary/11237769263/)

Tracks shipment of software versions for audit purposes.

The app has various "audit endpoints" to receive events,
such as deploys, builds, ticket creations, etc.

We use an append-only store, nothing in the DB is ever modified or deleted.
Event sourcing is used to replay each event allowing us to reconstruct the state
of the system at any point in time.

## Getting Started

Install the gems and set up the database.

```
bundle install
bundle exec rake db:setup
```

Set up Git hooks, for running tests and linters before pushing to master.

```
rake git:setup_hooks
```

You can use Guard during development to run rspec, cucumber, and rubocop when it detects any changes.

```
bundle exec guard
```

### Enabling access to repositories via SSH

Ensure that `libssh2` is installed and the `rugged` gem is reinstalled. On OSX:

```
brew install libssh2
gem pristine rugged
```

When booting server, set Environment variables `SSH_USER`, `SSH_PUBLIC_KEY` and `SSH_PRIVATE_KEY`:

```
SSH_USER=git \
SSH_PUBLIC_KEY='ssh-rsa AAAXYZ' \
SSH_PRIVATE_KEY='-----BEGIN RSA PRIVATE KEY-----
abcdefghijklmnopqrstuvwxyz
-----END RSA PRIVATE KEY-----' \
rails s -p 1201
```

Note that port 1201 is only needed in development; it's the expected port by auth0 (the service we use for authentication).

You can also use Foreman to start the server and use settings from Heroku:

```
SSH_USER=git SSH_PRIVATE_KEY=$(heroku config:get SSH_PRIVATE_KEY) SSH_PUBLIC_KEY=$(heroku config:get SSH_PUBLIC_KEY) foreman s -p 1201
```

## License

Copyright © 2015 Funding Circle Ltd.

Distributed under the BSD 3-Clause License.
