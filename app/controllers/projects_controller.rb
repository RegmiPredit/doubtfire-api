class ProjectsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_current_user

  def index
    @projects = Project.where(:team_membership => @user.team_memberships)
  end

  def show
    @student_projects = Project.find(@user.team_memberships.map{|membership| membership.project_id})
    @project = Project.includes(:tasks => [:task_template]).find(params[:id])

    respond_to do |format|
      format.html
      format.json { 
        render json: @project.to_json(
          :include => [
            {
              :tasks => {:include => {:task_template => {:except=>[:updated_at, :created_at]}}, :except => [:updated_at, :created_at] }
            },
            :project_template => {:except => [:updated_at, :created_at]}
          ],
          :methods => [:relative_progress],
          :except => [:updated_at, :created_at]
        )
      }
    end
  end

  def load_current_user
    @user = current_user
  end
end