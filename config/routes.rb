RecipeParser::Application.routes.draw do
  resources :recipes
  resources :ingredients
  resources :steps

  root to:'recipes#new'

  match '/recipes/parse_from_three_boxes'

  match '/recipes/confirm_parsed_recipe'

  match '/new_one_box_recipe' => 'recipes#new_one_box'

  match '/recipes/parse_from_one_box'

end