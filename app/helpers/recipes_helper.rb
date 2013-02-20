module RecipesHelper

	def get_new_fields(f,association)
    logger.debug "Attempting: New Class #{f.object.class}.reflect_on_association(association).klass}"
    new_object = f.object.class.reflect_on_association(association).klass.new
    logger.debug "Success: New Class #{f.object.class.reflect_on_association(association).klass}"
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render('confirm_'+association.to_s.singularize, :f => builder)
    end
    return fields
  end

	def button_to_add_ingredient(f)
    fields = get_new_fields(f, :ingredients)
    button_to_function("Add Ingredient", "add_ingredient_fields(\"#{:ingredients}\", \"#{escape_javascript(fields)}\")", :class => "secondary radius button expand")
  end

  def button_to_remove_fields(f)
    f.hidden_field(:_destroy) + button_to_function("X", "remove_fields(this)", :class => "button secondary deletebutton radius")
  end

  def button_to_add_step(f)
    fields = get_new_fields(f, :steps)
    button_to_function("Add Step", "add_step_fields(\"#{:steps}\", \"#{escape_javascript(fields)}\")", :class => "secondary radius button expand")
  end

end
