const codes = [
  ["Escape", 27],
  ["ArrowRight", 39],
  ["ArrowLeft", 37],
  ["F", 70],
  ["D", 68],
]

const handlers = {}

window.keybus = handlers

export default {
  onKey(event) {
    const code = codes.find(
      ([name, c]) =>
        event.keyCode == c || event.key == name || event.code == name
    )
    if (!code) return
    const available = [...handlers[code[0]]]
    if (code && available) {
      available.reverse().forEach(({ callback }) => {
        if (!event.cancelBubble) {
          callback.call(event, event)
        }
      })
    }
  },
  addKeyListener(keyname, identifier, priority, callback) {
    console.log("add key listener", keyname, identifier)
    if (!handlers[keyname]) handlers[keyname] = []

    handlers[keyname].push({ identifier, priority, callback })
  },
  removeKeyListener(keyname, identifier) {
    console.log("remove key listener", keyname, identifier)
    handlers[keyname] = handlers[keyname].filter(
      e => e.identifier !== identifier
    )
  },
}
