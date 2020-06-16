class Repository < GithubGraphQlClient
  attr_reader :organization, :name

  MASTER = "master"
  MAIN = "main"

  def initialize(params)
    @organization = params.fetch(:organization)
    @name = params.fetch(:name)
    super(params)
  end

  def enforce_settings
    setup_branch_protection
    apply_repository_settings
  end

  private

  def setup_branch_protection
    # it's easier to delete branch protection and then set it up again,
    # than to try and modify it in place
    branch_protection_rules
      .filter { |rule| rule["pattern"] == MASTER }
      .each { |rule| delete_branch_protection_rule(rule["id"]) }

    branch_protection_rules
      .filter { |rule| rule["pattern"] == MAIN }
      .each { |rule| delete_branch_protection_rule(rule["id"]) }

    create_branch_protection_rule
  end

  def apply_repository_settings
    mutation = %[
      mutation UpdateRepositorySettings {
        updateRepository(input: {
          repositoryId: "#{id}",
          hasIssuesEnabled: true
        }) {
          clientMutationId
        }
      }
    ]
    run_query(mutation)
  end

  def branch_protection_rules
    graphql_data.dig("data", "repository", "branchProtectionRules", "nodes")
  end

  def delete_branch_protection_rule(id)
    mutation = %[
      mutation DeleteMasterBranchProtection {
        deleteBranchProtectionRule(input: {
          branchProtectionRuleId: "#{id}"
        }) {
          clientMutationId
        }
      }
    ]
    run_query(mutation)
  end

  def create_branch_protection_rule
    mutation = %[
      mutation ProtectMasterBranch {
        createBranchProtectionRule(input: {
          repositoryId: "#{id}",
          dismissesStaleReviews: true,
          isAdminEnforced:true,
          pattern: "#{MAIN}",
          requiresApprovingReviews: true,
          requiresCodeOwnerReviews: true,
          requiredApprovingReviewCount: 1,
          requiresStatusChecks: true,
          requiresStrictStatusChecks: true
        }) {
          clientMutationId
        }
      }
    ]
    run_query(mutation)
  end

  def id
    graphql_data.dig("data", "repository", "id")
  end

  def graphql_data
    @data ||= JSON.parse(run_query(repo_settings_query))
  end

  def repo_settings_query
    %[
      {
        repository(name: "#{name}", owner: "#{organization}") {
          id
          name
          branchProtectionRules(first: 100) {
            nodes {
              id
              pattern
            }
          }
        }
      }
    ]
  end
end
