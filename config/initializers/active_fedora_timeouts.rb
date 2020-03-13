module ActiveFedoraOverride
  def authorized_connection
    super.tap do |conn|
      conn.options[:timeout] = 9999
    end
  end
end

ActiveFedora::Fedora.class_eval do
  prepend ActiveFedoraOverride unless self.class.include?(ActiveFedoraOverride)
end
