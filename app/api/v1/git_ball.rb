class GitBall < Grape::API
  format :json


  resource :comment do
    params do
      requires :payload, type: String
    end

    post '/' do
      Github.update_ball_tag(params.payload.to_s)
      PostLog.create(data: params.payload.to_s)
    end
  end
end
