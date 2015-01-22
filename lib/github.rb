class Github
  require 'octokit'
  def self.update_ball_tag(payload)
    self.new(payload).run
  end

  def initialize(payload)
    @data = JSON.parse(payload)
    @repos = 'kazuhisa/gitball'
    @client = Octokit::Client.new(:access_token => ENV['GITHUB_ACCESS_TOKEN'])
  end

  def run
    issue_number = @data['issue']['number']
    remove_ball_labels(issue_number)
    tags = create_tags_from_message(@data['comment']['body'])
    add_labels_to_an_issue(issue_number, tags)
  rescue
    raise @data.to_s
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

  # 書き込み内容からタグを生成
  def create_tags_from_message(message)
    list = message.scan(/@[a-z0-9_-]+/i)
    list.map { |v| v.sub('@','') + '_ball' }
  end
end