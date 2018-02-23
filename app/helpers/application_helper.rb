module ApplicationHelper
  def currency_format(value)
    number_to_currency(value, unit: "Rp ", separator: ",", delimiter: ".", precision: 0)
  end
end
