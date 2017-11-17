#### REWRITE

Basisfunktionalitaet:

* Bearbeiten:
  * Rotieren
  * Assigning von Tags/Shares (Bearbeiten)
  * Caption
  * ShotAt aendern
  * Neues Face malen

* Mobile Back Button

---

* Filter Sidebar
  * Datum, Range: "2017"  "November 2016", "Nov 2017" als Range moeglich
  * Filter: Personen And/Or
  * Filter: Geloescht
  * Orte (+Alle Photos desselben Tages)

---

* aws private
* Cookie login

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
