# Web Image Gallery for Autoshare Android Phone

[![Build Status](https://travis-ci.org/zealot128/AutoShare-Gallery.svg?branch=master)](https://travis-ci.org/zealot128/AutoShare-Gallery)

This is a Rails-App, which acts as an api server for different (Android) photo upload apps and private image-gallery.


## Features

* Integrations with AutoShare and PhotoBackup
  * AutoShare is an Android App which can automatically upload any (new) images to a specified server. In a way, it work's similiar like the Android Google+ App/Dropbox whatever.
    AutoShare: [Autoshare on Google Play Store](https://play.google.com/store/apps/details?id=com.dngames.autoshare)
  * [PhotoBackup](http://photobackup.github.io/) is a small protocol and a collection of Apps. For Mobile there is only a Android App atm
  * Manual Upload on website
  * ... your app missing? Just POST to / with http-basic-auth or pseudo-password or unique upload URL (displayed in the app)

* Image gallery grouped by Year -> Month -> Day for faster image retrieval
* Reads EXIF information for date of photo, GPS and camera information, orientation
* Uses LightGallery with VideoJS support, so Photos as well as videos can be uploaded
* works on mobile (responsive + touch support by LightGallery)

Default:
* Uses AWS S3 to store the original files (Also grouped by /year/day/). The smaller thumbnails and preview versions are stored locally (can be changed in ``app/uploaders/image_uploader.rb``) to reduce aws requests and costs.

Shares + Tags
* Photos/Videos can be tagged (private) and added to shares (public). Those shares have each an unique long URL and can be handed to other people
* a share "Public" is automatically created, and all containing photos are displayed in a blogy fashion on the home page (Feed subcription possible)



## Install

**Prerequisites:**

* Ruby >2.2.2 and bundler
* Imagemagick
* PostgreSQL
* (optional) ffmpeg for video upload
* (optional) AWS account and S3 configuration
* At this point, only tested on (x64) linux architecture and OSX


Getting started (development mode)

```bash
git clone https://github.com/zealot128/AutoShare-Gallery.git
cd AutoShare-Gallery
bundle install
cp config/secrets.yml.example config/secrets.yml
# edit secrets
rake db:setup  # migrate and create a new user "share" with password "password"
rails server -p 3000
# server is started on port 3000
```

This will also create a new user with name "share" and password "password". This can be changed later.
Configuration for AutoShare is explained after login.

## AWS

1. Create AWS account
2. Create S3 Bucket (name needs to be unique over all S3 buckets), remember bucket name + region
3. Create an IAM User in Security credentials, download credentials
4. under yab Permissions Attach policy:  AmazonS3FullAccess  +  CloudWatchReadOnlyAccess
5. Fill in AccessKeyId and SecretAccessKey in ``config/secrets.yml``, as well as bucket + region

## Video

For video transcoding needs ffmpeg, because Libfaac is not available on many systems by default, the default Audio codec is aac.

OSX:

```
brew reinstall ffmpeg --with-faac
```

## License


Copyright (c) 2012 Stefan Wienert

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

