require 'test_helper'

class CRatingsControllerTest < ActionController::TestCase
  setup do
    @c_rating = c_ratings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:c_ratings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create c_rating" do
    assert_difference('CRating.count') do
      post :create, c_rating: { comment_id: @c_rating.comment_id, score: @c_rating.score, user_id: @c_rating.user_id }
    end

    assert_redirected_to c_rating_path(assigns(:c_rating))
  end

  test "should show c_rating" do
    get :show, id: @c_rating
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @c_rating
    assert_response :success
  end

  test "should update c_rating" do
    patch :update, id: @c_rating, c_rating: { comment_id: @c_rating.comment_id, score: @c_rating.score, user_id: @c_rating.user_id }
    assert_redirected_to c_rating_path(assigns(:c_rating))
  end

  test "should destroy c_rating" do
    assert_difference('CRating.count', -1) do
      delete :destroy, id: @c_rating
    end

    assert_redirected_to c_ratings_path
  end
end
