Time::DATE_FORMATS[:just_year] = '%Y'
Time::DATE_FORMATS[:d_m] = "%d-%b"
Time::DATE_FORMATS[:d_m_y] = "%d %b %Y"

# Time::DATE_FORMATS[:short_ordinal] = lambda { |time| time.strftime("%B #{time.day.ordinalize}") }