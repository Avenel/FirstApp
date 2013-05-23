module ApplicationHelper

  # Spaltensortierung in einer Tabelle. NU
  def sortable(column, title = nil)
    title ||= column.titleize
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, :sort => column, :direction => direction
  end

  def resource_name
    :OZBPerson
  end

  def resource
    @resource = current_OZBPerson || OZBPerson.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:OZBPerson]
  end
  
  def devise_error_messages!
    return "" if resource.errors.empty?
  
    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = I18n.t("errors.messages.not_saved",
                      :count => resource.errors.count,
                      :resource => resource_name)
  
    html = <<-HTML
            <div id='error'>
              <h2>{sentence}<h2>
              <p>#{messages}</p>
  
          </div>
    HTML
  
    html.html_safe
  end
  




  
  # application_helper.rb
  # https://gist.github.com/1205828
  # Based on https://gist.github.com/1182136
  # Based on https://gist.github.com/1205828, in turn based on https://gist.github.com/1182136
  class BootstrapLinkRenderer < ::WillPaginate::ActionView::LinkRenderer
    protected

    def html_container(html)
      tag :div, tag(:ul, html), container_attributes
    end

    def page_number(page)
      tag :li, link(page, page, :rel => rel_value(page)), :class => ('active' if page == current_page)
    end

    def gap
      tag :li, link(super, '#'), :class => 'disabled'
    end

    def previous_or_next_page(page, text, classname)
      tag :li, link(text, page || '#'), :class => [classname[0..3], classname, ('disabled' unless page)].join(' ')
    end
  end

  def page_navigation_links(pages)
    will_paginate(pages, :class => 'pagination pagination-centered', :inner_window => 2, :outer_window => 0, :renderer => BootstrapLinkRenderer, :previous_label => '&laquo;'.html_safe, :next_label => '&raquo;'.html_safe)
  end
  
  # defines a more simpler errors.full_messages method for the application
  # and does not show any associated object names which is a bit confusing for
  # the users.
  def simple_form_errors(object)
    if object.kind_of?(String) || object.kind_of?(Array) || (!object.errors.nil? && object.errors.any?)
      html_output = ""
      
      html_output += '<div class="alert alert-error" id="error_explanation">'
      html_output += '<h3>Fehler beim Speichern der Daten:</h3>' 
      html_output += '  <ul>'
      
      if (object.kind_of?(Array))
        object.each do |error|
          html_output += '<li>' + error + '</li>'
        end
      elsif (object.kind_of?(String))
        html_output += '<li>' + object + '</li>'
      else
        object.errors.to_hash.each do |key, error|
          html_output += '<li>' + object.class.human_attribute_name(key.to_sym) + ' ' + error.to_s + '</li>'
        end
      end
      
      html_output += '  </ul>'
      html_output += '</div>'
      
      html_output.html_safe
    end
  end
end