class GitBall < Grape::API
  format :json

  resource :comment do
    params do
      requires :payload, type: String
    end

    post '/' do
      PostLog.create(data: params.payload.to_s)
    end
  end
end
