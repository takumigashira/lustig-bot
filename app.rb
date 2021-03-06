require 'sinatra'
require 'line/bot'

module Line
  module Bot
    class HTTPClient
      def http(uri)
        proxy = URI(ENV["FIXIE_URL"])
        http = Net::HTTP.new(uri.host, uri.port, proxy.host, proxy.port, proxy.user, proxy.password)
        if uri.scheme == "https"
          http.use_ssl = true
        end

        http
      end
    end
  end
end

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  p events

  events.each { |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        case event.message['text'] #Webhook event objectの送信されたtextを参照
        when 'こんにちは'
          message = {
             type: 'text',
             text: 'Guten Tag!'
          }
          res = client.reply_message(event['replyToken'], message)
          p res
          p res.body

        when 'おはよう'
          message = {
             type: 'text',
             text: 'Guten Morgen'
          }
          res = client.reply_message(event['replyToken'], message)
          p res
          p res.body
          
        when 'こんばんわ'
          message = {
             type: 'text',
             text: 'Guten Abend'
          }
          res = client.reply_message(event['replyToken'], message)
          p res
          p res.body  

        when 'おやすみ'
          message = {
             type: 'text',
             text: 'Gute  Nacht'
          }
          res = client.reply_message(event['replyToken'], message)
          p res
          p res.body
          
        else
          message = {
            type: 'text',
            text: event.message['text']
          }
          res = client.reply_message(event['replyToken'], message)
          p res
          p res.body
      end
    end
  end
 
  }

  "OK"
end