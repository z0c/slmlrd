require_relative 'exceptions'
require 'nokogiri'
require 'rest-client'

module Slmlrd
  # ImageTwist
  class ImageTwist
    HOME_URL = 'http://imagetwist.com/'.freeze
    UPLOAD_URL_GALLERY = 'http://img114.imagetwist.com/cgi-bin/upload.cgi?upload_id=124684505799&js_on=1&utype=reg&upload_type=url'.freeze
    UPLOAD_ERROR_TEXT = 'ERROR: Server don\\\'t allow uploads at the moment'.freeze

    def initialize(config)
      @username = config['username']
      @password = config['password']
      @cookies_hash = nil
    end

    def login
      RestClient.post(
        HOME_URL,
        login_params
      ) do |resp, _request, _result, &_block|
        raise Exceptions::LoginError unless resp.code == 302
        @cookies_hash = resp.cookies
      end
    end

    def logged_in?
      @cookies_hash.nil? ? false : true
    end

    def folders
      login unless logged_in?
      resp = RestClient.get(
        HOME_URL,
        params: folder_params,
        cookies: @cookies_hash
      )
      raise Exceptions::ResponseCodeError, resp.code unless resp.code == 200
      parse_folders(Nokogiri::HTML(resp.body))
    end

    def get_folder(name)
      login unless logged_in?
      folders
        .select { |folder| folder['name'] == name }
        .first
    end

    def create_folder(folder_name, domain)
      login unless logged_in?
      domain ||= 'imagetwist.com'
      RestClient.post(
        HOME_URL,
        create_folder_params(folder_name, domain),
        cookies: @cookies_hash
      ) do |resp, _req, _result, &_block|
        raise Exceptions::ResponseCodeError, resp.body unless resp.code == 302
      end
    end

    def upload_urls_to_folder(folder_id, images_array, upload_domain)
      login unless logged_in?
      upload_domain ||= 'imagetwist.com'
      resp = RestClient.post(
        UPLOAD_URL_GALLERY,
        upload_urls_params(images_array, upload_domain, folder_id),
        cookies: @cookies_hash
      )
      raise Exceptions::ResponseCodeError, resp.code unless resp.code == 200
      raise Exceptions::UploadFailed if resp.body.include? UPLOAD_ERROR_TEXT
    end

    def session_id
      login unless logged_in?
      resp = RestClient.get(HOME_URL, cookies: @cookies_hash)
      raise Exceptions::ResponseCodeError, resp.code unless resp.code == 200
      parse_session_id(resp.body)
    end

    def get_urls_in_folder(folder_id, domain)
      login unless logged_in?

      resp = RestClient.post(
        HOME_URL,
        urls_in_folder_params(domain, folder_id),
        cookies: @cookies_hash
      )

      raise Exceptions::ResponseCodeError, resp.code unless resp.code == 200

      parse_urls_in_folder(resp.body)
    end

    def delete_folder(folder_id)
      login unless logged_in?
      resp = RestClient.get(
        HOME_URL,
        params: delete_folder_params(folder_id),
        cookies: @cookies_hash
      )
      code = resp.history.first.code
      raise Exceptions::ResponseCodeError, code unless code == 302
    end

    private

    def parse_folders(page)
      folders = []
      page.css('[@name="s_fld_id"]').each do |n|
        folders.push(
          'id' => n['value'],
          'name' => n.next_element.text,
          'href' => n.parent
                     .element_children.last.element_children.first['href'].to_s
        )
      end

      folders
    end

    def parse_urls_in_folder(body)
      urls = []
      Nokogiri::HTML(body).css('textarea').first.text.each_line do |line|
        urls.push(line)
      end
      urls
    end

    def parse_session_id(body)
      Nokogiri::HTML(body)
              .css('[@name="sess_id"]')
              .first['value']
              .to_s
    end

    def login_params
      {
        op: 'login',
        redirect: '',
        login: @username,
        password: @password,
        submit_btn: 'Login'
      }
    end

    def create_folder_params(folder_name, domain)
      {
        op: 'my_files',
        fld_id: 0,
        sort_field: 'file_created',
        sort_order: 'down',
        export_mode: '',
        domain: domain,
        create_new_folder: folder_name,
        to_folder: ''
      }
    end

    def upload_urls_params(images_array, upload_domain, folder_id)
      {
        content_type: 'application/x-www-form-urlencoded',
        multipart: true,
        sess_id: session_id,
        upload_type: 'url',
        mass_upload: '1',
        url_mass: images_array.join("\r\n"),
        thumb_size: '170x170',
        per_row: '1',
        sdomain: upload_domain,
        fld_id: folder_id,
        tos: '1',
        submit_btn: 'Upload'
      }
    end

    def urls_in_folder_params(domain, folder_id)
      {
        content_type: 'application/x-www-form-urlencoded',
        op: 'my_files_export',
        fld_id: 0,
        sort_field: 'file_created',
        sort_order: 'down',
        export_mode: 'folder',
        domain: domain,
        create_new_folder: '',
        s_fld_id: folder_id,
        to_folder: ''
      }
    end

    def folder_params
      {
        op: 'my_files',
        fld_id: ''
      }
    end

    def delete_folder_params(folder_id)
      {
        op: 'my_files',
        fld_id: 0,
        del_folder: folder_id
      }
    end
  end
end
