namespace(:vendor) do
  desc 'vendorize a gem'
  task(:gem, [:gem, :version]) do |task, options|
  ## setup
  #
    options.with_defaults(
      :gem  => (ENV['gem']  || ENV['GEM']),
      :dst  => (ENV['dst']  || ENV['DST'])
    )
    gem = options[:gem]
    version = options[:version]

    abort('no GEM!') unless gem

    gem_dir = gem_dir_for(gem, version)
    spec = spec_for(version, version)

  
    dst = File.join(Rails.root, 'vendor/gems', File.basename(gem_dir))
    abort("#{ dst } exists!") if test(?e, dst)
    FileUtils.mkdir_p(File.join(Rails.root, 'vendor/gems'))
    FileUtils.cp_r(gem_dir, dst)
    FileUtils.cp(spec, dst)
    puts(File.expand_path(dst))
  end

private
    def gem_dir_for(gem, version = nil)
      glob = File.join(Gem.dir, "gems", [gem, version].compact.join('-') + '*')
      entries = Dir.glob(glob).select{|entry| test(?d, entry)}
      entries = entries.sort_by{|entry| version = entry.split(/-/).last.scan(/\d+/).map{|i| i.to_i}; version}
      entries.last
    end

    def spec_for(gem, version = nil)
      glob = File.join(Gem.dir, "specifications", [gem, version].compact.join('-') + '*.gemspec')
      entries = Dir.glob(glob).select{|entry| test(?f, entry)}
      entries = entries.sort_by{|entry| version = entry.split(/-/).last.scan(/\d+/).map{|i| i.to_i}; version}
      entries.last
    end
end
