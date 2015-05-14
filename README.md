# shipment_tracker
[![Circle CI](https://circleci.com/gh/FundingCircle/shipment_tracker.svg?style=shield)](https://circleci.com/gh/FundingCircle/shipment_tracker)

Tracks shipment of software versions for audit purposes

## Setup

```
bundle install
bundle exec rake db:setup
```

## Setup Git hooks

```
rake git:setup_hooks
```

## Enabling access to repositories via SSH

Ensure that `libssh2` is installed and the `rugged` gem is reinstalled. On OSX:

```
brew install libssh2
gem pristine rugged
```

When booting server set Environment variables `SSH_USER`, `SSH_PUBLIC_KEY` and `SSH_PRIVATE_KEY`:

```
SSH_USER=git \
SSH_PUBLIC_KEY='ssh-rsa AAAXYZ' \
SSH_PRIVATE_KEY='"-----BEGIN RSA PRIVATE KEY-----
abcdefghijklmnopqrstuvwxyz
-----END RSA PRIVATE KEY-----
" rails s
```

## License

Copyright © 2015 Funding Circle Ltd.

Distributed under the BSD 3-Clause License.
