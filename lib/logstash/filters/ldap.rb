# encoding: utf-8

require "logstash/filters/base"
require "logstash/namespace"
require 'digest/md5'

class LogStash::Filters::Ldap < LogStash::Filters::Base

  config_name "ldap"

   config :identifier_value, :validate => :string, :required => true
   config :identifier_key, :validate => :string, :required => false, :default => "uid"
   config :identifier_type, :validate => :string, :required => false, :default => "posixAccount"

   config :host, :validate => :string, :required => true

   config :ldap_port, :validate => :number, :required => false, :default => 389
   config :ldaps_port, :validate => :number, :required => false, :default => 636
   config :use_ssl, :validate => :boolean, :required => false, :default => false

   config :username, :validate => :string, :required => false
   config :password, :validate => :string, :required => false

   config :userdn, :validate => :string, :required => true
   config :userattrs, :validate => :array, :required => false, :default => ['givenName', 'sn']

   config :useCache, :validate => :boolean, :required => false, :default => false
   config :cache_interval, :validate => :number, :required => false, :default => 300


   public
   def register
     require 'ldap'
     @cache = {}
     @DEFAULT = "Unknown"
     @SUCCESS = "LDAP_OK"
     @FAILURE = "LDAP_ERR"
     @UNKNOWN = "LDAP_UNK"
   end

   public
   def filter(event)

     identifier_hash = hashIdentifier(@host, @port, @identifier_key, @identifier_value)

     exitstatus = @SUCCESS

     cached = false
     if @useCache
         cached = cached?(identifier_hash)
     end

     if cached
         login, user = cached
     else
         @logger.info("prompt LDAP for #{identifier_hash} informations")
         if use_ssl
             conn = LDAP::SSLConn.new(host=@host, port=@ldaps_port)
         else
             conn = LDAP::Conn.new(host=@host, port=@ldap_port)
         end

         res = ldapsearch(conn, @identifier_type, @identifier_key, @identifier_value)
         res.each{|key, value|
           event.set(key, value)
         }
         exitstatus = res['status']

         #cacheUID(identifier_hash, login, user)
     end

     if exitstatus != @SUCCESS
       if event.get("tags")
           event.set("tags", event.get("tags") << exitstatus)
       else
           event.set("tags", [exitstatus])
       end
     end

     filter_matched(event)
   end


   private

   def hashIdentifier(host, port, identifier_key, identifier_value)
     md5 = Digest::MD5.new
     md5.update(host)
     md5.update(port.to_s)
     md5.update(identifier_key)
     md5.update(identifier_value)
     return md5.hexdigest
  end

   def cached?(uidNumber)
     cached = @cache.fetch(uidNumber, false)
     if cached and Time.now - cached[2] <= @cache_interval
         return cached[0], cached[1]
     end
     return false
   end

   def cacheUID(uidNumber, login, user)
     @cache[uidNumber] = [login, user, Time.now]
   end

   def ldapsearch(conn, identifier_type, identifier_key, identifier_value)
     ret = { 'status' => @SUCCESS, 'err' => "" }

     begin
         conn.bind(username, password)
     rescue LDAP::Error => err
         @logger.error("Error: #{err.message}")
         ret['err'] = err
         ret['status']  = @FAILURE
         return ret
     end

     scope = LDAP::LDAP_SCOPE_SUBTREE

     begin
         conn.search(@userdn, scope, "(& (objectclass=#{identifier_type}) (#{identifier_key}=#{identifier_value}))", @userattrs) { |entry|

             hashEntry = {}
             for k in entry.get_attributes
                 ret[k] = entry.vals(k).join(" ")
             end

              match = 1
         }
     rescue LDAP::Error => err
         @logger.error("Error: #{err.message}")
         ret['err'] = err
         ret['status']  = @FAILURE
         return ret
     end

     #if ret['user'] == @DEFAULT
    #     ret['status'] = "#{@UNKNOWN}_USER"
    #     return ret
    # end

     return ret
   end

end
