class GitBall < Grape::API
  format :json

  # サイネージ承認結果受信
  resource :comment do
    params do
      requires :Parameters, type: String
    end

    post '/' do
      logger.info(params[:Parameters])
    end
  end
end
