class Category < ActiveRecord::Base
# joins
  has_many(:category_context_joins, :dependent => :destroy)

  Categories = %(

    Featured
    Happy Hour
    Music
    Retail
    Food & Dining
    Arts & Entertainment
    Sports & Recreation
    Health & Medical
    Beauty & Spas
    Campus
    Community
    Business & Tech
    Non-Profit
    Other

  ).to_list

  AdminCategories = %(

    Featured

  ).to_list

  UserCategories = Categories - AdminCategories

  def Category.categories
    Categories
  end

  def Category.list
    @list ||= order('position').map
  end

  def Category.names
    @names ||= list.map{|category| category.name}
  end

  def Category.options_for_select(options = {})
    options.to_options!
    user = options[:user]
    list = Category.list.map{|category| [category.id, category.name]}
    list.unshift([nil, nil]) unless options[:blank]==false
    list.reject!{|pair| AdminCategories.include?(pair.last)} unless options[:admin]
    list
  end

  def Category.add!(name)
    create!(:name => name, :position => Category.count)
  end

  def Category.for(arg)
    return arg if arg.is_a?(Category)
    case arg.to_s
      when %r/^\s*\d+\s*$/
        Category.find(arg)
      else
        Category.find_by_name(arg)
    end
  end

  def slug
    @slug ||= Slug.for(name)
  end
end
