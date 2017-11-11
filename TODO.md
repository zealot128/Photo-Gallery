#### REWRITE

Basisfunktionalitaet:

* Loeschen / Undelete
  * Star nicht loeschbar
* Bearbeiten:
  * Rotieren
  * Assigning von Tags/Shares (Bearbeiten)
  * Caption
  * ShotAt aendern
* Faces Toggle
  * Neues Face malen

* Mobile Back Button

---

* Filter Sidebar
  * Datum, Range: "2017"  "November 2016", "Nov 2017" als Range moeglich
  * Filter: Personen And/Or
  * Filter: Geloescht
  * Option Alle Photos desselben Tages mit einbeziehen
  * Orte (+Alle Photos desselben Tages)

###############

* Loeschen loescht zuviel!!
* Statt Loeschen -> Mark as delete und nach ein paar Tagen loeschen.
* Cookie login
* Unbearbietete/Fehlende Videos in tube
* Tube mit Size auswahl/Preloading
* Tube verlinken


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
