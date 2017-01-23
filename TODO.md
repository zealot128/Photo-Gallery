# TODO

* Search
  * Mehr Optionen (Kamera)

* Rekognition
  * Button der die naechsten ~1000 unrekognized Bilder durch geht
  * Similarity abspeichern
  * Vorschau Hover bei Unassigned

* Bilder
  * Geodaten -> Map in Day view

* MetaData als FlatFiles mit abspeichern
  * Je Day eine json Datei:
  {
    "file": "IMG_...",
    "labels": [..],
    "faces: [..]
  }
  * Oder HiddenFile?
    Labels=A,B,C
    People=Lili,Stefan
    ShotAt=2016-..

* SMTP configurable (?)
* Real multi user with groups=families
* Jpegoptim?

* WebDAV: andere Apps, wie Owncloud checken
* S3 import?
* public/uploads/tmp wird nicht gecleart, je release; symlnk fehlt noch beim ansible
