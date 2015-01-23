class Github
  require 'octokit'

  class Payload
    def initialize(payload)
      @data = JSON.parse(payload)
    end

    # _ballラベルのリストを取得
    def ball_tags
      return [] unless @data['action'] == 'created' || @data['action'] == 'opened'
      if @data['action'] == 'created' && @data.has_key?('issue') #issueとプルリクにコメントが追加された場合
        create_tags_from_message(@data['comment']['body'])
      elsif @data['action'] == 'opend' && @data.has_key?('issue') #issueが新規作成された場合
        create_tags_from_message(@data['issue']['body'])
      elsif @data['action'] == 'opend' && @data.has_key?('pull_request') # プルリクが新規作成された場合
        create_tags_from_message(@data['pull_request']['body'])
      end
    end

    # issue番号を取得
    def number
      return nil unless @data['action'] == 'created' || @data['action'] == 'opened'
      if @data.has_key?('issue') #issueの場合
        @data['issue']['number']
      elsif @data.has_key?('pull_request') # プルリクの場合
        @data['pull_request']['number']
      else
        nil
      end
    end

    # 書き込み内容からタグを生成
    def create_tags_from_message(message)
      list = message.scan(/@[a-z0-9_-]+/i)
      list.map { |v| v.sub('@','') + '_ball' }
    end
  end

  def self.update_ball_tag(payload)
    self.new(payload).run
  end

  def initialize(arg)
    @payload = Payload.new(arg)
    @repos = 'kazuhisa/gitball'
    @client = Octokit::Client.new(:access_token => ENV['GITHUB_ACCESS_TOKEN'])
  end

  def run
    return if @payload.number.nil?
    remove_ball_labels(@payload.number)
    add_labels_to_an_issue(@payload.number, @payload.ball_tags)
  end

  # issueにラベルを追加する
  def add_labels_to_an_issue(issue_number, label_names)
    @client.add_labels_to_an_issue(@repos, issue_number, label_names)
  end

  # issueに付けられてるラベルを取り外す
  def remove_label(issue_number, label_name)
    @client.remove_label(@repos, issue_number, label_name)
  end

  # issueに付けられているラベルの一覧を取得する
  def labels_for_issue(issue_number)
    @client.labels_for_issue(@repos, issue_number)
  end

  # issueに付けられているballラベルを全て除去する
  def remove_ball_labels(issue_number)
    labes = labels_for_issue(issue_number)
    labes.select { |v| v[:name] =~ /_ball$/ }.each do |label|
      remove_label(issue_number, label[:name])
    end
  end
end