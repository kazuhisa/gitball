class Github
  require 'octokit'

  class Payload
    def initialize(payload)
      @data = JSON.parse(payload)
    end

    # Getting '_ball' label lists.
    def ball_tags
      return [] unless @data['action'] == 'created' || @data['action'] == 'opened'
      if @data['action'] == 'created' && @data.has_key?('issue') # add issue and pullreq comment.
        create_tags_from_message(@data['comment']['body'])
      elsif @data['action'] == 'opened' && @data.has_key?('issue') # create issue.
        create_tags_from_message(@data['issue']['body'])
      elsif @data['action'] == 'opened' && @data.has_key?('pull_request') # create pullreq.
        create_tags_from_message(@data['pull_request']['body'])
      end
    end

    # Getting issue number
    def number
      return nil unless @data['action'] == 'created' || @data['action'] == 'opened'
      if @data.has_key?('issue') # issue
        @data['issue']['number']
      elsif @data.has_key?('pull_request') # pullreq
        @data['pull_request']['number']
      else
        nil
      end
    end

    # create tags from message.
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

  # add label for issue
  def add_labels_to_an_issue(issue_number, label_names)
    @client.add_labels_to_an_issue(@repos, issue_number, label_names)
  end

  # remove label from issue
  def remove_label(issue_number, label_name)
    @client.remove_label(@repos, issue_number, label_name)
  end

  # getting labels from issue
  def labels_for_issue(issue_number)
    @client.labels_for_issue(@repos, issue_number)
  end

  # remove all labels from issue
  def remove_ball_labels(issue_number)
    labes = labels_for_issue(issue_number)
    labes.select { |v| v[:name] =~ /_ball$/ }.each do |label|
      remove_label(issue_number, label[:name])
    end
  end
end