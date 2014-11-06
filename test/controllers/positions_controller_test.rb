require 'test_helper'

class PositionsControllerTest < ActionController::TestCase
  setup do
    @position = positions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:positions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create position" do
    assert_difference('Position.count') do
      post :create, position: { dest: @position.dest, eta: @position.eta, last_port: @position.last_port, last_upt: @position.last_upt, lat: @position.lat, long: @position.long, nav_status: @position.nav_status, prev_dest: @position.prev_dest }
    end

    assert_redirected_to position_path(assigns(:position))
  end

  test "should show position" do
    get :show, id: @position
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @position
    assert_response :success
  end

  test "should update position" do
    patch :update, id: @position, position: { dest: @position.dest, eta: @position.eta, last_port: @position.last_port, last_upt: @position.last_upt, lat: @position.lat, long: @position.long, nav_status: @position.nav_status, prev_dest: @position.prev_dest }
    assert_redirected_to position_path(assigns(:position))
  end

  test "should destroy position" do
    assert_difference('Position.count', -1) do
      delete :destroy, id: @position
    end

    assert_redirected_to positions_path
  end
end
