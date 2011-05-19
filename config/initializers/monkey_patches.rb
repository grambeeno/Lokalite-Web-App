### https://rails.lighthouseapp.com/projects/8994/tickets/5657-rails-30-console-hard-aborts-on-attempted-autocompletion-patch-supplied

begin
  if defined?(Arel::Attribute::Predications) and defined?(Arel::Attribute::PREDICATES) and Arel::Attribute::PREDICATES.first.is_a?(Symbol)
    Arel::Attribute::Predications.module_eval do
      def self.instance_methods *args
        #warn "this module is deprecated, please use the PREDICATES constant"
        Arel::Attribute::PREDICATES.map{|x| x.to_s}
      end
    end
  end
rescue Object
  nil
end
