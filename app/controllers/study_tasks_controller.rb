class StudyTasksController < ApplicationController
  before_action :set_user
  
  def index
    @tasks = @user.study_tasks
  end

  def create
    openai_service = OpenaiService.new
    tasks_data = openai_service.generate_study_plan(@user)
    
    tasks_data.each do |task_data|
      @user.study_tasks.create!(
        title: task_data["title"],
        description: task_data["description"],
        completed: false
      )
    end
    
    redirect_to user_study_tasks_path(@user), notice: 'Study plan generated successfully!'
  rescue StandardError => e
    redirect_to user_study_tasks_path(@user), alert: "Error generating study plan: #{e.message}"
  end

  def update
    @task = @user.study_tasks.find(params[:id])
    if @task.update(task_params)
      redirect_to user_study_tasks_path(@user), notice: 'Task updated successfully!'
    else
      redirect_to user_study_tasks_path(@user), alert: 'Error updating task.'
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def task_params
    params.require(:study_task).permit(:completed)
  end
end
