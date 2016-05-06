# Web Image Gallery for Autoshare Android Phone

This is a Rails-App, which acts as an endpoint and private image-gallery.


## Features

* Integrations with Autoshare
AutoShare is an Android App which can automatically upload any (new) images to a specified server. In a way, it work's similiar like the Android Google+ App/Dropbox whatever.
I liked the way the google+ app uploaded any new images to picasa. I didn't like the feeling that all my photos are located on a (US) company's server, which I have no control over.

AutoShare: [Autoshare on Google Play Store](https://play.google.com/store/apps/details?id=com.dngames.autoshare)

[Some Screenshots/Demo using sharing feature](http://pics.stefanwienert.de/shares/adfb45830b436150cc5e15e4b95db599136f568fb1b80afd)


## More Features:

* Works as API for other applications too: just POST the picture content to /photos with credentials as HTTP Basic authentication
* Reads EXIF information for date of photo, GPS and camera information
![](http://pics.stefanwienert.de/photos/medium/2012-12-19/shot6.jpg?1356009448)
* being able to share individual photos or whole days via a "Share", which is a random URL which contains all the shared info. In this way, there are no limit, which photos too share to whome. A share is like a gallery
![](http://pics.stefanwienert.de/photos/medium/2012-12-19/shot5.jpg?1356009448)
* a share "Public" is automatically created, and all containing photos are displayed in a blogy fashion on the home page (Feed subcription possible, endless scrolling enabled)
  ![](http://pics.stefanwienert.de/photos/medium/2012-12-19/sho1.jpg?1356009370)
* Using Twitter Bootstrap
* Internal private gallery: This is more or less the core feature and been used by me for a while now.
![](http://pics.stefanwienert.de/photos/medium/2012-12-19/shot4.jpg?1356009376)
  * All images are sorted and grouped by date. For performance reasons, whole years are foldable and folded by default.
  * days are automatically montage'd into a big preview thumbnail, so even if you took 100's of shots on one day, it will load fastly (because you save 99 HTTP-Requests)
  * Bulk upload with ajax possible, just drop your picture folder into the app
  * Images are saved in a way, even after quitting the app, the folder can be took and makes sense: public/photos/original/YEAR-MO-DA/pictures-of-the-days


## Install

**Prerequisites:**

* Ruby >2.2 and bundler
* imagemagick
* ffmpeg for video upload
* file-storage -> all pictures are stored inside public/photos directory
  * Image uploads are handled by [Paperclip](https://github.com/thoughtbot/paperclip#storage), so with a little configuration S3, Fog, Dropbox or azure should be possible.
* postgresql

```
git clone https://github.com/zealot128/AutoShare-Gallery.git
bundle
rake db:setup  # migrate and create a new user "share" with password "password"
rails s
# server is started on port 3000
# edit config/locales/en.yml and change settings
```

This will also create a new user with name "share" and password "password". This can be changed later.
Configuration for AutoShare is explained after login.

## Video

For video transcoding needs ffmpeg with libfaac
OSX:

```
brew reinstall ffmpeg --with-faac
```

## License



Copyright (c) 2012 Stefan Wienert

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

