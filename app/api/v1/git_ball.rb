class GitBall < Grape::API
  format :json

  resource :comment do
    params do
      requires :Parameters, type: String
    end

    post '/' do
      PostLog.create(data: params[:Parameters].to_s)
    end
  end
end
