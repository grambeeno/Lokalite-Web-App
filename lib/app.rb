App = Rails.application

App.singleton_class do
# conf
#
  fattr(:name){ Rails.application.class.name.split(/::/).first.underscore }
  fattr(:protocol){ DefaultUrlOptions.protocol }
  fattr(:host){ DefaultUrlOptions.host }
  fattr(:port){ DefaultUrlOptions.port }
  fattr(:domain){ host.split(/./).first || "#{ name }.com" }

  fattr(:logger){ Rails.logger }
  fattr(:email){ "#{ name }@#{ domain }" }

# encryption/encoding support
#
  def encrypt(plaintext, options = {})
    ciphertext = Encryptor.encrypt(plaintext, options)
    encodedtext = Encoder.encode(ciphertext)
  end

  def decrypt(encodedtext, options = {})
    ciphertext = Encoder.decode(encodedtext)
    plaintext = Encryptor.decrypt(ciphertext, options)
  end

  def recrypt(plaintext, options = {})
    decrypt(encrypt(plaintext, options), options)
  end

  def encode(plaintext)
    encodedtext = Encoder.encode(plaintext)
  end

  def decode(encodedtext)
    plaintext = Encoder.decode(encodedtext)
  end

  def recode(plaintext)
    decode(encode(plaintext))
  end

# uuid generation
#
  def uuid(*args)
    UUIDTools::UUID.timestamp_create.to_s
  end

# domid generation
#
  def App.domid(*args)
    args.flatten!
    args.compact!
    args.push('app') if args.empty?
    args.push(App.uuid)
    args.join('-')
  end

# support for rails independent url generation. useful in mailers, background jobs, etc.
#
  def App.slash(options = {})
    options = options.to_options!

    protocol = options.has_key?(:protocol) ? options[:protocol] : App.protocol
    host = options.has_key?(:host) ? options[:host] : App.host
    port = options.has_key?(:port) ? options[:port] : App.port

    slash = []
    if protocol and host
      protocol = protocol.to_s.split(/:/, 2).first 
      slash << protocol
      slash << "://#{ host }"
    else
      slash << "//#{ host }"
    end
    if port
      slash << ":#{ port }"
    end
    slash.join
  end

  def App.url(*args)
    options = args.extract_options!.to_options!

    path_info = options.delete(:path_info) || options.delete(:path)
    query_string = options.delete(:query_string)
    fragment = options.delete(:fragment) || options.delete(:hash)
    query = options.delete(:query) || options.delete(:params)

    if query and !options.empty?
      raise ArgumentError, 'use App.url(..., :query => {}) to specify query options'
    end

    if query.nil? and !options.empty?
      query = options
    end

    raise ArgumentError, 'both of query and query_string' if query and query_string

    args.push(path_info) if path_info
    slash = App.slash(options).sub(%r|/*$|,'')
    url = slash + ('/' + args.join('/')).gsub(%r|/+|,'/')

    url += ('?' + query_string) unless query_string.blank?
    url += ('?' + query.query_string) unless query.blank?
    url += ('#' + fragment) if fragment
    url
  end

  def App.url_for(*args, &block)
    helper.url_for(*args, &block)
  end

  def App.helper
    Helper.new(ActionController::Base.current)
  end

  def App.json_for(*args)
  ### from yajl/json_gem
    if Rails.env.development?
      JSON.pretty_generate(*args)
    else
      JSON.generate(*args)
    end
  end

  def App.parse_json(*args)
  ### from yajl/json_gem
    JSON.parse(*args)
  end

  def App.token_for(options = {})
    options.to_options!
    data = options[:data]
    expires = Time.parse((options[:expires] || 1.week.from_now.iso8601).to_s)
    hash = {'data' => data, 'expires' => expires.iso8601}
    json = App.json_for(hash)
    App.encode(json)
  end

  def App.parse_token(token)
    returning(token.to_s) do |token|
      token.fattr(:data => nil)
      token.fattr(:expires => nil)
      token.fattr(:expired => nil)
      token.fattr(:valid){ !expired }

      unless token.blank?
        begin
          json = App.decode(token)
          hash = App.parse_json(json)
          token.data = hash['data']
          token.expires = Time.parse(hash['expires'] || Time.now.iso8601)
          token.expired = Time.now >= token.expires
        rescue
          nil
        end
      end
    end
  end

end
