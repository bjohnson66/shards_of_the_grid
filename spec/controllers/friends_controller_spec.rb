require 'rails_helper'

RSpec.describe FriendsController, type: :controller do
  let!(:user) { create(:user) }
  let!(:friend) { create(:user, email: "friend@example.com") }
  let!(:pending_friend) { create(:user, email: "pending@example.com") }
  let!(:friendship) { create(:friendship, user: user, friend: friend, status: "accepted") }
  let!(:pending_friendship) { create(:friendship, user: user, friend: pending_friend, status: "pending") }

  before do
    allow(controller).to receive(:set_current_user).and_return(user)
    controller.instance_variable_set(:@current_user, user)
  end

  describe "GET #index" do
    it "assigns the user's friends, pending friend requests, and sent friend requests" do
      get :index
      expect(assigns(:friends)).to eq([friend])
      expect(assigns(:pending_friend_requests)).to eq([])
      expect(assigns(:sent_friend_requests)).to eq([pending_friend])
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "when the friend exists and is valid" do
      it "creates a friend request" do
        new_friend = create(:user, email: "newfriend@example.com")
        expect {
          post :create, params: { friend_email: new_friend.email }
        }.to change(Friendship, :count).by(1)

        expect(flash[:notice]).to eq("Friend request sent to #{new_friend.name}!")
        expect(response).to redirect_to(friends_path)
      end
    end

    context "when the friend does not exist" do
      it "sets a flash alert and redirects" do
        post :create, params: { friend_email: "nonexistent@example.com" }
        expect(flash[:alert]).to eq("No user found with the email nonexistent@example.com.")
        expect(response).to redirect_to(friends_path)
      end
    end

    context "when trying to friend oneself" do
      it "sets a flash alert and redirects" do
        post :create, params: { friend_email: user.email }
        expect(flash[:alert]).to eq("You cannot send a friend request to yourself.")
        expect(response).to redirect_to(friends_path)
      end
    end

    context "when the friend request already exists or they are already friends" do
      it "sets a flash alert and redirects" do
        post :create, params: { friend_email: friend.email }
        expect(flash[:alert]).to eq("#{friend.name} is already your friend or has a pending request.")
        expect(response).to redirect_to(friends_path)
      end
    end
  end

  describe "POST #accept" do
    context "when the friend request is valid" do
      it "accepts the friend request" do
        pending_request = create(:friendship, user: pending_friend, friend: user, status: "pending")
        post :accept, params: { id: pending_request.user.id }

        pending_request.reload
        expect(pending_request.status).to eq("accepted")
        expect(flash[:success]).to eq("Friend request accepted.")
        expect(response).to redirect_to(friends_path)
      end
    end

    context "when unable to accept the friend request" do
      it "sets a flash error" do
        allow_any_instance_of(Friendship).to receive(:update).and_return(false)
        pending_request = create(:friendship, user: pending_friend, friend: user, status: "pending")
        post :accept, params: { id: pending_request.user.id }

        expect(flash[:error]).to eq("Unable to accept friend request.")
        expect(response).to redirect_to(friends_path)
      end
    end
  end

  describe "DELETE #reject" do
    context "when the friend request is valid" do
      it "rejects the friend request" do
        pending_request = create(:friendship, user: pending_friend, friend: user, status: "pending")
        delete :reject, params: { id: pending_request.user.id }

        expect(Friendship.exists?(id: pending_request.id)).to be_falsey
        expect(flash[:notice]).to eq("Friend request rejected.")
        expect(response).to redirect_to(friends_path)
      end
    end

    context "when unable to reject the friend request" do
      it "sets a flash error" do
        allow_any_instance_of(Friendship).to receive(:destroy).and_return(false)
        pending_request = create(:friendship, user: pending_friend, friend: user, status: "pending")
        delete :reject, params: { id: pending_request.user.id }

        expect(flash[:error]).to eq("Unable to reject friend request.")
        expect(response).to redirect_to(friends_path)
      end
    end
  end

  describe "DELETE #cancel" do
    context "when the sent friend request is valid" do
      it "cancels the sent friend request" do
        delete :cancel, params: { id: pending_friend.id }
        expect(Friendship.exists?(id: pending_friendship.id)).to be_falsey
        expect(flash[:notice]).to eq("Friend request canceled.")
        expect(response).to redirect_to(friends_path)
      end
    end

    context "when unable to cancel the friend request" do
      it "sets a flash error" do
        allow_any_instance_of(Friendship).to receive(:destroy).and_return(false)
        delete :cancel, params: { id: pending_friend.id }

        expect(flash[:error]).to eq("Unable to cancel friend request.")
        expect(response).to redirect_to(friends_path)
      end
    end
  end

  describe "DELETE #unfriend" do
    context "when the friendship exists" do
      it "removes the friend" do
        delete :unfriend, params: { id: friend.id }
        expect(Friendship.exists?(id: friendship.id)).to be_falsey
        expect(flash[:notice]).to eq("Friend removed successfully.")
        expect(response).to redirect_to(friends_path)
      end
    end

    context "when unable to remove the friend" do
      it "sets a flash error" do
        allow_any_instance_of(Friendship).to receive(:destroy).and_return(false)
        delete :unfriend, params: { id: friend.id }

        expect(flash[:error]).to eq("Unable to remove friend.")
        expect(response).to redirect_to(friends_path)
      end
    end
  end
end
