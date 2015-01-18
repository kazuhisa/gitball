class GitBall < Grape::API
  format :json

  resource :comment do
    params do
      requires :Parameters, type: String
    end

    post '/' do
      logger.info(params[:Parameters])
    end
  end
end
