# Enforce Repository Settings

Given a reference to a github repository, enforce a standard set of permissions
and other settings.

## Pre-requisites

A `GITHUB_TOKEN` environment variable whose value is a GitHub [personal access
token](https://github.com/settings/tokens) with at least `repo` scope, and
SSO-enabled if appropriate.

## Granting team admin permissions

It would be good to take a team name, and grant that team `admin` on the repo.

In theory, you could do this via Octokit (the graphql API does not enable
manipulating team/repo access in that way), but in practice you need to have a
github token with organisation ownership access, which may not be desirable.

If you do want to do this:

* Add the relevant scopes to your github token
* Install the "octokit" gem
* Add code like that below to the `Repository` class
* Invoke `grant_team_admin_role` in `Repository#enforce_settings`

```ruby
  def grant_team_admin_role
    v3_api_client.add_team_repo(team_id, "#{organization}/#{name}", permission: "admin")
  end

  def team_id
    v3_api_client.team_by_name(organization, team).fetch(:id)
  end

  def v3_api_client
    @client ||= Octokit::Client.new(access_token: github_token)
  end
```
