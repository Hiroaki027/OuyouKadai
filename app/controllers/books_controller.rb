class BooksController < ApplicationController
  before_action :is_matching_login_user, only: [:edit]

  def show
    @book = Book.find(params[:id])
    @book_new = Book.new
    @book_comment = BookComment.new
    unless ReadCount.where(created_at: Time.zone.now.all_day).find_by(user_id: current_user.id, book_id: @book.id)
      current_user.read_counts.create(book_id: @book.id)
    end
  end

  def index
    @book = Book.new
    #to = Time.current.at_end_of_day
    #from = (to - 6.day).at_beginning_of_day
    #@books = Book.includes(:favorites).
     # sort_by {|f|
      #  f.favorites.where(created_at: from..to).size
      #}.reverse
    if params[:latest]
      @books = Book.latest
    elsif params[:old]
      @books = Book.old
    elsif params[:star_count]
      @books = Book.star_count
    else
      @books = Book.all
    end
  end

  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    if @book.save
      redirect_to book_path(@book), notice: "You have created book successfully."
    else
      @books = Book.all
      render 'index'
    end
  end

  def edit
    @book = Book.find(params[:id])
  end

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to book_path(@book), notice: "You have updated book successfully."
    else
      render "edit"
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to books_path
  end

  private

  def book_params
    params.require(:book).permit(:title, :body,:star)
  end

  def is_matching_login_user
    book = Book.find(params[:id])
    unless book.user_id == current_user.id
      redirect_to books_path
    end
  end
end
