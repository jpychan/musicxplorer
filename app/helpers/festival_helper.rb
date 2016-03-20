module FestivalHelper
  def display(info)
    info.nil? || info == 0 ? 'n/a' : info
  end
end
