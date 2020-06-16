# Enforce Repository Settings

Given a reference to a github repository, enforce a standard set of permissions
and other settings.

## Pre-requisites

A `GITHUB_TOKEN` environment variable whose value is a GitHub [personal access
token](https://github.com/settings/tokens) with at least `repo` scope, and
SSO-enabled if appropriate.

## Updating

A github action is used to build a docker image from this project, and publish
it to [docker hub]. To trigger this process, create a new [release]

## Running

First, set your `GITHUB_TOKEN` environment variable.

Get the correct (latest) [release] number, and edit the following command
accordingly, filling in the relevant `[repo name]`:

```bash
docker run --rm \
  -e GITHUB_TOKEN=${GITHUB_TOKEN} \
  ministryofjustice/enforce-repository-settings:1.0 ministryofjustice [repo name]
```

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

[docker hub]: https://hub.docker.com/repository/docker/ministryofjustice/enforce-repository-settings
[release]: https://github.com/ministryofjustice/enforce-repo-settings/releases
