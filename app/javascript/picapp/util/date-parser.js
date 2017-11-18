import SugarDate from 'picapp/util/sugar-date'

/* eslint no-restricted-globals: 0 */

const checkInvalid = (date) => {
  if (isNaN(date.getTime())) {
    return null
  } else {
    return date;
  }
}

const dateParser = (string) => {
  let from;
  let to;
  let match;

  match = string.match(/^(\d{4})$/)
  if (match) {
    from = new Date(parseInt(match[1], 10), 0, 1)
    to = new Date(parseInt(match[1], 10), 11, 31)
    return [from, to]
  }
  match = string.match(/^(\d{4}) *- *(\d{4})$/)
  if (match) {
    from = new Date(parseInt(match[1], 10), 0, 1)
    to = new Date(parseInt(match[2], 10), 11, 31)
    return [from, to]
  }
  match = string.match(/^>(.+)/)
  if (match) {
    from = SugarDate.create(match[1])
    to = null
    return [from, to]
  }
  match = string.match(/^<(.+)/)
  if (match) {
    to = SugarDate.create(match[1])
    from = null
    return [from, to]
  }
  match = string.match(/^(.*)-(.*)/)
  if (match) {
    from = SugarDate.create(match[1])
    to = SugarDate.create(match[2])
    return [from, to]
  }

  SugarDate.setLocale('de')
  let range = SugarDate.range(string)
  from = checkInvalid(range.start)
  to = checkInvalid(range.end)
  if (from || to) {
    return [from, to]
  }
  SugarDate.setLocale('en')
  range = SugarDate.range(string)
  from = checkInvalid(range.start)
  to = checkInvalid(range.end)
  if (from || to) {
    return [from, to]
  }

  return false
}

export default dateParser
