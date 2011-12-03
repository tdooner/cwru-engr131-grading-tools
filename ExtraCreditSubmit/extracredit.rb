require 'sinatra'
require 'active_record'
require 'delayed_job'
require 'haml'
require 'open3'
require 'casclient'
require 'json'

configure do
    ActiveRecord::Base.establish_connection({
        :adapter => "sqlite3",
        :database => "db/development.db"
    })
    ActiveRecord::Base.timestamped_migrations = false
    Delayed::Worker.backend = :active_record
    Delayed::Worker.max_run_time = 60.seconds
    Delayed::Worker.max_attempts = 1
    enable :sessions
    #@auth = CASClient::Client.new.configure(
    #    :cas_base_url => "https://login.case.edu/"
    #)
end

helpers do
    def logged_in
        session[:case_id]
    end
end

class Submission < ActiveRecord::Base
    after_create :queue
    belongs_to :problem
    validates_presence_of :problem_id, :code, :case_id

    def queue
        Delayed::Job.enqueue RunSubmission.new(self.id)
    end
    def calculate_scores
        return 'unknown' unless self.output
        results = YAML::load(self.output)
        self.problem.problem_inputs.map{|i|
            begin
                if results[i.id][:output].join() == i.expected_output
                    i.points
                else
                    0
                end
            rescue
                0
            end
        }
    end    
end
class RunSubmission < Struct.new(:submission_id)
    def perform
        submission.update_attribute(:status, 100)
        submission.update_attribute(:output, self.run_matlab)
        submission.update_attribute(:status, 200)
    end

    def error(job, exception)
        submission.update_attribute(:status, 500)
        submission.update_attribute(:output, 'system error!')
    end

    def run_matlab
        return {} unless submission.problem && submission.problem.problem_inputs
        submission.problem.problem_inputs.inject({}){|a,i|
            start = Time.now
            stdin, stdout, stderr, _ = Open3.popen3("matlab -nodisplay -nosplash -r \"#{submission.code};quit;\"")
            i.input.split("\n").each do |i|
                stdin.puts(i)
            end
            
            a.merge({i.id => {:output=>stdout.to_a[10..-1], :duration=>Time.now-start}})
        }
    end
    private
        def submission
            @submission ||= Submission.find(submission_id)
        end
end
class Problem < ActiveRecord::Base
    has_many :problem_inputs
    has_many :submissions
end
class ProblemInput < ActiveRecord::Base
    belongs_to :problem
end

get '/' do
    return "Welcome to the site! <a href='/submit'>Submit some code!</a>"
end

=begin
get '/submit' do
    return redirect("/login") unless logged_in
    @problems = Problem.all
    haml :'submit'
end
=end
get '/problem/:problem_id' do
    @problem = Problem.find(params[:problem_id])
    @points = @problem.problem_inputs.map{|x| x.points}.sum
    haml :problem
end

get '/login' do
    return redirect("/") if logged_in
    return "Your Case ID, please: <form method='POST' action='/login'><input type='input' name='case_id'></form>"
end

post '/login' do
    session[:case_id] = params[:case_id]
    redirect("/")
end

post '/submit' do
    params[:case_id] = session[:case_id]
    sub = Submission.create! params
    redirect('/submissions/' + session[:case_id])
end

get '/submissions/:case_id' do
    haml :submissions
end

get '/json/submissions/:case_id' do
    sub = Submission.find_all_by_case_id(params[:case_id])
    sub.map{|x|
        {:id=>x.id, :submitted=>x.created_at, :score=>x.calculate_scores.sum, :status=>x.status, :problem=>x.problem.name}
    }.to_json
end
