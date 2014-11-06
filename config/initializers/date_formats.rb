Date::DATE_FORMATS[:just_year] = "%Y"
Date::DATE_FORMATS[:day_month_year] = "%d-%b-%Y"
Date::DATE_FORMATS[:day_month] = "%d-%b"
Date::DATE_FORMATS[:d_m_time] = "%d-%b %H:%M"
# Date::DATE_FORMATS[:short_ordinal] = ->(date) { date.strftime("%B #{date.day.ordinalize}") }