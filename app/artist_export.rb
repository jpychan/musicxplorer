Festival.all.each do |festival|
  festival_json = {
    "id" => festival.id,
    "term" => festival.name,
    "data" => {
      "url" => "/festivals/#{festival.id}"
    }
  } 
File.open("festivals.json","a") do |f|
  f.write("#{festival_json.to_json} \n")
end
end 
