class RecipesController < ApplicationController
  def show
  	@recipe = Recipe.find(params[:id])
  end

  def update
  	@recipe = Recipe.find(params[:id])
  	if @recipe.update_attributes(params[:recipe])
  		redirect_to @recipe
  	else
  		render 'confirm_recipe'
  	end
  end	

  def edit
  end

  def index
    @recipes = Recipe.paginate(page: params[:page], :per_page => 10)
  end

  def parse_from_one_box
    split_text = params['recipe_text_box'].split("\r\n\r\n")

    logger.debug "HELLO #{split_text.size}"

    if split_text.size == 3
      info_text = split_text.shift()
      ingredients_text = split_text.shift()
      steps_text = split_text.shift()

      build_recipe(info_text, ingredients_text, steps_text)
    else
      flash_message(:error, "Recipe Format is incorrect.")
      render 'new_one_box', :locals => { :recipe => params['recipe_text_box'] }
    end

  end

  def parse_from_three_boxes
    if params["info_text_box"].blank?
      flash_message(:error, "Must Supply Recipe Info.")
      errored = true
    end
    if params["ingredients_text_box"].blank?
      flash_message(:error, "Must Supply Recipe Ingredients.")
      errored = true
    end
    if params["steps_text_box"].blank?
      flash_message(:error, "Must Supply Recipe Steps.")
      errored = true
    end

    if errored
      render "new", :locals => {:info => params["info_text_box"], :ingredients => params["ingredients_text_box"], :steps => params["steps_text_box"]}
    else

    	info_text = params["info_text_box"]
    	ingredients_text = params["ingredients_text_box"]
    	steps_text = params["steps_text_box"]

      build_recipe(info_text, ingredients_text, steps_text)

    end
  end

  def build_recipe(info_text, ingredients_text, steps_text)
    recipe_info = parse_recipe_information(info_text)
    recipe_ingredients = parse_ingredients(ingredients_text)
    recipe_steps = parse_steps(steps_text)

    @recipe = Recipe.new

    # save the original text to the recipe
    @recipe.original_text_info = info_text
    @recipe.original_text_ingredients = ingredients_text
    @recipe.original_text_steps = steps_text

    # add recipe info to recipe
    @recipe.title = recipe_info[:title]
    @recipe.source = recipe_info[:source]
    @recipe.prep_time = recipe_info[:prep_time]
    @recipe.cook_time = recipe_info[:cook_time]

    # add steps to recipe
    step_num = 0 
    recipe_steps.each do |step|
      step_num = step_num+1
      @recipe.steps.build(number: step_num, description: step)
    end

    # add ingredients to recipe
    recipe_ingredients.each do |ing|
      @recipe.ingredients.build(amount: ing[:amount], modifiers: ing[:modifiers], name: ing[:name], original_text: ing[:original_text])
    end

    @recipe.save()

    render 'confirm_recipe'
  end

  private
  	AMOUNT_REGEX = /(\s*)((\d*\s*)(\d+(\/|\.)\d+)|(\d+))/
		UNITS_REGEX = /(\s*)\b(.*)\b((dash)|(can)|(teaspoon)|(tablespoon)|(cup)|(quart)|(pint)|(pound)|(ounce)|(gallon)|(oz)|(lb)|(pt)|(qt)|(tsp)|(tbsp)|(tbl)|(t))s*\b/i
		UNIT_MODIFIER_REGEX = /\A(\s*)\(.+\)/
		INGREDIENT_MODIFIER_REGEX = /((,)(.)+)|(\(.+\))/

  	def parse_recipe_information(text)
  		split_text = text.split("\r\n")
  		
  		recipe_info = Hash.new()
  		recipe_info[:title] = split_text.shift().squish()
  		recipe_info[:source] = split_text.shift().squish()
  		recipe_info[:prep_time] = split_text.shift().gsub(/.+:/,"").squish() if !split_text[0].nil?&&split_text[0].include?("Prep")
  		recipe_info[:cook_time] = split_text.shift().gsub(/.+:/,"").squish() if !split_text[0].nil?&&split_text[0].include?("Cook")
  		
  		return recipe_info
  	end

  	def parse_ingredients(text)
  		text.strip!()
  		ingredients = Array.new
  		# pull out  					| carriage returns 	| tabs   			   | OR's  					   | and then combine multiple groups of ***'s, and split on them
  		split_text = text.gsub("\r\n", "***").gsub("\t","***").gsub(" OR ", "***").gsub(/\*{3,}/, "***").split("***")
  		split_text.each do |ing|
  			# grab the original text of the ingredient
  			original_text = ing.dup
  			# pull out what should be the number amount from the ingredient
  		  ing_amount = ing.slice!(AMOUNT_REGEX)

  		  # remove the periods so that we don't have to worry about finding them in the unit
    		ing.delete!(".")
   		  ing_unit = ing.slice!(UNITS_REGEX)

   		  # if we found a unit, then look for a modifier for that unit inside parens
   		  if !ing_unit.nil?
  		  	#look for unit modifiers
  		  	ing_unit_modifier = ing.slice!(UNIT_MODIFIER_REGEX)
  		  	# strip out all spaces around the parens 
  		  	if !ing_unit_modifier.nil?
	  		  	ing_unit_modifier.gsub!(/ *\( */, "(")
	  		  	ing_unit_modifier.gsub!(/ *\) */, ")")
	  		  	ing_unit = ing_unit + " " + (ing_unit_modifier || "")
	  		  end
  		  end

  		  # build the ingredient amount back up
  		  ing_amount = (ing_amount || "") + (ing_unit || "")

  		  ing_modifiers = ing.slice!(INGREDIENT_MODIFIER_REGEX)
  		  ing_modifiers.delete!(",") if !ing_modifiers.nil?

  		  ing_amount.squish!() if !ing_amount.nil? 
  		  ing_unit.squish!() if !ing_unit.nil?
  		  ing_modifiers.squish!() if !ing_modifiers.nil?
  		  ing.squish!() if !ing.nil?

  		  # now add the ingredient to the array to pass pack
  		  ingredients.push(amount: ing_amount, name: ing, modifiers: ing_modifiers, original_text: original_text) if !ing.blank?
  		end
  		return ingredients
  	end

  	def parse_steps(text)
  		split_text = text.gsub(/\.\s+/, ".***").split("***")
  		return split_text
  	end
end
