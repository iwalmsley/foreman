require 'test_helper'

class Api::V2::HostConfigGroupsControllerTest < ActionController::TestCase
  def setup
    # By default HostConfigGroup is initialized with an entry for host_id: 1 via hostgroup
    # even though host does not exist
    @host = FactoryBot.create(:host, :with_config_group, :id => 2)
  end

  test "should get config_group ids for host" do
    get :index, params: { :host_id => @host.to_param }
    assert_response :success
    config_groups = ActiveSupport::JSON.decode(@response.body)
    assert !config_groups['results'].empty?
    assert_equal config_groups['results'].length, 1
  end

  test "should add a config group to a host" do
    assert_difference('@host.config_groups.count') do
      post :create, params: { :host_id => @host.to_param, :config_group_id => config_groups(:one).id }
    end
    assert_response :success
  end

  test "should remove a config_group from a host" do
    assert_difference('@host.config_groups.count', -1) do
      delete :destroy, params: { :host_id => @host.to_param, :id => @host.host_config_groups.first.config_group_id }
    end
    assert_response :success
  end

  test "should not add a config group that does not exist to a host" do
    post :create, params: { :host_id => @host.to_param, :config_group_id => "invalid_cfg_group_id" }
    assert_response :not_found
  end
end
