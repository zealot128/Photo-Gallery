HEIF:

- Rotate

Jobs:

- Version generation

Deploy:

- Tomo

- Rails 6 Upgrade
- Test im Development mit AWS Krams

---


* Landscape View
* AWS: OCR
  * Suche - PG Search
  * Text anzeigen
* Faces
  * Neues Face malen
* ShotAt aendern
* Rotate
* Geodaten -> Map in Day view?
* Mobile FF retained nicht position :(

#### REWRITE

* Mobile Back Button


---

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

* WebDAV: andere Apps, wie Owncloud checken
* public/uploads/tmp wird nicht gecleart, je release; symlnk fehlt noch beim ansible
