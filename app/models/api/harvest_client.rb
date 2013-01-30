class Api::HarvestClient
  def initialize(user)
    @client = Harvest.client(user.harvest_subdomain, user.harvest_username, user.harvest_password)
  end

  def all_projects
    @client.projects.all
  end

  def create(task_name, project_id)
    task = Harvest::Task.new
    task.name = task_name
    task = @client.task.create(task)
    assignment = Harvest::TaskAssignment.new
    assignment.task = task.id
    assignment.project = project_id
    @client.task_assignment.create(assignment)
  end

  def start_task(task_id, harvest_project_id, user_id)
    entries = find_entry(user_id, task_id)
    if entries.empty?
      entry = Harvest::TimeEntry.new
      entry.project_id = harvest_project_id
      entry.task_id = task_id
      entry.user_id = user_id
      @client.time.create(entry)
    end
  end

  def stop_task(task_id, user_id)
    entries = find_entry(user_id, task_id)
    @client.time.toggle() unless entries.empty?
  end

  def find_entry(user_id, task_id)
    entries = @client.time.all(Time.now, user_id).select do |entry|
      entry.task_id == task_id && entry.ended_at.nil?
    end
  end
end