# Web Image Gallery for Autoshare Android Phone

This is a Rails-App, which acts as an endpoint and private image-gallery.


## Features

* Integrations with Autoshare
AutoShare is an Android App which can automatically upload any (new) images to a specified server. In a way, it work's similiar like the Android Google+ App/Dropbox whatever.
I liked the way the google+ app uploaded any new images to picasa. I didn't like the feeling that all my photos are located on a (US) company's server, which I have no control over.

AutoShare: [Autoshare on Google Play Store](https://play.google.com/store/apps/details?id=com.dngames.autoshare)


## More Features:

* Works as API for other applications too: just POST the picture content to /photos with credentials as HTTP Basic authentication
* Reads EXIF information for date of photo, GPS and camera information
* being able to share individual photos or whole days via a "Share", which is a random URL which contains all the shared info. In this way, there are no limit, which photos too share to whome. A share is like a gallery
* a share "Public" is automatically created, and all containing photos are displayed in a blogy fashion on the home page (Feed subcription possible, endless scrolling enabled)
* Using Twitter Bootstrap
* Internal private gallery:
  * All images are sorted and grouped by date. For performance reasons, whole years are foldable and folded by default.
  * days are automatically montage'd into a big preview thumbnail, so even if you took 100's of shots on one day, it will load fastly (because you save 99 HTTP-Requests)
  * Bulk upload with ajax possible, just drop your picture folder into the app
  * Images are saved in a way, even after quitting the app, the folder can be took and makes sense: public/photos/original/YEAR-MO-DA/pictures-of-the-days


## Install

```
git clone THIS
bundle
rake db:setup  # migrate and create a new user
```

This will also create a new user with name "share" and password "password". This can be changed later.
Configuration for AutoShare is explained after login.

## Todo

* Being able to rotate images from the interface
* Change/Correct image dates

