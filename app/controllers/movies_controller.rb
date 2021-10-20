class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    
    if (params[:ratings]==nil && session[:ratings_to_show] != nil)
      # params[:ratings] = session[:ratings_to_show]
      @ratings_to_show = session[:ratings_to_show]
      @movies = Movie.with_ratings(@ratings_to_show)
      redirect = true
    elsif (params.has_key?(:ratings))
      @ratings_to_show = params[:ratings].keys
      @movies = Movie.with_ratings(@ratings_to_show)
    else
      @ratings_to_show = @all_ratings
      @movies = Movie.all
    end

        
    if (params[:clicked] == nil && session[:clicked] != nil)
      # params[:clicked] = session[:clicked]
      @clicked = session[:clicked]
      redirect = true
    elsif (params[:clicked] != nil)
      @clicked = params[:clicked]
    end
    
    session[:ratings_to_show] = @ratings_to_show
    session[:clicked] = @clicked
    
    if (@clicked == "release")
      @movies = @movies.order('release_date')
    elsif (@clicked == "title")
      @movies = @movies.order('title')
    end
    
    if(redirect)
      redirect_to movies_path(clicked: @clicked, ratings: Hash[@ratings_to_show.collect { |v| [v, 1] }])
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
