class HomeController < ApplicationController

  def index
    # TODO: make this configurable
    @top_practice = Practice.find_by(name: 'Project HAPPEN')


    # display the "Terrible Trio"
    # TODO: make configurable
    naloxone = Practice.find_by(name: 'VHA Rapid Naloxone')
    my_life_my_story = Practice.find_by(name: 'FLOW3')
    stride = Practice.find_by(name: 'VIONE')

    @featured_practices = [naloxone, my_life_my_story, stride]

    @facilities_data = facilities_json['features']
  end

end
