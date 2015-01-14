Time::DATE_FORMATS[:just_year] = '%Y'
Time::DATE_FORMATS[:d_m] = "%d-%b"
Time::DATE_FORMATS[:d_m_y] = "%d %b %Y"
Time::DATE_FORMATS[:d_m_y_h_m] = "%d/%m/%y (%H:%M)"
Time::DATE_FORMATS[:long_d_m_y_h_m] = "%d %b %Y - %H:%M"
Time::DATE_FORMATS[:h_m] = "%H:%M"

# Time::DATE_FORMATS[:short_ordinal] = lambda { |time| time.strftime("%B #{time.day.ordinalize}") }