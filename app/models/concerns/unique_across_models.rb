module UniqueAcrossModels
  def unique_across_models(attribute, **)
    validates attribute, presence: true
    validates(attribute, cross_model_slug: true, **, if: :"#{attribute}_changed?")
  end
end
