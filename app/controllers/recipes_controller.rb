class RecipesController < ApplicationController
	before_action :find_recipe, only: [:show, :edit, :update, :destroy]
	before_action :authenticate_user!, except: [:index, :show, :search]

	def search
		if params[:search].present?
			@recipe = Recipe.search(params[:search])
		else
			@recipe = Recipe.all
		end
	end

	def index
		@recipe = Recipe.all.order("created_at DESC")
	end

	def show
		@reviews = Review.where(recipe_id: @recipe.id).order("created_at DESC")
	end

	def new
		@recipe = current_user.recipes.build
	end

	def create
		@recipe = current_user.recipes.build(recipe_params)

		if @recipe.save
			redirect_to root_path, notice: "Succesfully created new recipe"
		else
			render 'new'
		end
	end

	def edit
	end

	def update
		if @recipe.update(recipe_params)
			redirect_to root_path
		else
			render 'edit'
		end
	end

	def destroy
		@recipe.destroy
		redirect_to root_path, notice: "succesfully deleted recipe"
	end

	def upvote
		@recipe = Recipe.find(params[:id])
		@recipe.upvote_by current_user
		redirect_back(fallback_location: root_path)
	end

	def downvote
		@recipe = Recipe.find(params[:id])
		@recipe.downvote_by current_user
		redirect_back(fallback_location: root_path)
	end

	private

	def recipe_params
		params.require(:recipe).permit(:title, :description, :image, ingredients_attributes: [:id, :name, :_destroy], directions_attributes: [:id, :step, :_destroy])
	end

	def find_recipe
		@recipe = Recipe.find(params[:id])
	end
end
