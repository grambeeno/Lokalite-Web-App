require 'cgi'

class String
  def column
    parts = split('.')
    column_name = parts.pop
    table_name = parts.pop
    parts = []
    if table_name
      if table_name =~ /^[A-Z]/
        model = table_name.constantize
        table_name = model.table_name
      end
      parts.push(ActiveRecord::Base.connection.quote_table_name(table_name))
    end
    parts.push(ActiveRecord::Base.connection.quote_column_name(column_name))
    parts.join('.')
  end

  def String.unindented! s
    margin = nil
    s.each do |line|
      next if line =~ %r/^\s*$/
      margin = line[%r/^\s*/] and break
    end
    s.gsub! %r/^#{ margin }/, "" if margin
    margin ? s : nil
  end

  def String.unindented s
    s = "#{ s }"
    unindented! s
    s
  end

  def String.random options = {}
    Kernel.srand
    default_size = 6
    size = Integer(options.getopt(:size, default_size))
    default_chars = ( ('a' .. 'z').to_a + ('A' .. 'Z').to_a + (0 .. 9).to_a )
    %w( 0 O l ).each{|char| default_chars.delete(char)}
    chars = [ *options.getopt(:chars, default_chars).to_a ].flatten.compact.map{|char| char.to_s}
    Array.new(size).map{ chars[rand(2**32)%chars.size, 1] }.join
  end

  def unindented!
    String.unindented! self
  end

  def unindented
    String.unindented self
  end

  def String.indented! s, n = 2
    margin = ' ' * Integer(n)
    unindented!(s).gsub!(%r/^/, margin)
    s
  end

  def String.indented s, n = 2
    s = "#{ s }"
    indented! s, n
    s
  end

  def indented! n = 2
    String.indented! self, n
  end

  def indented n = 2
    String.indented self, n
  end

  def String.inlined! s
    #s.gsub! %r/([^\n]|\A)\n(?!\n)/, '\1 '
    s.strip!
    s.gsub! %r/([^\n])\n(?!\n)/, '\1 '
  end

  def String.inlined s
    s = "#{ s }"
    inlined! s
    s
  end

  def inlined!
    String.inlined! self
  end

  def inlined
    String.inlined self
  end

  def solid
    gsub %r/[ ]/, '&nbsp;'
  end

  def slug
    Slug.for(self)
  end

  def / other
    File.join self, other.to_s
  end

  def quoted
    "<b style='font-size:large'>&ldquo;</b>#{ self }<b style='font-size:large'>&rdquo;</b>"
  end

  def escapeHTML
    CGI.escapeHTML(self)
  end

  def escape_html
    CGI.escapeHTML(self)
  end

  def wrapped(options = {})
    options.to_options!
    with = options[:with]
    unless options[:empty]
      return to_s if empty?
    end
    with = with.to_s.split(//) unless with.is_a?(Array)
    first, last = with[0...with.size/2], with[with.size/2..-1]
    "#{ first }#{ to_s }#{ last }"
  end

  def ellipsis(n = 42)
    size >= n ? "#{ slice(0, n - 3) }..." : self
  end

  def to_list
    split(/\n/).map{|name| name.strip}.reject{|name| name.blank?}
  end
end

class Array
  def to_csv
    require 'csv' unless defined?(CSV)
    returning(string = String.new) do
      CSV::Writer.generate(string){|csv| each{|record| csv << record}}
    end
  end
end

class Object
  def singleton_class &block
    sc =
      class << self
        self
      end
    block ? sc.module_eval(&block) : sc
  end

  def deep_copy
    Marshal.load(Marshal.dump(self))
  end
end

class Numeric
  def parity
    (self.to_i % 2) == 0 ? 'even' : 'odd'
  end
end

class Fixnum
  LONG_MAX = ( (2 ** (64 - 2)) - 1 )
  INT_MAX = ( (2 ** (32 - 2)) - 1 )

  if LONG_MAX.class == Fixnum
    N_BYTES = 8
    N_BITS = 64
    MAX = LONG_MAX
    MIN = -MAX - 1
  else
    N_BYTES = 4
    N_BITS = 32 
    MAX = INT_MAX
    MIN = -MAX - 1
  end

  def Fixnum.max() MAX end
  def Fixnum.min() MIN end

  raise('bad Fixnum.max') unless (Fixnum.max + 1).class == Bignum
end

class Float
  PositiveInfinity = 42.0/0.0
  NegativeInfinity = -42.0/0.0
  Infinity = PositiveInfinity
  #def Infinity.+@() Infinity end
  #def Infinity.-@() Infinity end
  def Float.infinity() Infinity end
end 

class Time
  def Time.starts_at
    @starts_at ||= Time.at(0).utc
  end

  def Time.ends_at
    @ends_at ||= Time.parse('03:14:07 UTC on Tuesday, 19 January 2038')
  end
end

class Dir
  require 'tmpdir'
  Tmpdir = method(:tmpdir)

  def Dir.tmpdir(&block)
    return Tmpdir.call() unless block
    basename = [Process.ppid.to_s, Process.pid.to_s, Thread.current.object_id.abs.to_s, Time.now.to_f, rand.to_s].join('-')
    dirname = File.join(tmpdir, basename)
    FileUtils.mkdir_p(dirname)
    begin
      Dir.chdir(dirname) do
        return block.call(Dir.pwd)
      end
    ensure
      FileUtils.rm_rf(dirname) rescue "system rm -rf #{ dirname.inspect }"
    end
  end
end

class Hash
  def to_query_string options = {}
    escape = options.getopt(:escape, true)
    pairs = [] 
    esc = escape ? lambda{|v| CGI.escape(v.to_s)} : lambda{|v| v.to_s}
    each do |key, values|
      key = key.to_s
      values = [values].flatten
      values.each do |value|
        value = value.to_s
        if value.empty?
          pairs << [ esc[key] ]
        else
          pairs << [ esc[key], esc[value] ].join('=')
        end
      end
    end
    pairs.replace pairs.sort_by{|pair| pair.size}
    pairs.join('&')
  end
  alias_method :query_string, :to_query_string

  def to_css
    pairs = []
    each do |key, value|
      pairs << [key, value].join(':') unless value.blank?
    end
    css = pairs.join(';')
    css += ';' unless css.blank?
    css
  end

  def html_options
    to_a.map{|k,v| "#{ k }=#{ CGI.escapeHTML(v).inspect }"}.join(' ')
  end

  def html_attributes
    map{|k,v| [k, v.to_s.inspect].join('=')}.join(' ') 
  end
        
  def getopt key, default = nil
    [ key ].flatten.each do |key|
      return fetch(key) if has_key?(key)
      key = key.to_s
      return fetch(key) if has_key?(key)
      key = key.to_sym
      return fetch(key) if has_key?(key)
    end
    default
  end

  def getopts *args
    args.flatten.map{|arg| getopt arg}
  end

  def hasopt key, default = nil
    [ key ].flatten.each do |key|
      return true if has_key?(key)
      key = key.to_s
      return true if has_key?(key)
      key = key.to_sym
      return true if has_key?(key)
    end
    default
  end

  def hasopts *args
    args.flatten.map{|arg| hasopt arg}
  end

  def delopt key, default = nil
    [ key ].flatten.each do |key|
      return delete(key) if has_key?(key)
      key = key.to_s
      return delete(key) if has_key?(key)
      key = key.to_sym
      return delete(key) if has_key?(key)
    end
    default
  end

  def delopts *args
    args.flatten.map{|arg| delopt arg}
  end

  def select! *a, &b
    replace(select(*a, &b).to_hash)
  end
end


module Kernel
private
    def j(object, port=STDOUT)
      port << JSON.generate(object)
      port.is_a?(IO) ? nil : port
    end

    def jj(object, port=STDOUT)
      port << JSON.pretty_generate(object, :max_nesting => 0)
      port.is_a?(IO) ? nil : port
    end
end
