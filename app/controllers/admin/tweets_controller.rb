class Admin::TweetsController < Admin::AdminController
  before_filter :load_tweet, :only => [:review, :message, :next_tweets]
  helper TweetsHelper
  # list either unreviewed
  def index
    if params[:politician_id] and !params[:politician_id].blank?
      @politicians = Politician.find(params[:politician_id])
    else
      @politicians = Politician.active.all
    end

    @all_politicians = Politician.active.all

    @tweets = DeletedTweet.where(:politician_id => @politicians)
    per_page = params[:per_page] ? params[:per_page].to_i : nil
    per_page ||= Tweet.per_page
    per_page = 200 if per_page > 200
    # filter to relevant subset of deleted tweets
    @tweets = @tweets.where :reviewed => params[:reviewed], :approved => params[:approved]

    # show unreviewed tweets oldest to newest
    if !params[:reviewed]
      @tweets = @tweets.reorder "modified DESC"
    end

    @tweets = @tweets.includes(:politician => [:party]).paginate(:page => params[:page], :per_page => per_page)
    @admin = true

    respond_to do |format|
      format.html # admin/tweets/index.html.erb
      format.rss do
        response.headers["Content-Type"] = "application/rss+xml; charset=utf-8"
        render "tweets/index"
      end
    end
  end
 
  def reject
    page = params[:page] || 1
    politician_id = params[:politician_id] || nil
    ids = params[:ids]
    ids_list = ids.split(',')
    
    for id in ids_list
      @deleted_tweet = DeletedTweet.find(id)
      
      @deleted_tweet.reviewed = true
      @deleted_tweet.approved = false
      @deleted_tweet.reviewed_at =  Time.now
      @deleted_tweet.reviewed_by = current_admin
      
      if @deleted_tweet.save!
        flash[:success_message] = t "rejected",:scope => [:politwoops,:admin]
      else
        flash[:review_message] = t "note_is_missing",:scope => [:politwoops,:admin]
      end
    end

    redirect_to "/admin/review?page=#{page}#{politician_id ? '&politician_id='+ params[:politician_id].to_s : '' }"
  end

  def approve
    page = params[:page] || 1
    politician_id = params[:politician_id] || nil
    ids = params[:ids]
    ids_list = ids.split(',')
    
    for id in ids_list
      @deleted_tweet = DeletedTweet.find(id)
      
      @deleted_tweet.reviewed = true
      @deleted_tweet.approved = true
      @deleted_tweet.reviewed_at =  Time.now
      @deleted_tweet.reviewed_by = current_admin
      
      if @deleted_tweet.save!
        flash[:success_message] = t "approved",:scope => [:politwoops,:admin]
      else
        flash[:review_message] = t "note_is_missing",:scope => [:politwoops,:admin]
      end
    end

    redirect_to "/admin/review?page=#{page}#{politician_id ? '&politician_id='+ params[:politician_id].to_s : '' }"
  end
  
  # approve or unapprove a tweet, mark it as reviewed either way
  def review
    
    review_message = (params[:review_message] || "").strip

    if [t(:approve, :scope => [:politwoops,:admin]), t(:unapprove, :scope => [:politwoops,:admin])].include?(params[:commit])
      approved = (params[:commit] == t(:approve, :scope => [:politwoops,:admin]))

      # if approved and review_message.blank?
      #   flash[:review_message] = t "note_is_missing",:scope => [:politwoops,:admin]
      #   #t "You need to add a note about why you're approving this tweet."
      #   redirect_to params[:return_to]
      #   return false
      # end

      @tweet.approved = approved
      @tweet.reviewed = true
      @tweet.reviewed_at = Time.now
    end

    if review_message.any?
      @tweet.review_message = review_message
    end
    
    @tweet.reviewed_by = current_admin
    
    @tweet.save!
    expire_action :controller => '/tweets', :action => :index
    
    
    respond_to do |format|
      format.html do 
        redirect_to params[:return_to]
      end
      format.js
    end
  end
  
  def next_tweets
    @next_tweets = Tweet.where(["id > ? and politician_id = ? ", @tweet.id, @tweet.politician_id]).order("id asc").limit(2)
    
    respond_to do |format|
      format.js
    end
  end
  # filters
  def load_tweet
    unless params[:id] and (@tweet = DeletedTweet.find(params[:id]))
      render :nothing => true, :status => :not_found
      return false
    end
  end

 
  
 

end
