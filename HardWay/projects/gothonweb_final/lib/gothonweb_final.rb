require_relative "gothonweb_final/version"
require_relative "map"
require "sinatra"
require "erb"

use Rack::Session::Pool

get '/' do
    # This is used to "setup" the session with starting values
    p START
    session[:room] = START
    redirect("/game")
end

get '/game' do 
    if session[:room]
        erb :show_room, :locals => {:room => session[:room]}
    else
        # If any weird issue just die
        erb :you_died
    end 
end

post '/game' do
    action = "#{params[:action] || nil}"
    
    # Let's save the previous room name
    previousRoom = session[:room].name

    if session[:room]
        session[:room] = session[:room].go(params[:action])
        
        #check for the death message
        if session[:room] == nil
            session[:room] = DEATH
            if previousRoom == 'Laser Weapon Armory'
                session[:room].setMessage('wrongCode')
            elsif previousRoom == 'The Bridge'
                session[:room].setMessage('bridgeDeath')
            end
        elsif session[:room].name == 'death'
            session[:room].setMessage(params[:action])
        elsif session[:room].name == 'Laser Weapon Armory'
            session[:room].setMessage('hint')
        elsif session[:room].name == 'Wrong Pod'
            session[:room].setMessage('wrongPod')
        end
    end

    session[:room].previousRoom = previousRoom
    redirect("/game")
end