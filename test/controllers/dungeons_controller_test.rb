require 'test_helper'

class DungeonsControllerTest < ActionController::TestCase
  setup do
    @dungeon = dungeons(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:dungeons)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dungeon" do
    assert_difference('Dungeon.count') do
      post :create, dungeon: { coin: @dungeon.coin, dungeon_group_id: @dungeon.dungeon_group_id, exp: @dungeon.exp, floors: @dungeon.floors, img: @dungeon.img, name: @dungeon.name, stamina: @dungeon.stamina }
    end

    assert_redirected_to dungeon_path(assigns(:dungeon))
  end

  test "should show dungeon" do
    get :show, id: @dungeon
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @dungeon
    assert_response :success
  end

  test "should update dungeon" do
    patch :update, id: @dungeon, dungeon: { coin: @dungeon.coin, dungeon_group_id: @dungeon.dungeon_group_id, exp: @dungeon.exp, floors: @dungeon.floors, img: @dungeon.img, name: @dungeon.name, stamina: @dungeon.stamina }
    assert_redirected_to dungeon_path(assigns(:dungeon))
  end

  test "should destroy dungeon" do
    assert_difference('Dungeon.count', -1) do
      delete :destroy, id: @dungeon
    end

    assert_redirected_to dungeons_path
  end
end
