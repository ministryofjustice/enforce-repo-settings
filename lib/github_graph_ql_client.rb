class GithubGraphQlClient
  attr_reader :github_token

  GITHUB_GRAPHQL_URL = "https://api.github.com/graphql"

  def initialize(params)
    @github_token = params.fetch(:github_token)
  end

  def run_query(body)
    puts "run_query:\n#{body}\n"

    json = {query: body}.to_json
    headers = {"Authorization" => "bearer #{github_token}"}

    uri = URI.parse(GITHUB_GRAPHQL_URL)
    resp = Net::HTTP.post(uri, json, headers)

    puts "response:\n#{resp.body}\n"

    resp.body
  end
end
