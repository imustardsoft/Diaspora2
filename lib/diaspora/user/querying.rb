#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module UserModules
    module Querying

      def find_visible_post_by_id( id, opts={} )
        post = Post.where(:id => id).joins(:contacts).where(:contacts => {:user_id => self.id}).where(opts).first
        post ||= Post.where(:id => id, :author_id => self.person.id).where(opts).first
        post ||= Post.where(:id => id, :public => true).where(opts).first
      end

      def visible_posts(opts = {})
        opts = opts.dup
        opts[:type] ||= ['StatusMessage', 'Photo']
        opts[:limit] ||= 15
        opts[:order] ||= 'updated_at DESC'
        order_field = opts[:order].split.first.to_sym
        opts[:hidden] ||= false
        order_with_table = 'posts.' + opts[:order]
        opts[:max_time] = Time.at(opts[:max_time]) if opts[:max_time].is_a?(Integer)
        opts[:max_time] ||= Time.now + 1
        select_clause ='DISTINCT posts.id, posts.updated_at AS updated_at, posts.created_at AS created_at'

        # cloud modify posts from others
        
        #posts_from_others = Post.joins(:contacts).where( :post_visibilities => {:hidden => opts[:hidden]}, :contacts => {:user_id => self.id})
       
        #posts_from_others = Post.joins(:aspects).where("posts.author_id != #{self.id} and aspects.id in (?)", opts[:by_members_of]) if opts[:by_members_of].class == "Array"
        #posts_from_others = Post.includes(:aspect_visibilities).where("posts.author_id != #{self.id} and aspect_visibilities.aspect_id = ?", opts[:by_members_of]) if (opts[:by_members_of].class == "Fixnum" || opts[:by_members_of].class == "String")
        
        # end
        #posts_from_self = self.person.posts
        
        # cloud comment line
#        if opts[:by_members_of]
#          puts "one two three four"
#          puts opts[:by_members_of].inspect
#          posts_from_others = posts_from_others.joins(:contacts => :aspect_memberships).where(:aspect_memberships => {:aspect_id => opts[:by_members_of]})
#          posts_from_self = posts_from_self.joins(:aspect_visibilities).where(:aspect_visibilities => {:aspect_id => opts[:by_members_of]})
#        end
        

        #posts_from_others = posts_from_others.select(select_clause).limit(opts[:limit]).order(order_with_table).where(Post.arel_table[order_field].lt(opts[:max_time]))
        #posts_from_self = posts_from_self.select(select_clause).limit(opts[:limit]).order(order_with_table).where(Post.arel_table[order_field].lt(opts[:max_time]))

        #all_posts = "(#{posts_from_others.to_sql}) UNION ALL (#{posts_from_self.to_sql}) ORDER BY #{opts[:order]} LIMIT #{opts[:limit]}"
        # end
        #post_ids = Post.connection.execute(all_posts).map{|r| r.first}

        #Post.where(:id => post_ids, :pending => false, :type => opts[:type]).select('DISTINCT posts.*').limit(opts[:limit]).order(order_with_table)
        Post.includes(:aspect_visibilities).select(select_clause).where("aspect_visibilities.aspect_id in (?)", opts[:by_members_of]).limit(opts[:limit]).order(order_with_table).where(Post.arel_table[order_field].lt(opts[:max_time])).where("pending = false").where(:type => opts[:type])
      end

      def visible_photos(opts = {})
        visible_posts(opts.merge(:type => 'Photo'))
      end

      def contact_for(person)
        return nil unless person
        contact_for_person_id(person.id)
      end
      def aspects_with_post(post_id)
        self.aspects.joins(:aspect_visibilities).where(:aspect_visibilities => {:post_id => post_id})
      end

      def contact_for_person_id(person_id)
        Contact.where(:user_id => self.id, :person_id => person_id).includes(:person => :profile).first
      end

      def people_in_aspects(requested_aspects, opts={})
        allowed_aspects = self.aspects & requested_aspects
        person_ids = contacts_in_aspects(allowed_aspects).collect{|contact| contact.person_id}
        people = Person.where(:id => person_ids)

        if opts[:type] == 'remote'
          people = people.where(:owner_id => nil)
        elsif opts[:type] == 'local'
          people = people.where('people.owner_id IS NOT NULL')
        end
        people
      end

      def aspects_with_person person
        contact_for(person).aspects
      end

      def contacts_in_aspects aspects
        aspects.inject([]) do |contacts,aspect|
          contacts | aspect.contacts
        end
      end

      def all_aspect_ids
        self.aspects.all.collect{|x| x.id}
      end

      def posts_from(person)
        return self.person.posts.where(:pending => false).order("created_at DESC") if person == self.person
        con = Contact.arel_table
        p = Post.arel_table
        post_ids = []
        if contact = self.contact_for(person)
          post_ids = Post.connection.execute(contact.post_visibilities.where(:hidden => false).select('post_visibilities.post_id').to_sql).map{|r| r.first}
        end
        post_ids += Post.connection.execute(person.posts.where(:public => true).select('posts.id').to_sql).map{|r| r.first}

        Post.where(:id => post_ids, :pending => false).select('DISTINCT posts.*').order("posts.created_at DESC")
      end
    end
  end
end
