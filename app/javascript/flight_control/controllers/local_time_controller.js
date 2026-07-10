import { Controller } from "@hotwired/stimulus"

// Replaces a server-rendered UTC timestamp with "<browser-local time> · <UTC time>".
// Leaves the UTC-only fallback in place when the browser's timezone is UTC.
export default class extends Controller {
  static values = { datetime: String }

  connect() {
    const date = new Date(this.datetimeValue)
    if (isNaN(date)) return

    const local = this.format(date)
    const utc = this.format(date, "UTC")
    this.element.textContent = local === utc ? utc : `${local} · ${utc}`
  }

  format(date, timeZone = undefined) {
    // en-CA yields "2026-07-10, 12:32:15 UTC"
    return new Intl.DateTimeFormat("en-CA", {
      timeZone,
      year: "numeric", month: "2-digit", day: "2-digit",
      hour: "2-digit", minute: "2-digit", second: "2-digit",
      hourCycle: "h23",
      timeZoneName: "short"
    }).format(date).replace(",", "")
  }
}
