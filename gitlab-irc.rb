require 'rubygems'
require 'sinatra'
require 'json'

# IRC Config
IRC_HOST = 'irc.freenode.org'
IRC_PORT = 6667
IRC_CHANNEL = '#yourchannel'
IRC_NICK = 'GitLabBot'
IRC_REALNAME = 'GitLabBot'

post '/commit' do

  Thread.new do
    socket = TCPSocket.open(IRC_HOST, IRC_PORT)
    socket.puts("NICK #{IRC_NICK}")
    socket.puts("USER #{IRC_NICK} 8 * : #{IRC_REALNAME}")
    #socket.puts("JOIN #{IRC_CHANNEL}") # don't join, just send the msg directly -- make sure the channel is /mode -n
    
    # Don't send anything to the channel until we've been successfully authorized by the IRC server to do so
    while line = socket.gets
      if line.include? "376 #{IRC_NICK}"
        break
      end
    end

    json = JSON.parse(request.env["rack.input"].read)

    socket.puts "PRIVMSG #{IRC_CHANNEL} :New Commits for '" + json['repository']['name'] + "'"

    json['commits'].each do |commit|
      socket.puts "PRIVMSG #{IRC_CHANNEL} :by #{commit['author']['name']} | #{commit['message']} | #{commit['url']}"
    end

    puts socket.gets
    socket.close

    Thread.stop
  end

end
