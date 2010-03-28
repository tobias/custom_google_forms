class OperateFormController < ApplicationController
  def index
    #@forms = GoogleForm.all
    redirect_to 'http://ashevilletkd.com/'
  end
  
  def show
    slug = params[:slug].first
    if @google_form = GoogleForm.find_by_slug(slug)
      response  = @google_form.fetch_form_page!
      form_html = response.body
      doc       = clean_up_html(form_html)
      render :text => doc.to_html
    else
      redirect_to '/'
    end
  end
  
  def update
    if @google_form = GoogleForm.find(params[:id])
      params.delete(:id)
      params.delete(:action)
      params.delete(:controller)
      
      params.each do |key, value|
        if key =~ /\.group$/ and value.is_a?(Array)
          params[key] = value.join(', ')
        end
      end

      google_form_action = params.delete(:google_form)
      
      session[:form_data] = params

      Rails.logger.info "#### #{params.inspect}"
      response = @google_form.submit(google_form_action, params)
      result_html = response.body
      if result_html =~ %r{<title>Thanks!<\/title>}
        redirect_to @google_form.thank_you_path.blank? ? '/thankyou.html' : @google_form.thank_you_path
      elsif result_html =~ /Moved Temporarily/
        render :text => "Ooh, this form has been moved or disabled. How odd."
      else
        if doc = clean_up_html(result_html)
          render :text => doc.to_html
        else
          render :text => result_html
        end
      end
    end
  end
  
  private
  def clean_up_html(form_html)
    doc = Nokogiri::HTML(form_html)
    doc.xpath("//*[@style]").remove_attr('style')
    doc.xpath("//*[@class='ss-legal']").each { |n| n.unlink }
    doc.xpath("//link").each { |n| n.unlink }
    doc.xpath("//style").each { |n| n.unlink }

    google_form = doc.xpath("//form").first
    return false unless google_form
    google_form_action = google_form["action"]
    google_form["action"] = submit_operate_form_url(:id => @google_form.id, :google_form => google_form_action)

    google_form.css("li.ss-choice-item input[type=checkbox]").each do |cb|
      cb['name'] += "[]"
    end

    google_form.css('.ss-navigate input').each do |inp|
      inp['value'] = 'Submit Registration'
    end

    css_node = doc.create_element('link')
    css_node["href"] = "/stylesheets/reset.css"
    css_node["rel"] = "stylesheet"
    css_node["type"] = "text/css"
    doc.xpath("//head").first.add_child(css_node)
    
    css_node = doc.create_element('link')
    css_node["href"] = "/stylesheets/style.css"
    css_node["rel"] = "stylesheet"
    css_node["type"] = "text/css"
    doc.xpath("//head").first.add_child(css_node)
    
    footer = doc.create_element('div')
    footer["id"] = "footer"
    doc.xpath("//body").first.add_child(footer)
    
    analytics = doc.create_element('div')
    analytics.inner_html = render_to_string :partial => 'layouts/google_analytics'
    doc.xpath("//body").first.add_child(analytics)
    doc
  end
end
