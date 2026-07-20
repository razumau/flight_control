module FlightControl::DatesHelper
  def time_distance_in_words_with_title(time)
    tag.span time_ago_in_words_with_default_options(time), title: "Since #{time.to_fs(:long)}"
  end

  def bidirectional_time_distance_in_words_with_title(time)
    time_distance = if time.past?
      "#{time_ago_in_words_with_default_options(time)} ago"
    else
      "in #{time_ago_in_words_with_default_options(time)}"
    end

    tag.span time_distance, title: time.to_fs(:long)
  end

  # Renders "2026-07-10 12:32:15 UTC (about 4 hours ago)". The local-time
  # Stimulus controller prepends the timestamp in the browser's timezone,
  # which the server can't know.
  def timestamp_with_relative_time(time)
    time = time.to_time.utc
    safe_join [
      tag.span(time.strftime("%Y-%m-%d %H:%M:%S UTC"), data: {controller: "local-time", local_time_datetime_value: time.iso8601}),
      " (#{time_ago_in_words_with_default_options(time)} ago)"
    ]
  end

  def time_ago_in_words_with_default_options(time)
    time_ago_in_words(time, include_seconds: true, locale: :en)
  end
end
