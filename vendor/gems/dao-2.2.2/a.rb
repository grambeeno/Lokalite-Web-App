Api =
  Dao.api do
    call('/foobar') do
      errors.add 'no bar' unless params[:bar]
      return!
      #apply(params)
      #validates_any_of :foo, :bar
      validate!
    end
  end

api = Api.new

result = api.call('/foobar', :foo => 42)

require 'pp'
pp result
