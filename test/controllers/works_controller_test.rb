require "test_helper"

describe WorksController do
  let (:work) { works(:movie) }
  let (:user) { users(:user_five) }

  describe "index" do
    it "should get index" do
      get works_path

      must_respond_with :success
    end
  end

  describe "show" do
    it "can get a valid work" do
      get work_path(work.id)

      must_respond_with :success
    end

    it "will redirect for an invalid work" do
      invalid_id = -1
      get work_path(invalid_id)

      expect(flash[:error]).must_equal "That work does not exist"
      must_respond_with :redirect
    end
  end

  describe "new" do
    it "can get the new task page" do
      get new_work_path

      must_respond_with :success
    end
  end

  describe "create" do
    it "can create a new work" do
      work_hash = {
        work: {
          category: "book",
          title: "A Song of Ice and Fire",
          creator: "George R. R. Martin",
          publication_year: 1996,
          description: "epic fantasy novel",
        },
      }

      expect {
        post works_path, params: work_hash
      }.must_change "Work.count", 1

      new_work = Work.find_by(title: work_hash[:work][:title])
      expect(new_work.category).must_equal work_hash[:work][:category]
      expect(new_work.publication_year).must_equal work_hash[:work][:publication_year]
      expect(new_work.description).must_equal work_hash[:work][:description]

      expect(flash[:success]).must_equal "Successfully created #{new_work.category} #{new_work.id}"
      must_respond_with :redirect
      must_redirect_to work_path(new_work.id)
    end

    it "can give an error message when no title is given" do
      work_hash = {
        work: {
          category: "book",
          title: "",
          creator: "George R. R. Martin",
          publication_year: 1996,
          description: "epic fantasy novel",
        },
      }
      post works_path, params: work_hash

      expect(flash.now[:title]).must_equal ["can't be blank"]
    end

    it "can give an error message when a repeat title is given" do
      work_hash = {
        work: {
          category: "movie",
          title: "The Thing",
        },
      }
      post works_path, params: work_hash

      expect(flash.now[:title]).must_equal ["has already been taken"]
    end
  end

  describe "edit" do
    it "can get the edit page for an existing work" do
      get edit_work_path(work.id)

      must_respond_with :success
    end

    it "will respond with redirect when attempting to edit a nonexistent work" do
      invalid_id = "Not a valid id!"

      get edit_work_path(invalid_id)

      expect(flash[:error]).must_equal "That work does not exist"
      must_respond_with :redirect
    end
  end

  describe "update" do
    it "can update an existing work" do
      work_change = {
        work: {
          publication_year: 2000,
          description: "this is a new description!",
        },
      }

      patch work_path(work.id), params: work_change

      edited_work = Work.find_by(id: work.id)
      expect(edited_work.publication_year).must_equal work_change[:work][:publication_year]
      expect(edited_work.description).must_equal work_change[:work][:description]

      expect(flash[:success]).must_equal "Successfully updated #{edited_work.category} #{edited_work.id}"
      must_respond_with :redirect
      must_redirect_to work_path(work.id)
    end

    it "can give an error message when no title is given" do
      work_change = {
        work: {
          title: "",
        },
      }
      patch work_path(work.id), params: work_change

      expect(flash.now[:title]).must_equal ["can't be blank"]
    end
  end

  describe "destroy" do
    it "returns a flash error if a work is not found" do
      invalid_work_id = -1

      expect {
        delete work_path(invalid_work_id)
      }.wont_change "Work.count"

      expect(flash[:error]).must_equal "That work does not exist"
    end

    it "can delete a work" do
      new_work = Work.create(title: "This is a title that will be deleted")

      expect {
        delete work_path(new_work.id)
      }.must_change "Work.count", -1

      expect(flash[:success]).must_equal "Successfully destroyed #{new_work.category} #{new_work.id}"
      must_respond_with :redirect
      must_redirect_to root_path
    end
  end

  describe "upvote" do
    it "allows a logged in user to vote for a new work" do
      login_data = {
        user: {
          username: user.username,
        },
      }
      post login_path, params: login_data

      expect {
        post upvote_work_path(work.id)
      }.must_change "work.votes.count", 1

      expect(flash[:success]).must_equal "Successfully upvoted!"
    end

    it "does not allow a user who is not logged in to vote" do
      expect {
        post upvote_work_path(work.id)
      }.must_change "work.votes.count", 0

      expect(flash[:error]).must_equal "You must log in to do that"
    end

    it "must send an error message when a person tries to vote on the same work more than once" do
      login_data = {
        user: {
          username: user.username,
        },
      }
      post login_path, params: login_data

      post upvote_work_path(work.id)

      expect {
        post upvote_work_path(work.id)
      }.must_change "work.votes.count", 0

      expect(flash[:error]).must_equal "user: has already voted for this work"
    end
  end
end
