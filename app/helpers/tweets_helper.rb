module TweetsHelper
  def format_user_name(tweet_content)
    tweet_content.gsub(/(@(\w+))/, %Q{<a href="http://twitter.com/\\2" target="_blank">\\1</a>})
  end
  
  def format_hashtag(tweet_content)
    tweet_content.gsub(/(#(\w+))/, %Q{<a href="https://twitter.com/#!/search?q=%23\\2" target="_blank">\\1</a>})
  end
  
  def format_tweet(tweet)
    content = auto_link(format_user_name(format_hashtag(tweet.content)), :html => { :target => '_blank' }) if tweet.content
  end

  def avatar_url(politician)
    politician.profile_image_url
  end

  def byline(tweet, html = true)
    tweet_when = time_ago_in_words tweet.modified
    delete_delay = (tweet.modified - tweet.created).to_i

    if delete_delay > 1
      delay = t("after", :scope => [:politwoops, :tweets]) + ' '
      delay += if delete_delay > (60 * 60 * 24 * 7)
         "#{delete_delay / (60 * 60 * 24 * 7)}" + ' ' + t("week", :scope => [:politwoops, :tweets])
      elsif delete_delay > (60 * 60 * 24)
        "#{delete_delay / (60 * 60 * 24)}" + ' ' + t("day",:scope => [:politwoops, :tweets])
      elsif delete_delay > (60 * 60)
        "#{delete_delay / (60 * 60)}" + ' ' + t("hour",:scope => [:politwoops, :tweets])
      elsif delete_delay > 60
        "#{delete_delay / 60}" + ' ' + t("minute", :scope => [:politwoops, :tweets])
      elsif delete_delay > 1
        "#{delete_delay}" + ' ' + t("second",:scope => [:politwoops, :tweets])
      else
        ""
      end
      
      delay += ' ' + t("from_publishing_it", :scope => [:politwoops, :tweets])
    else
      delay = t("immediately", :scope => [:politwoops, :tweets])
    end
    
    if html
      tweet_when = "<a class=\"linkUnderline\" href=\"/tweet/#{tweet.id}\">#{tweet_when}</a>"
      source = tweet.details["source"].to_s.html_safe
      byline = "<a href=\"http://twitter.com/#{tweet.politician.user_name}\" class=\"twitter\">#{tweet.details['user']['name']}</a>".html_safe
      byline += t(:byline,:scope => [:politwoops, :tweets], :when => tweet_when, :what => source, :delay => delay).html_safe
      byline
    else
      t(:byline_text, :scope => [:politwoops, :tweets], :when => tweet_when, :delay => delay).html_safe
    end
  end

  def rss_date(time)
    time.strftime "%a, %d %b %Y %H:%M:%S %z"
  end

end