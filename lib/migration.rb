#Datumswerte aktualisieren
SLOW_CALLBACKS = false
Photo.find_each { |i|i.save!(:validate => false)}

# MOntagen hinzufuegen
SLOW_CALLBACKS = true
Day.find_each { |i| i.update_me }

