# Cooke's Auction Service

## Dependencies

* Ruby 2.3.3
* Bundler
* awscli
  * `aws configure` see [instructions](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)
* .envrc from Drive

## Dev

```
./bin/images process --src=/home/jesse/... --dest=2017-05-27-x
./bin/upload /home/jesse/Downloads/2017-05-27-x 2017-05-27-1
```

## Ruby 2.3.x

```
sudo pacman -Syyu openssl-1.0 gcc6                                                                                        10:04:00
env RUBY_CONFIGURE_OPTIONS="CC=/usr/bin/gcc-6 PKG_CONFIG_PATH=/usr/lib/openssl-1.0/pkgconfig" asdf install ruby 2.3.3
```
