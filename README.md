# Web Image Gallery for Autoshare Android Phone

[![Build Status](https://travis-ci.org/zealot128/Photo-Gallery.svg?branch=master)](https://travis-ci.org/zealot128/Photo-Gallery)

This is a Rails-App, which acts as an api server for different (Android) photo upload apps and private image-gallery.

## Features

* Integrations with AutoShare and PhotoBackup
  * AutoShare is an Android App which can automatically upload any (new) images to a specified server. In a way, it work's similiar like the Android Google+ App/Dropbox whatever.
    AutoShare: [Autoshare on Google Play Store](https://play.google.com/store/apps/details?id=com.dngames.autoshare)
  * [PhotoBackup](http://photobackup.github.io/) is a small protocol and a collection of Apps. For Mobile there is only a Android App atm
  * Manual Upload on website
  * ... your app missing? Just POST to / with http-basic-auth or pseudo-password or unique upload URL (displayed in the app), e.g. ``curl --progress-bar -i -k -XPOST https://myserver/?token=TOKEN` -F file="PATH_TO_FILE"``

* Image gallery grouped by Year -> Month -> Day for faster image retrieval
* Reads EXIF information for date of photo, GPS and camera information, orientation
* Uses LightGallery with VideoJS support, so Photos as well as videos can be uploaded
  * Video: Videos will be uploaded, a smaller preview version encoded and displayed via Video.js player
* works on mobile (responsive + touch support by LightGallery)
* Storage: It can either use local storage or S3 (only then rekognition feature can be used)
* **AWS Rekognition API**: Photos will be sent to AWS Rekognition API and app will store all "labels" and "faces" recognized by AWS. The app provides some kind of wizard process to assign faces to person names to search for photos with specific people
  * **WARNING**: This can be a little pricy, to process 1000 pictures cost $1. To get the labels AND faces, we need to issue 2 calls per picture, so $1/500 pictures. Only pictures that are tagged with either "People" or "Person"/"Child" are process for face detection though to reduce cost. There is a free tier of 5000 calls per month, which should cover most private uses after an initial import
  * Also *storing* the face vectors on AWS costs a little money, but is far less: $ 0.01 / 1000 faces. One photo could have more than one face in it, some have none. There is a clean-up option, to remove unneeded faces (background person, wrongly detected faces, etc.)
  * Data protection: According to AWS' policy, the images are not stored and are not used for their data model in any way.
* Photo search: "Show me all photos with me and my daughter taken from 2016-01-01 with an aperture of 1.2-2.5"

Shares + Tags
* Photos/Videos can be tagged (private) and added to shares (public). Those shares have each an unique long URL and can be handed to other people
* a share "Public" is automatically created, and all containing photos are displayed in a blogy fashion on the home page (Feed subcription possible)


## Install

**Prerequisites:**

* Ruby >2.2.2 and bundler
* Imagemagick
* PostgreSQL
* (optional) ffmpeg for video upload
* (optional but recommended) AWS account and S3 configuration
* At this point, only tested on (x64) linux architecture and OSX


Getting started (development mode)

```bash
git clone https://github.com/zealot128/AutoShare-Gallery.git
cd AutoShare-Gallery
bundle install
# Adjust secrets
cp config/secrets.yml.example config/secrets.yml
rake db:setup  # migrate and create a new user "share" with password "password"
rails server -p 3000
# server is started on port 3000
```

This will also create a new user with name "share" and password "password". This can be changed later.
Configuration for AutoShare is explained after login. Make sure to visit the admin->Settings page to fill in the missing credentials and adjust settings.

## AWS

1. Create AWS account
2. Create S3 Bucket (name needs to be unique over all S3 buckets), remember bucket name + region
3. Create an IAM User in Security credentials, download credentials
4. under tab Permissions Attach policy:  AmazonS3FullAccess  +  CloudWatchReadOnlyAccess
  [![Build Status](https://raw.githubusercontent.com/zealot128/Photo-Gallery/master/doc/aws_permissions.png)](https://travis-ci.org/zealot128/AutoShare-Gallery)
5. Fill in AccessKeyId and SecretAccessKey in Settings page, also Account-Id
6. Optional: Create some Budgets to

**IMPORTANT** If you intend to use Photo-Gallery in future for your personal gallery, please mention it somewhere (issue/email), so I can plan ahead to make future migrations more smooth. Also please notice, that this is MIT licensed software, so I can't provide any warranty whatsoever.

## Video

For video transcoding needs ffmpeg, because Libfaac is not available on many systems by default, the default Audio codec is aac. If you can provide faac, install it and fill in on Settings page, otherwise just use the default, aac.

e.g. OSX:

```
brew reinstall ffmpeg --with-faac
```


## Production deployment

Sorry, there is no automatic process at the moment, as a lot of people have different needs for deployment. Here are some of the things which are important:

* This is a more or less standard Rails app. In general, I recommend Passenger + Nginx/Apache2 which is easy to configure
* Make installation like development, but set ``export RAILS_ENV=production`` before.
* Compile assets: ``bundle exec rake assets:precompile``
* Change exception notification email recipients and smtp settings in ``config/environments/production.rb``
* Install cronjobs: ``bundle exec whenever --update-crontab``
* The app enforces ssl connections for all user interactions (upload can happen in plain text to also support ancient software, like AutoShare which can't handle too much modern SSL). If you can't install a valid certificate, remove that requirement from app/controllers/application_controller.rb

## Initial import of existing lots

* TODO, Rekognition, Day disabling etc.

### Upload script

I've provided a sh upload script in [ doc/upload.sh.example ](https://raw.githubusercontent.com/zealot128/Photo-Gallery/master/doc/upload.sh.example )
Edit the first two lines, fill in a token from your app instance (found in "Upload" section) and host. You can run this script with:

```
sh upload.sh *.jpg
```

this will upload each file and DELETE IT AFTERWARDS if uploaded successfully. As it only uses sh and curl, it can also run on most platforms, like NAS or Android phones (adb shell...) ;)



## License


Copyright (c) 2012 Stefan Wienert

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

