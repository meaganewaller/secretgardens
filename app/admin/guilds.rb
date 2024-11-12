ActiveAdmin.register Guild do
  menu priority: 3

  permit_params :name, :summary, :url, :slug, :tag_line, user_ids: []

  actions :all, except: [:new]

  filter :id
  filter :name
  filter :slug
  filter :summary
  filter :tag_line
  filter :created_at
  filter :updated_at
  filter :blog_posts

  index do
    selectable_column
    id_column
    column :name
    column :slug
    column :tag_line
    column :created_at
    column :updated_at

    actions
  end

  show do
    attributes_table_for(resource) do
      row :id
      row :name
      row :slug
      row :summary
      row :tag_line
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      f.input :name
      f.input :slug
      f.input :summary
      f.input :tag_line
      f.input :users, as: :select, input_html: { multiple: true }, collection: User.all
    end
    f.actions
  end
end
