class GitBall < Grape::API
  format :json

  resource :comment do
    params do
      requires :Parameters, type: String
    end

    post '/' do
      logger.debug(params)
      PostLog.create(data: params[:Parameters].to_s)
    end
  end
end
