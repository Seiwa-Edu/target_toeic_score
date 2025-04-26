require "test_helper"

class StudyTasksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get study_tasks_index_url
    assert_response :success
  end

  test "should get create" do
    get study_tasks_create_url
    assert_response :success
  end

  test "should get update" do
    get study_tasks_update_url
    assert_response :success
  end
end
