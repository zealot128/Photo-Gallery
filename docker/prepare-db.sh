#!/bin/sh

# If database exists, migrate. Otherweise setup (create and seed)
bundle exec rake db:migrate && echo "Database is ready!"
