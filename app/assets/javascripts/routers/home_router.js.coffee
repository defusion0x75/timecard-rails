class Timecard.Routers.Home extends Backbone.Router
  routes:
    "users/:user_id/projects/:project_id/issues/:state": "showUserProjectIssues"

  initialize: ->
    @projects = new Timecard.Collections.Projects()
    @issues = new Timecard.Collections.Issues()

  showUserProjectIssues: (user_id, project_id, state) ->
    $('.nav-pills li').removeClass('active')
    $('#project-'+project_id).addClass('active')
    @issues.fetch
      data:
        user_id: user_id
        project_id: project_id
        status: state
      success: (collection) ->
        @viewIssuesState = new Timecard.Views.IssuesState(user_id: user_id, project_id: project_id)
        @viewIssuesState.render()
        @viewIssuesIndex = new Timecard.Views.IssuesIndex(issues: collection)
        @viewIssuesIndex.render()
