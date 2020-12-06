#!/bin/sh

./docker/wait-for-it.sh db:5432
./docker/prepare-db.sh
mkdir -p ./tmp/pids
bundle exec puma -C config/puma.rb
