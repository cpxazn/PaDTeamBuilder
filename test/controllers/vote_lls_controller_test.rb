require 'test_helper'

class VoteLlsControllerTest < ActionController::TestCase
  setup do
    @vote_ll = vote_lls(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:vote_lls)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create vote_ll" do
    assert_difference('VoteLl.count') do
      post :create, vote_ll: { leaders: @vote_ll.leaders, score: @vote_ll.score, user_id: @vote_ll.user_id }
    end

    assert_redirected_to vote_ll_path(assigns(:vote_ll))
  end

  test "should show vote_ll" do
    get :show, id: @vote_ll
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @vote_ll
    assert_response :success
  end

  test "should update vote_ll" do
    patch :update, id: @vote_ll, vote_ll: { leaders: @vote_ll.leaders, score: @vote_ll.score, user_id: @vote_ll.user_id }
    assert_redirected_to vote_ll_path(assigns(:vote_ll))
  end

  test "should destroy vote_ll" do
    assert_difference('VoteLl.count', -1) do
      delete :destroy, id: @vote_ll
    end

    assert_redirected_to vote_lls_path
  end
end
