class StaticController < ApplicationController
  include ApplicationHelper
  
  def about
    render "static/about"
  end
   
  def privacy
    render "static/privacy"
  end
  
	def contact_us
    render "static/contact_us"
  end
	def send_contact_us
    name = params[:name]
    email = params[:email]
		comment = params[:comment]
    if  !name.empty? and !comment.empty? and (email =~ /@/)
      UserMailer.contact_us(name, email, comment).deliver
      redirect_to("/")
    else
      redirect_to("/")
    end

  end
end
