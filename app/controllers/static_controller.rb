class StaticController < ApplicationController
  include ApplicationHelper
  
  def about
    render "static/about"
  end
   
  def privacy
    render "static/privacy"
  end
  def blog
    render "static/blog"
  end
	def contact_us
    render "static/contact_us"
  end
	def send_contact_us
    name = params[:name]
    email = params[:email]
		comment = params[:comment]
    
    if  !name.empty? and !comment.empty? and (email =~ /@/)
			if !verify_solvemedia_puzzle 
	 		  @user_error = t(:captcha_error, :scope =>[:politwoops, :error])
		    render 'contact_us'
			else
  			UserMailer.contact_us(name, email, comment).deliver
     		redirect_to("/")
   		end
    
    else
      @user_error = t(:contact_us_error, :scope =>[:politwoops, :error])
      render 'contact_us'
    end

  end
end
