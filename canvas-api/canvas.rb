require 'json'
require 'net/http'

module Canvas
  URL_BASE        = 'https://canvas.instructure.com/api/v1/'
  COURSES_URL     = URL_BASE + 'courses/'
  SECTIONS_URL    = URL_BASE + 'courses/%{course_id}/sections/'
  ASSIGNMENTS_URL = URL_BASE + 'courses/%{course_id}/assignments/'

  class Client
    def initialize(apikey)
      @apikey = apikey
    end

    # TODO: Make this a method of Course (i.e. Course.all)
    def courses
      request(COURSES_URL, {}, 'GET').map do |course|
        Course.new(self, course)
      end
    end

    def request(uri, uri_params = {}, method = 'GET')
      uri = URI(uri % uri_params)
      uri.query = URI.encode_www_form(uri_params)
      request_uri(uri, method)
    end

    def to_s
      return '<Canvas::Client>'
    end

    private

    def request_uri(uri, method)
      Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
        headers = { 'Authorization' => "Bearer #{@apikey}" }

        res = case method
              when 'GET'
                http.get([uri.path, uri.query].join('?'), headers)
              when 'POST'
                http.post(uri.path, URI.decode_www_form(uri.query), headers)
              end
        if res.is_a?(Net::HTTPOK)
          return JSON.parse(res.body)
        else
          raise Exception, "Request Failed! #{res}"
        end
      end
    end
  end

  class CanvasModel
    def initialize(client, attr)
      @client = client.freeze
      self.attributes = attr
    end

    def attributes=(attr)
      attr.each do |k,v|
        if self.respond_to?(setter = "#{k}=")
          self.send(setter, v)
        end
      end
    end
  end

  class Course < CanvasModel
    attr_accessor :id, :name, :course_code

    def sections(opts = {})
      uri_opts = [[:course_id, self.id]]
      opts[:with].each { |i| uri_opts << ['include[]', i] } if opts[:with]

      @client.request(SECTIONS_URL, Hash[uri_opts], 'GET').map do |s|
        Section.new(@client, s)
      end
    end

    def assignments(opts = {})
      uri_opts = [[:course_id, self.id]]

      @client.request(ASSIGNMENTS_URL, Hash[uri_opts], 'GET').map do |a|
        Assignment.new(@client, a)
      end
    end
  end

  class Section < CanvasModel
    attr_reader :students
    attr_accessor :id, :name, :course_id

    def students=(user_list)
      @students ||= user_list.map do |u|
        User.new(@client, u)
      end
    end

    def to_s
      self.name
    end
  end

  class User < CanvasModel
    attr_accessor :id, :name, :login_id, :email
  end

  class Assignment < CanvasModel
    attr_accessor :id, :name, :description, :course_id, :position,
      :points_possible

    def submissions(opts = {})
      if opts[:section].is_a?(Canvas::Section)
        uri = URL_BASE +
          "sections/#{opts[:section].id}/assignments/#{self.id}/submissions"
      else
        uri = ASSIGNMENTS_URL + "#{self.id}/submissions"
      end

      uri_opts = [[:course_id, self.course_id]]
      opts[:with].each { |i| uri_opts << ['include[]', i] } if opts[:with]

      @client.request(uri, Hash[uri_opts], 'GET').map do |s|
        Submission.new(@client, s)
      end
    end

    def to_s
      self.name
    end
  end

  class Submission < CanvasModel
    attr_reader :submission_comments
    attr_accessor :assignment_id, :body, :score, :submission_comments,
      :user_id, :html_url, :preview_url

    def submission_comments=(comment_list)
      @submission_comments ||= comment_list.map do |c|
        SubmissionComment.new(@client, c)
      end
    end

    def attachments
      @attachments || []
    end

    def attachments=(attachment_list)
      @attachments ||= attachment_list.map do |a|
        SubmissionAttachment.new(@client, a)
      end
    end
  end

  class SubmissionComment < CanvasModel
    attr_accessor :author_id, :author_name, :comment

    def to_s
      self.comment
    end
  end

  class SubmissionAttachment < CanvasModel
    attr_accessor :id, :filename, :size, :updated_at, :url, :display_name,
      :content_type
  end
end
