# Web Image Gallery for Autoshare Android Phone


This is a Rails-App, which acts as an endpoint and private image-gallery.

AutoShare is an Android App which can automatically upload any (new) images to a specified server. In a way, it work's similiar like the Android Google+ App.
I liked the way the google+ app uploaded any new images to picasa. I didn't like the feeling that all my photos are located on a (US) company's server, which I have no control over.

AutoShare: [[https://play.google.com/store/apps/details?id=com.dngames.autoshare]]

So I created that very simplified Gallery-App.

## Install

```
git clone THIS
bundle
rake db:setup  # migrate and create a new user
```

This will also create a new user with name "share" and password "password". This can be changed later.
Configuration for AutoShare is explained after login.

Under development
