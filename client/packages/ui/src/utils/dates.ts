export const formatDate = (
  date: string | number | Date,
  options?: Intl.DateTimeFormatOptions
) => {
  const defaultOptions = options || {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: 'numeric',
    minute: 'numeric'
  }
  return new Intl.DateTimeFormat('default', defaultOptions).format(
    new Date(date)
  )
}

export const formatUnixTs = (
  unixTs: string | number = 0,
  options?: Intl.DateTimeFormatOptions
) => formatDate(Number(unixTs) * 1000, options)

export const formatFinishDate = (
  unixTsStartDate: string,
  hours: number,
  options?: Intl.DateTimeFormatOptions
) => formatUnixTs(Number(unixTsStartDate) + hours * 3600, options)

export const convertUnixTimeToDuration = (durationInSeconds: number) => {
  const days = Math.floor(durationInSeconds / 86400)
  durationInSeconds %= 86400
  const hours = Math.floor(durationInSeconds / 3600)
  durationInSeconds %= 3600
  const minutes = Math.floor(durationInSeconds / 60)
  const seconds = durationInSeconds % 60
  const timeUnits: string[] = []
  if (days > 0) {
    timeUnits.push(`${days} day${days > 1 ? 's' : ''}`)
  }
  if (hours > 0) {
    timeUnits.push(`${hours} hour${hours > 1 ? 's' : ''}`)
  }
  if (minutes > 0) {
    timeUnits.push(`${minutes} minute${minutes > 1 ? 's' : ''}`)
  }
  if (seconds > 0) {
    timeUnits.push(`${seconds} second${seconds > 1 ? 's' : ''}`)
  }
  const durationString = timeUnits.join(' ')
  return durationString
}
