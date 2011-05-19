preinitializers_dir = File.dirname(File.expand_path(__FILE__))
config_dir = File.dirname(preinitializers_dir)
rails_root = File.dirname(config_dir)
vendor_gems = File.join(rails_root, 'vendor/gems')
glob = File.join(vendor_gems, '*')

Dir.glob(glob) do |gemdir|
  libdir = File.join(gemdir, 'lib')
  $LOAD_PATH.push(libdir)
  #parts = File.basename(gemdir).split('-')
  #version = parts.pop
  #gemname = parts.join('-')
end
