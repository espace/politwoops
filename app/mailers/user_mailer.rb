class UserMailer < ActionMailer::Base
  default :from => "suggest@kelmetak.com", 
  		  :to => "info@kelmetak.com"
  
  def suggest_politician(politician, name, email)
  	@name = name
  	@email = email

  	@politician = politician
  	@url = 'http://2ad.kelmetak.com'
  	
  	mail(:to => "info@kelmetak.com", :subject => "Politician suggestion from #{name}")
  end
  def contact_us(name, email, comment)
  	@name = name
  	@email = email

  	@comment = comment
  	
  	mail(:to => "info@kelmetak.com", :subject => "contact from #{name}")
  end

end
