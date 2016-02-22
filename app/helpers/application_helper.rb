module ApplicationHelper

  def format_date(date)
	return date.localtime.strftime("%-m-%e-%Y %l:%M %p EST")
  end
end
