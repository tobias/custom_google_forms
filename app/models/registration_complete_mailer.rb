class RegistrationCompleteMailer < ActionMailer::Base
  

  def registration_notification(title, form_data, data_map, url)
    subject    "[#{title}] you have received a registration"
    recipients ENV['REGISTRATION_RECIPIENTS'] ? ENV['REGISTRATION_RECIPIENTS'].split(',') : ['tcrawley@gmail.com']
    from       'noreply@ashevillesunsoo.com'
    sent_on    Time.now
    
    data = []
    data_map.each do |key, label|
      data << "#{label}: #{form_data[key]}"
    end
    
    body       :data => data, :url => url
  end

end
