class EventsController < ApplicationController
  
  def tournament
  end
  
  def tournament_thanks
    url = 'http://spreadsheets.google.com/a/ashevillesunsoo.com/ccc?key=0AvlaqWAgxnlsdHNZRDRFVjJmSmU1Qi1qV1dFYzN0U2c&hl=en'
    
    response_map =
      [
       ['entry.0.single', 'First name'],
       ['entry.2.single', 'Last name'],
       ['entry.19.single', 'City'],
       ['entry.21.single', 'State'],
       ['entry.29.single', 'Email'],
       ['entry.48.single', 'School'],
       ['entry.7.group', 'Events']
      ]
    
    if session[:form_data] and !session[:form_data][:notification_sent]
      RegistrationCompleteMailer.deliver_registration_notification('JTF 2010 Tournament',
                                                                   session[:form_data],
                                                                   response_map,
                                                                   url)
      session[:form_data][:notification_sent] = true
    end
  end
  
  def summer_camp
  end

  def summer_camp_thanks
  end
end
