require 'test_helper'

class ShipmentStatusesControllerTest < ActionController::TestCase
  setup do
    @shipment_status = shipment_statuses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:shipment_statuses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create shipment_status" do
    assert_difference('ShipmentStatus.count') do
      post :create, shipment_status: { title: @shipment_status.title }
    end

    assert_redirected_to shipment_status_path(assigns(:shipment_status))
  end

  test "should show shipment_status" do
    get :show, id: @shipment_status
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @shipment_status
    assert_response :success
  end

  test "should update shipment_status" do
    patch :update, id: @shipment_status, shipment_status: { title: @shipment_status.title }
    assert_redirected_to shipment_status_path(assigns(:shipment_status))
  end

  test "should destroy shipment_status" do
    assert_difference('ShipmentStatus.count', -1) do
      delete :destroy, id: @shipment_status
    end

    assert_redirected_to shipment_statuses_path
  end
end
