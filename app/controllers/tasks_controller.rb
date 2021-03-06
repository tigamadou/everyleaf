class TasksController < ApplicationController
  before_action :set_task, only: %i[ show edit update destroy ]

  def index
    @tasks = current_user.tasks.page params[:page]
    @tasks = @tasks.search(params[:search]) if params[:search].present? 
    @tasks = @tasks.filter_by_status(params[:status]) if params[:status].present? && params[:status] != 'not_set'
    @tasks = @tasks.filter_by_tag(params[:tag_id]) if params[:tag_id].present? 
    
    if params[:sort_expired].present?
      @tasks = @tasks.order_by_deadline
    elsif params[:sort_priority].present?
      @tasks = @tasks.order_by_priority
    else
      @tasks = @tasks.order("created_at DESC")
    end
    
     
  end

  def show
  end

  def new
    @task = Task.new
  end

  def edit
  end

  def create
    @task = Task.new(task_params)
    @task.user_id = current_user.id
    
    
    respond_to do |format|
      if @task.save
        @task.tags.build(params[:tag_ids])
        format.html { redirect_to @task, notice: "Task was successfully created." }
        format.json { render :show, status: :created, location: @task }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  def saveTags (tag_ids)

  end

  def update
    respond_to do |format|
      if @task.update(task_params)
        @task.tags.build(params[:tag_ids])
        
        format.html { redirect_to @task, notice: "Task was successfully updated." }
        format.json { render :show, status: :ok, location: @task }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to tasks_url, notice: "Task was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_task
      @task = Task.find(params[:id])
      
    end

    def task_params
      params.require(:task).permit(:name, :content, :expired_at, :status, :priority, tag_ids: [ ])
    end
end
